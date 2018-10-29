#include "mandelbrot.h"

using namespace std;

#define IS_BIG_ENDIAN (*(uint16_t *)"\0\xff" < 0x100)

MandelbrotImage::MandelbrotImage(double *params) {
  // "Static" init (hack).
  if (!static_init_done) {
    // Allocate color schemes (never deallocated).
    MandelbrotImage::num_color_schemes = 2;
    MandelbrotImage::color_scheme_size = (int *) malloc(sizeof(int) * MandelbrotImage::num_color_schemes);
    MandelbrotImage::color_scheme = (color_t **) malloc(sizeof(color_t *) * MandelbrotImage::num_color_schemes);
    MandelbrotImage::color_scheme[0] = allocGradientsColorScheme(MandelbrotImage::color_scheme_size[0], 8, 64);
    MandelbrotImage::color_scheme[1] = allocRandomColorScheme(MandelbrotImage::color_scheme_size[1], 32);
    static_init_done = true;
  }
  
  depth_array = NULL;
  pixel_data = NULL;
  png = NULL;
  width = height = 0;
  x = y = pix_x = pix_y = (coord_t)0.0;
  is_3d = (params[9] > 0.0);
  adjustment = params[7] / 100.0;
  
  // For darkening distant 3D depths.
  darken = (params[12] > 0.0);
  start_darkening_depth = 0;
  half_faded_depth = 0;
  
  assert(! IS_BIG_ENDIAN);

  setColorScheme(is_3d ? 1 : 0);
  setBounds(params);
};
 
