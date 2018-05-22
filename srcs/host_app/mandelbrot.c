#include "mandelbrot.h"

using namespace std;

#define IS_BIG_ENDIAN (*(uint16_t *)"\0\xff" < 0x100)

MandelbrotImage::MandelbrotImage(bool _is_3d, bool _darken) {
  
  // "Static" init (hack).
  if (!static_init_done) {
    MandelbrotImage::default_color_scheme = allocGradientsColorScheme(default_color_scheme_size, 8, 4);
    static_init_done = true;
  }
  
  color_scheme = NULL;
  color_scheme_size = 0;
  depth_array = NULL;
  pixel_data = NULL;
  png = NULL;
  width = height = 0;
  x = y = pix_x = pix_y = (coord_t)0.0;
  is_3d = _is_3d;
  
  // For darkening distant 3D depths.
  darken = _darken;
  start_darkening_depth = 0;
  half_faded_depth = 0;
  
  assert(! IS_BIG_ENDIAN);
};
  
MandelbrotImage::MandelbrotImage(double *params, bool _is_3d, bool _darken) : MandelbrotImage(_is_3d, _darken) {
  setColorScheme();
  setBounds(params);
};
 
MandelbrotImage::~MandelbrotImage() {
  if (pixel_data != NULL) {
    free(pixel_data);
  }
  if (png != NULL) {
    free(png);
  }
}



MandelbrotImage * MandelbrotImage::enable3D() {
  is_3d = true;
  return this;
}

MandelbrotImage * MandelbrotImage::enableTimer(int level) {
  timer_level = level;
  return this;
}

// Set the color scheme.
MandelbrotImage *MandelbrotImage::setColorScheme() {
  if (color_scheme != NULL) {
    cerr << "Error (mandelbrot.c): Color scheme set multiple times.\n";
  }
  color_scheme = MandelbrotImage::default_color_scheme;
  color_scheme_size = default_color_scheme_size;
  
  return this;
}
 
MandelbrotImage *MandelbrotImage::setBounds(double *params) {
  x = (coord_t)params[0];
  y = (coord_t)params[1];
  pix_x = (coord_t)params[2];
  pix_y = (coord_t)params[3];
  width = (int)params[4];
  height = (int)params[5];
  max_depth = (int)params[6];
  if (is_3d) {
    // For 3D images, we compute 2x h/w images for greater resolution of the 1x 3D image.
    x -= (coord_t)width  / 2.0 * pix_x;
    y -= (coord_t)height / 2.0 * pix_y;
    width *= RESOLUTION_FACTOR_3D;
    height *= RESOLUTION_FACTOR_3D;
  }
  cout << "New image: upper-left = (" << x << ", " << y << "), pix_size = (" << pix_x << ", " << pix_y
       << "), img_size = (" << width << ", " << height << "), max_depth = " << max_depth << "\n";

  return this;
};

/*
coord_t MandelbrotImage::getCenterX() {
  return x + pix_x * width / 2.0;
};

coord_t MandelbrotImage::getCenterY() {
  return y + pix_y * height / 2.0;
};
*/


MandelbrotImage *MandelbrotImage::make3d() {
  startTimer();
  // The 3D image has a plane at each depth with a cut-out Mandelbrot hole for that depth of iterations.
  // The separation between each plane is scaled by a scaling factor (< 1.0) from the previous, while
  // the plane coordinate system remains constant across planes. The scale of the 3D object, however,
  // grows by 1/scaling_factor with each depth of zoom. This is achieved by doing all computation based
  // on units of depth from the eye. Pix_x/y determines the coordinate system at a constant depth (eye_fit_depth)
  // (and if we implement two eyes, their separation is a constant number of pixels).

  // The shape of each plane is given by the depth data array of the Mandelbrot set already computed.
  // Beyond the fit_depth we need access to x/y coordinates outside the ones at the fit depth (TODO).
  
  // Assumptions:
  //   o pix_x/pix_y reflect a whole number of depths of zoom.

  int width_3d = width / RESOLUTION_FACTOR_3D;
  int height_3d = height / RESOLUTION_FACTOR_3D;
  int *depth_array_3d = (int *)malloc(width_3d * height_3d * sizeof(int));
  
  //-coord_t center_x = getCenterX();
  //-coord_t center_y = getCenterY();
  coord_t center_w_2d = width / 2.0L;
  coord_t center_h_2d = height / 2.0L;
  coord_t center_w_3d = width_3d / 2.0L;
  coord_t center_h_3d = height_3d / 2.0L;
  
  //-coord_t img_size_y = pix_y * height;
  coord_t eye_fit_depth = -7.0L;
     // Depth of the eye (negative) at which the depth=0 circle Y-dimension fits the image height.
     // Well, not exactly. In reality, the first depth is -1/eye_fit_depth of the way to the fit depth.
  coord_t pix_y_fit = 4.0L / (coord_t)height;  // Pixel size at which plane-0 (the circle) is fit to the image.
  coord_t scaling_factor = 0.92L;  // Empirical.
  coord_t zoom_depth = log(scaling_factor, pix_y / pix_y_fit);  // Number of depths zoomed from fit, where the eye remains a constant number of depths from the image.
  coord_t eye_depth = zoom_depth + eye_fit_depth;
  
  // Begin with the first depth plane in front of the eye.
  int first_depth = ((int)(eye_depth + 1000.0L + 0.01L)) - 1000 + 1;
     // Round up (+1000.0 used to operate on positive value; +0.01 to avoid depth w/ infinite pix_x/y; +1 to round up, not down).
  //-// Initialize depth_pix_x/y for the first depth.
  //-coord_t tmp = pow(1.0 / scaling_factor, zoom_depth - first_depth);
  //-coord_t depth_pix_x = pix_x * tmp;
  //-coord_t depth_pix_y = pix_y * tmp;
  
  for (int h_3d = 0; h_3d < height_3d; h_3d++) {
    coord_t h_from_center_3d = (coord_t)h_3d - center_h_3d;
    for (int w_3d = 0; w_3d < width_3d; w_3d++) {
      coord_t w_from_center_3d = (coord_t)w_3d - center_w_3d;
      int depth_from_eye = 1;
      int depth = first_depth;
      coord_t depth_separation = 1.0L; // Absolute separation between subsequent depths.
      coord_t dist_from_eye = depth_separation; // Absolute distance from eye in units of first-depth-distance.
      bool done = false;
      while (!done && depth < max_depth) {
        coord_t multiplier_3d_to_2d = dist_from_eye / - eye_fit_depth;
        
        int w_2d = round(center_w_2d + w_from_center_3d * multiplier_3d_to_2d);
        int h_2d = round(center_h_2d + h_from_center_3d * multiplier_3d_to_2d);
        if (w_2d < 0 || w_2d >= width ||
            h_2d < 0 || h_2d >= height) {
          // Outside the 2d image. Make everything solid.
          done = true;
        } else {
          done = depth_array[h_2d * width + w_2d] <= depth;
        }
        
        // Next
        depth++;
        depth_from_eye++;
        depth_separation *= scaling_factor;
        dist_from_eye += depth_separation;
      }
      depth_array_3d[h_3d * width_3d + w_3d] = depth;
    }
  }
  
  // Replace depth_array w/ 3d depth array.
  // Since it has a different size, also correct that.
  free(depth_array);
  depth_array = depth_array_3d;
  width = width_3d;
  height = height_3d;
  
  start_darkening_depth = zoom_depth;
  half_faded_depth = 30;

  stopTimer("make3d()");
  
  return this;
};

MandelbrotImage *MandelbrotImage::generateDepthArray() {
  startTimer();
  // Fill depth_array with depth for each pixel.
  
  depth_array = (int *)malloc(width * height * sizeof(int));

  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
      coord_t xx = x + pix_x * w;
      coord_t yy = y + pix_y * h;
      coord_t x0 = xx;
      coord_t y0 = yy;
      int iteration = 0;
      while (xx*xx + yy*yy < 2*2 && iteration < max_depth) {
        coord_t xtemp = xx*xx - yy*yy + x0;
        yy = 2*xx*yy + y0;
        xx = xtemp;
        iteration += 1;
      }
      depth_array[h * width + w] = iteration;
    }
  }
  
 stopTimer("generateDepthArray()");

  return this;
}