MandelbrotImage::~MandelbrotImage() {
  if (depth_array != NULL) {
    free(depth_array);
  }
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

MandelbrotImage * MandelbrotImage::setColorScheme(int scheme) {
  active_color_scheme = scheme;  
  return this;
}

MandelbrotImage::color_t * MandelbrotImage::getColorScheme() {
  return color_scheme[active_color_scheme];
}
int MandelbrotImage::getColorSchemeSize() {
  return color_scheme_size[active_color_scheme];
}

 
MandelbrotImage *MandelbrotImage::setBounds(double *params) {
  x = (coord_t)params[0];
  y = (coord_t)params[1];
  pix_x = (coord_t)params[2];
  pix_y = (coord_t)params[3];
  width = (int)params[4];
  height = (int)params[5];
  max_depth = (int)params[6];
  center_offset_w = (int)(params[10]);
  center_offset_h = (int)(params[11]);
  if (is_3d) {
    // For 3D images, we compute larger h/w images for greater resolution of the 1x 3D image.
    //x -= (coord_t)width  / 2.0 * (RESOLUTION_FACTOR_3D - 1) * pix_x;
    //y -= (coord_t)height / 2.0 * (RESOLUTION_FACTOR_3D - 1) * pix_y;
    width *= RESOLUTION_FACTOR_3D;
    height *= RESOLUTION_FACTOR_3D;
    // Preserve the relative position of the offset.
    center_offset_w *= RESOLUTION_FACTOR_3D;
    center_offset_h *= RESOLUTION_FACTOR_3D;
  }
  center_w = (width  >> 1) + center_offset_w;
  center_h = (height >> 1) + center_offset_h;
  cout << "New image: center coords = (" << x << ", " << y << "), pix_size = (" << pix_x << ", " << pix_y
       << "), img_size = (" << width << ", " << height << "), center = (" << center_w << ", " << center_h
       << "), max_depth = " << max_depth << "\n";

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

const int MandelbrotImage::RESOLUTION_FACTOR_3D = 3;  // Chosen imperically as an integer. Could scrutinize.
const MandelbrotImage::coord_t MandelbrotImage::SCALE_PER_DEPTH = 0.84L;
const MandelbrotImage::coord_t MandelbrotImage::EYE_DEPTH_FIT = 30.0L;
const MandelbrotImage::coord_t MandelbrotImage::NATURAL_DEPTH = 3.0L;

MandelbrotImage *MandelbrotImage::make3d() {
  startTimer();
  // The 3D "Structure":
  // ------------------
  // A 3D "structure" is defined based on the 2D Mandelbrot where there is an
  // infinite planar x/y surface at each depth with a cut-out hole as defined in the Mandelbrot
  // image. The depth-0 surface has a cut-out for the Mandelbrot depth-0 circle, and so on. X/y
  // and h/w coordinates in the 3D structure are as in the 2D image and are uniform at each depth. The
  // separation between each plane is scaled by a scaling factor SCALE_PER_DEPTH (< 1.0) from
  // the previous. This keeps plane separation on par with feature size which shrinks with each
  // depth. This scaling factor is determined empirically. The perceived image will scale in depth
  // proportional to the distance of the eye from the screen. So, there are no absolute coordinates
  // for the Z dimension (depth), but rather a fixed number of depths from the eye to the screen.
  //
  // Exploration:
  // -----------
  // To explore the intricacies of the 3D structure, we zoom into, or scale, the 3D surface as
  // with the 2D surface based on the provided pix_[x/y]. As the structure scales, it moves closer to the eye such
  // that the separation between depths remains constant relative to the eye. So, with each
  // 1/SCALE_PER_DEPTH of scaling, the eye moves inward one depth, and the structure grows by
  // 1/SCALE_PER_DEPTH. So, pixel size determines both the structure size and the depth of the eye.
  //
  // Image Generation:
  // ----------------
  // To generate the 3D image, we first generate the 2D image (as a depth array). This defines the
  // cut-outs at each depth. (The cut-out for depth n is where the depth in the depth array > n.)
  // We then ray-trace each pixel of the 3D image through the cut-outs at each depth beyond the eye until
  // a depth is reached where the ray point is not in the cut-out. NATURAL_DEPTH is a scaling
  // factor for the generated image/surface. It specifies the depth at which the 2D image is
  // scaled 1:1 with the 3D image. Since a ray can contact outside the requested 2D image, we
  // generate a larger 2D image than requested. The image must be large enough for the projection
  // of the natural image onto the worst-case maximum depth plane. This is not computed; we
  // use a hardcoded constant, RESOLUTION_FACTOR_3D. Eye depth is used to determine where
  // darkening begins if darkening is enabled. Adjustments to SCALE_PER_DEPTH, eye depth, and
  // darkening constant could be provided as user inputs, but currently are not. The shape of
  // each plane is given by the depth data array of the Mandelbrot set already computed.
  
  // Assumptions:
  //   o pix_x/pix_y reflect a whole number of depths of zoom.
  
  //-coord_t center_x = getCenterX();
  //-coord_t center_y = getCenterY();
  coord_t center_w_2d = (coord_t)center_w;
  coord_t center_h_2d = (coord_t)center_h;
  // Revert image scaling to get 3D image size back to the size requested.
  int width_3d = width / RESOLUTION_FACTOR_3D;
  int height_3d = height / RESOLUTION_FACTOR_3D;
  coord_t center_w_3d = center_w / RESOLUTION_FACTOR_3D;
  coord_t center_h_3d = center_h / RESOLUTION_FACTOR_3D;
  
  int *depth_array_3d = (int *)malloc(width_3d * height_3d * sizeof(int));
  
  //-coord_t img_size_y = pix_y * height;
  coord_t pix_y_fit = 4.0L / (coord_t)height;  // Pixel size at which plane-0 (the circle) is fit to the image.
  coord_t zoom_depth = log(SCALE_PER_DEPTH, pix_y / pix_y_fit);  // Number of depths zoomed from fit, where the eye remains a constant number of depths from the image.
  coord_t eye_depth = zoom_depth - EYE_DEPTH_FIT;
  cout << "Eye depth: " << eye_depth << endl;
  
  // Iterate the depths in front of the eye, so begin with the first depth plane in front of the eye.
  int first_depth = ((int)(eye_depth + 1000.0L + 0.01L)) - 1000 + 1;
     // Round up (+1000.0 used to operate on positive value; +0.01 to avoid depth w/ infinite pix_x/y; +1 to round up, not down).
  //-// Initialize depth_pix_x/y for the first depth.
  //-coord_t tmp = pow(1.0 / SCALE_PER_DEPTH, zoom_depth - first_depth);
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
        coord_t multiplier_3d_to_2d = dist_from_eye / NATURAL_DEPTH;
        
        int w_2d = round(center_w_2d + w_from_center_3d * multiplier_3d_to_2d);
        int h_2d = round(center_h_2d + h_from_center_3d * multiplier_3d_to_2d);
        if (w_2d < 0 || w_2d >= width ||
            h_2d < 0 || h_2d >= height) {
          // Outside the 2d image. Make everything solid starting w/ depth 0.
          done = depth >= 0;
        } else {
          done = depth_array[h_2d * width + w_2d] <= depth;
        }
        
        // Next
        depth++;
        depth_from_eye++;
        depth_separation *= SCALE_PER_DEPTH;
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
  // Upper-left x/y:
  coord_t ul_x = x - center_w * pix_x;
  coord_t ul_y = y - center_h * pix_y;
  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
      coord_t xx = ul_x + pix_x * w;
      coord_t yy = ul_y + pix_y * h;
      
      int iteration = 0;
      if (false) {
        // For debug:
        // This generates a square at depth 0.
        iteration = (xx < 0.3 && xx > -0.3 &&
                     yy < 0.3 && yy > -0.3) ? 0 : max_depth;
      } else {
        // Mandelbrot pixel calc.
        coord_t x0 = xx;
        coord_t y0 = yy;
        coord_t dist_sq;
        while ((dist_sq = xx*xx + yy*yy) < 2*2 && iteration < max_depth) {
          coord_t xtemp = xx*xx - yy*yy + x0 + adjustment * dist_sq;
          yy = 2*xx*yy + y0 - adjustment * dist_sq;
          xx = xtemp;
          iteration += 1;
        }
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
  if (pixel_data != NULL) {
    cerr << "Error (mandelbrot.c): Pixels generated multiple times.\n";
  }
  
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
  color_t * color_scheme = getColorScheme();
  int color_scheme_size = getColorSchemeSize();
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
int MandelbrotImage::num_color_schemes = -1;
int * MandelbrotImage::color_scheme_size = NULL;
MandelbrotImage::color_t ** MandelbrotImage::color_scheme = NULL;