MandelbrotImage *MandelbrotImage::generatePixels(int *data) {
  if (data != NULL) {
    assert(depth_array == NULL);
    depth_array = data;
  }
  if (depth_array == NULL) {
    generateDepthArray();
  }
  cout << "Entered MandelbrotImage::generatePixels.\n";
  if (pixel_data != NULL) {
    cerr << "Error (mandelbrot.c): Pixels generated multiple times.\n";
  }
  if (color_scheme == NULL) {
    cerr << "Error (mandelbrot.c): Can't generatePixels(..) without a color scheme.\n";
  } else {
    if (is_3d) {
      make3d();
    }
    
    startTimer();
  
    /*
    // To avoid byte writes, we pack bytes.
    ...
    int byte_ind = 0;
    int int_data;
    int int_bytes;
    for (int h = 0; h < height; h++) {
      // Handle left-over bytes.
      for (int w = 0; w < width && byte_ind < sizeof int; w++, byte_ind++) {
        int_data &= 
      }
      for (int w = --; w < width; w++) {
        if (by)
      }
    }
    */
    pixel_data = (unsigned char *) malloc(width * height * 3);
    
    int j = 0;

    // Building the image pixels data
    for(int i = 0; i < width * height * 3; i+=3) {
      int depth = depth_array[j];

      float brightness;
      bool shadow = darken && depth > start_darkening_depth;
      if (shadow) {
        brightness = 1.0L / (1.0L + (long double)(depth - start_darkening_depth) / half_faded_depth);
      }
      for(int k = 0; k < 3; k++) {
        if (depth == max_depth)
          pixel_data[i + k] = 0;
        else
          pixel_data[i + k] = color_scheme[depth % color_scheme_size].component[k];
          if (shadow) {
            pixel_data[i + k] = (int)(((float)pixel_data[i + k]) * brightness);
          }
      }
      
      j++;
    }
    stopTimer("generatePixels()");
  }
  
  return this;
};

unsigned char *MandelbrotImage::generatePNG(size_t *png_size_p) {
  if (png != NULL) {
    cerr << "Error (mandelbrot.c): PNG generated multiple times.\n";
  }
  if (pixel_data == NULL) {
    generatePixels();
  }
  
  startTimer();
  
  // Generate the png image
  unsigned error = lodepng_encode24(&png, png_size_p, pixel_data, width, height);
  if(error) perror("Error in generating png");
  
  stopTimer("generatePNG()");
  return png;
};


/*
**
** Funcitons that return a color scheme as an array of &size colors.
**
*/
MandelbrotImage::color_t * MandelbrotImage::allocGradientsColorScheme(int &size, int num_gradients, int increments) {
  size = num_gradients * increments;
  color_t * color_scheme = (color_t *) malloc(sizeof(color_t) * size);
  color_t color;

  for (int g = 0; g < num_gradients; g++) {
    // Start gradient from one corner of color cube. Choose corner based on lower 3 bits of gradient.
    for (int component = 0; component < 3; component++) {
      color.component[component] = (((g >> component) & 1) == 0) ? 0 : 255;
    }
    // Shift one gradient from 0..255. (Always from 0 is a strange choice.)
    int component = g % 3;
    if (color.component[component] == 255)
      color.component[component] = 0;

    for (int i = 0; i < increments; i++) {
      color_scheme[g * increments + i] = color;
      color.component[component] += 256 / increments;
    }
  }
  
  return color_scheme;
};

/*
 * Args:
 *   &size: size of the color scheme.
 *   num_colors: the number of colors in the color scheme. (Yes, this is the same as size; this just preserves a similar interface to other color scheme methods.)
 */
MandelbrotImage::color_t * MandelbrotImage::allocRandomColorScheme(int &size, int num_colors) {
  size = num_colors;
  color_t * color_scheme = (color_t *) malloc(sizeof(color_t) * size);
  
  for (int c = 0; c < size; c++) {
    for (int component = 0; component < 3; component++) {
      color_scheme[c].component[component] = (unsigned char)rand();
    }
  }
  
  return color_scheme;
};

// This function is used to extract bits from an integer number
int MandelbrotImage::extract_bits(int value, int bit_quantity, int start_from) {
  unsigned mask;
  mask = ((1 << bit_quantity) - 1) << start_from;

  return (value & mask) >> start_from;
};

MandelbrotImage::coord_t MandelbrotImage::log(MandelbrotImage::coord_t base, MandelbrotImage::coord_t x) {
  return std::log(x) / std::log(base);
}

void MandelbrotImage::startTimer() {
  clock_gettime(CLOCK_MONOTONIC_RAW, &timer_start_time);
}
timespec MandelbrotImage::stopTimer(string tag) {
  timespec end;
  uint64_t delta_us;
  clock_gettime(CLOCK_MONOTONIC_RAW, &end);
  delta_us = (end.tv_sec - timer_start_time.tv_sec) * 1000000 + (end.tv_nsec - timer_start_time.tv_nsec) / 1000;
  cout << "Execution time of " << tag << ": " << delta_us << " [us]\n";
  return end;
}

void MandelbrotImage::stopStartTimer(string tag) {
  timer_start_time = stopTimer(tag);
}

// Static initialization.
bool MandelbrotImage::static_init_done = false;
MandelbrotImage::color_t * MandelbrotImage::default_color_scheme;
int MandelbrotImage::default_color_scheme_size;
