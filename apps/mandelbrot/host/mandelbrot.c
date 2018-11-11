#include <math.h>
#include <cstdlib>
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
    //MandelbrotImage::color_scheme[2] = allocGradientsColorScheme(MandelbrotImage::color_scheme_size[2], 8, 64);
    MandelbrotImage::color_scheme[2] = allocGradientDiagonalColorScheme(MandelbrotImage::color_scheme_size[2], 5);
    static_init_done = true;
  }
  
  enableTimer(1);
  
  depth_array = right_depth_array = NULL;
  pixel_data = NULL;
  png = NULL;
  req_width = req_height = 0;
  calc_width = calc_height = 0;
  x = y = pix_x = pix_y = (coord_t)0.0L;
  is_3d = (params[9] > 0.0L);
  brighten = (int)(params[13]);
  eye_adjust = params[14];
  eye_separation = params[15];
  adjustment = params[7] / 100.0L;
  adjustment2 = params[8] / 100.0L;
  
  // For darkening distant 3D depths.
  darken = (params[12] > 0.0L);
  half_faded_depth = 30;
  
  auto_dive = true;
  auto_darken = true;
  
  assert(! IS_BIG_ENDIAN);

  setColorScheme(is_3d ? 1 : 2);
  
  x = (coord_t)params[0];
  y = (coord_t)params[1];
  pix_x = (coord_t)params[2];
  pix_y = (coord_t)params[3];
  req_width  = (int)params[4];
  req_height = (int)params[5];
  calc_width  = req_width;   // assuming not 3d
  calc_height = req_height;  // "
  max_depth = (int)params[6];
  req_eye_offset = (int)(params[10]);
  is_stereo = is_3d && eye_separation > 0;
  req_center_w = req_width  >> 1;  // (adjusted by req_eye_offset for stereo 3D)
  req_center_h = req_height >> 1;
  
  if (is_3d) {
    // For 3D images, we compute larger h/w images for greater resolution of the 1x 3D image.
    calc_width  = (req_width + eye_separation) * RESOLUTION_FACTOR_3D;
    calc_height = req_height * RESOLUTION_FACTOR_3D;
  }
  calc_center_w = (calc_width  >> 1);
  calc_center_h = (calc_height >> 1);
  cout << "New image: center coords = (" << x << ", " << y << "), pix_size = (" << pix_x << ", " << pix_y
       << ")" /* << ", calc_img_size = (" << calc_width << ", " << calc_height << "), calc_center = (" << calc_center_w << ", " << calc_center_h
       << "), max_depth = " << max_depth */ << ". ";
};
 
MandelbrotImage::~MandelbrotImage() {
  if (depth_array != NULL) {
    free(depth_array);
  }
  if (right_depth_array != NULL) {
    free(right_depth_array);
  }
  if (pixel_data != NULL) {
    free(pixel_data);
  }
  if (png != NULL) {
    free(png);
  }
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


/*
coord_t MandelbrotImage::getCenterX() {
  return x + pix_x * calc_width / 2.0;
};

coord_t MandelbrotImage::getCenterY() {
  return y + pix_y * calc_height / 2.0;
};
*/

// Number of depths zoomed from fit depth.
MandelbrotImage::coord_t MandelbrotImage::getZoomDepth() {
  coord_t pix_y_fit = 4.0L / (coord_t)req_height;  // Pixel size at which plane-0 (the circle) is fit to the image.
  coord_t zoom = pix_y / pix_y_fit;
  cout << "{Zoom info: " << pix_y_fit << ", " << zoom << "}. ";
  return log(SCALE_PER_DEPTH, zoom);
}

const int MandelbrotImage::RESOLUTION_FACTOR_3D = 3;  // TODO: Chosen empirically as an integer. It should be: distance from eye to most-distant visible depth / distance from eye to screen (and should be float).
const MandelbrotImage::coord_t MandelbrotImage::SCALE_PER_DEPTH = 0.84L;
const MandelbrotImage::coord_t MandelbrotImage::EYE_DEPTH_FIT = 30.0L;
const MandelbrotImage::coord_t MandelbrotImage::NATURAL_DEPTH = 3.0L;

int * MandelbrotImage::makeEye(bool right) {
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
  //   o pix_x/pix_y reflect a whole number of depths of zoom. (TODO: Not currently the case, but it looks okay anyway.)
  int direction = right ? -1 : 1;  // Invert calculations for the right eye.
  coord_t center_w_2d = (coord_t)(calc_center_w - direction * (eye_separation >> 1));  // Center is where the eye is.
  coord_t center_h_2d = (coord_t)calc_center_h;
  coord_t center_w_3d = (coord_t)req_center_w + direction * req_eye_offset;
  coord_t center_h_3d = (coord_t)req_center_h;
  
  int *depth_array_3d = (int *)malloc(req_width * req_height * sizeof(int));
  
  coord_t eye_depth = - EYE_DEPTH_FIT - eye_adjust + (auto_dive ? (coord_t)auto_depth : getZoomDepth());
  cout << "Eye depth: " << eye_depth << ". ";
  
  // Iterate the depths in front of the eye, so begin with the first depth plane in front of the eye.
  int first_depth = ((int)(eye_depth + 1000.0L + 0.01L)) - 1000 + 1;
     // Round up (+1000.0 used to ensure positive value for (int); +0.01 to avoid depth w/ infinite pix_x/y; +1 to round up, not down).
  
  for (int h_3d = 0; h_3d < req_height; h_3d++) {
    coord_t h_from_center_3d = (coord_t)h_3d - center_h_3d;
    for (int w_3d = 0; w_3d < req_width; w_3d++) {
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
        if (w_2d < 0 || w_2d >= calc_width ||
            h_2d < 0 || h_2d >= calc_height) {
          // Outside the 2d image. Make everything solid starting w/ depth 0.
          done = depth >= 0;
          if (done) {cout << "(" << depth << ": " << w_2d << ", " << h_2d << "). ";}
        } else {
          done = depth_array[h_2d * calc_width + w_2d] <= depth;
        }
        
        // Next
        depth++;
        depth_from_eye++;
        depth_separation *= SCALE_PER_DEPTH;
        dist_from_eye += depth_separation;
      }
      depth_array_3d[h_3d * req_width + w_3d] = depth;
    }
  }
  return depth_array_3d;
}

MandelbrotImage * MandelbrotImage::make3d() {
  startTimer();

  // Compute new 3D-iffied depth array(s) from depth_array.
  int * depth_array_3d = makeEye(false);
  if (is_stereo) {
    right_depth_array = makeEye(true);  // (freed upon destruction)
  }
  
  // Replace depth_array w/ 3d depth array.
  free(depth_array);
  depth_array = depth_array_3d;

  stopTimer("make3d()");
  
  return this;
};

inline int MandelbrotImage::pixelDepth(int h, int w, bool adjust, bool need_derivatives) {
  coord_t scaled_adjustment  = adjustment  * (req_width + req_height) * pix_x * 0.03;
  coord_t scaled_adjustment2 = adjustment2 * (req_width + req_height) * pix_x * 0.03;

  coord_t xx = x + (w - calc_center_w) * pix_x;
  coord_t yy = y + (h - calc_center_h) * pix_y;
  
  // These track the impact of a delta_x/y applied to layer 0 on subsequent depths.
  // This has a few uses:
  //  - Adjustments: It is used for applying x/y adjustments, where the adjustment is applied beginning at a (non-discrete) depth
  //    near the eye. Applying x/y adjustments as x0/y0 adjustments avoids a "heartbeat" with each depth, where the deltas
  //    applied change for each level.
  //  - Optimization: Knowledge of the sensitivity of x & y to changes may be used to guide an optimized algorithm
  //    to know when finer granularity calculations are needed. There's a writeup here:
  //    https://docs.google.com/document/d/1K0gPk9uK7av3IdA827IM3OaHT1pDNHdVi7VGKfMQwHc/edit?usp=sharing
  //    We implement an easier optimization: When we diverge, we use this to estimate how many pixels to the right also reach and
  //    diverged at this level or are max-depth and do not diverge.
  //  - Auto darkening: This provides a reasonable indication of level of detail. Darkening is applied after this process,
  //    so we can auto-generate a darkening depth through this process.
  coord_t dxx_dx0 = 0.0L;
  coord_t dxx_dy0 = 0.0L;
  coord_t dyy_dx0 = 0.0L;
  coord_t dyy_dy0 = 0.0L;
  coord_t next_dxx_dx0 = 0.0L;
  coord_t next_dxx_dy0 = 0.0L;
  coord_t next_dyy_dx0 = 0.0L;
  coord_t next_dyy_dy0 = 0.0L;
  
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
    while ((//(
             (dist_sq = xx*xx + yy*yy) < 2*2
            //) ^
            //(//((xx - floor(xx) < 0.05 || ceil(xx) - xx < 0.05) ||
             // (yy - floor(yy) < 0.05 || ceil(yy) - yy < 0.05)
             //) &&
             //(((xx > 0.0) ^ (yy > 0.0)) &&
             // ((((int)(xx * 4.0) + 1000) % 2 == 0) ^
             //  (((int)(yy * 4.0) + 1000) % 2 == 0)
             // ) &&
             // (iteration > (int)getZoomDepth() - (int)eye_adjust + brighten && iteration < (int)getZoomDepth() - (int)eye_adjust + brighten + 3)
             //)
            //)
           ) && iteration < max_depth
          ) {
            
      // Calculate adjustments
      
      // Delta sensitivity (x/y dirivatives w.r.t. top-level).
      if (need_derivatives) {
        // (These assume un-adjusted Mandelbrot equations.)
        next_dxx_dx0 = 2.0L * (xx * dxx_dx0 - yy * dyy_dx0) + 1.0L;
        next_dxx_dy0 = 2.0L * (xx * dxx_dy0 - yy * dyy_dy0);
        next_dyy_dx0 = 2.0L * (xx * dyy_dx0 + yy * dxx_dx0);
        next_dyy_dy0 = 2.0L * (xx * dyy_dy0 + yy * dxx_dy0) + 1.0L;
      }
      
      coord_t xtemp = xx*xx - yy*yy + x0;
      /*
      coord_t adj = adjustment;
      int int_adjust_depth = (int)(adjust_depth + 1000.0L) - 1000 + 1;  // +1000,-1000 to keep (int) operating on positive number. +1 to round up.
      if (adjust && (iteration >= int_adjust_depth)) {
        if (iteration == int_adjust_depth) {
          // prorate adj.
          coord_t prorate_factor = (coord_t)iteration - adjust_depth;
          adj *= prorate_factor;
        }
        xtemp += adj / 2.0L; //  (((coord_t)iteration - adjust_depth) / 200.0L);
      }
      */
      yy = 2*xx*yy + y0;
      xx = xtemp;
      if (adjust) {
        yy += scaled_adjustment  * next_dxx_dx0;
        xx += scaled_adjustment2 * next_dyy_dy0;
      }
      if (need_derivatives) {
        dxx_dx0 = next_dxx_dx0;
        dxx_dy0 = next_dxx_dy0;
        dyy_dx0 = next_dyy_dx0;
        dyy_dy0 = next_dyy_dy0;
      }
      iteration += 1;
    }
  }
  
  // Darken heuristic
  // If this pixel is within the rectangle used to determine auto-depth, see if we found the lowest depth yet, and if
  // we did, update max_depth to reflect it to save time in the future.
  if (iteration < auto_depth &&
      (abs(w - calc_center_w) <= auto_depth_w) &&
      (abs(h - calc_center_h) <= auto_depth_h)
     ) {
    updateMaxDepth(iteration);
  }
  return iteration;
}

int MandelbrotImage::tryPixelDepth(int h, int w, bool adjust, bool need_derivatives) {
  return pixelDepth(h, w, adjust, need_derivatives);
}

MandelbrotImage *MandelbrotImage::generateDepthArray() {
    
  startTimer();
  
  // Fill depth_array with depth for each pixel.
  
  bool adjust = adjustment != 0.0L || adjustment2 != 0.0;
  coord_t adjust_depth = 0.0L;
  if (adjustment != 0.0L) {
    // Matched to eye depth.
    adjust_depth = start_darkening_depth;  // Begin adjustment where we begin darkening (both should be around first visible level) //- getZoomDepth() - EYE_DEPTH_FIT - eye_adjust;
  }
  cout << "adjust_depth: " << adjust_depth << ", adjustment: " << adjustment << ". ";
  
  depth_array = (int *)malloc(calc_width * calc_height * sizeof(int));
  auto_depth = max_depth;  // Current heuristic is to use the minimum depth within a 2/3-w/h rectangle around the center.

  bool need_derivatives = adjust;  
  
  // Since auto_depth can be used to determine darkening which determines max_depth, we don't know max_depth
  // before we need it. To address this, we determine an initial conservative value for auto_depth to use here
  // by trying the four corners of the rectangle within which we look for depth. Likely these will find the
  // least depth. If not, we waste some time. Depth array may fill with values > max_depth. Max depth is updated
  // as each pixel is processed.
  // Use a different auto-depth for different modes:
  //   2-D: Auto-depth (darkening) at depth that touches 2/3-scaled requested rectangle.
  //   3-D: Auto-depth (darkening and screen depth) at depth that touches 3/4-scaled requested rectangle.
  //   Stereo 3-D: Auto-depth (darkening) and screen depth) at depth touching rectangle between eyes in width and 3/4 requested height.
  auto_depth_w = is_stereo ? eye_separation / 2 :  // Align the eye with auto-depth (screen depth)
                 is_3d     ? (req_width * 3 / 4) / 2 :  // 3/4-scaled center rectangle touches auto-depth (screen depth)
                             (req_width * 2 / 3) / 2;   // 2/3-scaled center rectangle touches auto-depth. 
  auto_depth_h = is_stereo ? (req_height * 3 / 4) / 2 :
                 is_3d     ? (req_height * 3 / 4) / 2 :
                             (req_height * 2 / 3) / 2;
  if (false && auto_darken) {
    tryPixelDepth(req_center_w - auto_depth_w, req_center_h - auto_depth_h, adjust, need_derivatives);
    tryPixelDepth(req_center_w + auto_depth_w, req_center_h - auto_depth_h, adjust, need_derivatives);
    tryPixelDepth(req_center_w - auto_depth_w, req_center_h + auto_depth_h, adjust, need_derivatives);
    tryPixelDepth(req_center_w + auto_depth_w, req_center_h + auto_depth_h, adjust, need_derivatives);
  }
   
  for (int h = 0; h < calc_height; h++) {
    for (int w = 0; w < calc_width; w++) {
      depth_array[h * calc_width + w] = pixelDepth(h, w, adjust, need_derivatives);;
    }
  }
  
  cout << ", auto_depth: " << auto_depth << ", brighten: " << brighten << ". ";
  
  stopTimer("generateDepthArray()");

  return this;
}

// Set max_depth based on darkening. This must be called multiple times because auto_darken is determined
// dynamically during depth array generation. We conservatively estimate first, then correct if necessary.
// Optionally pass a new value for auto_depth to apply if less than the current value.
void MandelbrotImage::updateMaxDepth(int new_auto_depth) {
  if (new_auto_depth < auto_depth) { 
    //if (new_auto_depth != INT_MIN) {
      auto_depth = new_auto_depth;
    //}
    start_darkening_depth = (auto_darken ? (coord_t)auto_depth : getZoomDepth()) - eye_adjust - (coord_t)brighten;
    if (darken) {
      int dark_depth = (int)start_darkening_depth + half_faded_depth * 6; // Light fades exponentially w/ depth. After 6 half_faded_depth's, brightness is 1/32.
      if (max_depth > dark_depth) {
        max_depth = dark_depth;
      }
    }
  }
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
  
  // TODO: Optimization: Currently for 3-D we generate two images independently, but we could generate a single
  //       DepthArray, and 3-D-ify it twice.
  if (is_3d) {
    make3d();
  }
  
  startTimer();

  //updateMaxDepth();
  cout << "start_darkening_depth: " << start_darkening_depth << ", zoom_depth: " << getZoomDepth() << ", max_depth: " << max_depth << ". ";
  
  /*
  // To avoid byte writes, we pack bytes.
  ...
  int byte_ind = 0;
  int int_data;
  int int_bytes;
  for (int h = 0; h < height; h++) {
    // Handle left-over bytes.
    for (int w = 0; w < calc_width && byte_ind < sizeof(int); w++, byte_ind++) {
      int_data &= 
    }
    for (int w = --; w < calc_width; w++) {
      if (by)
    }
  }
  */
  int chars_per_image = req_width * req_height * 3;
  pixel_data = (unsigned char *) malloc(chars_per_image * (is_stereo ? 2 : 1));
  toPixelData(pixel_data, depth_array, getColorScheme(), getColorSchemeSize());
  if (is_stereo) {
    toPixelData(pixel_data + sizeof(char) * chars_per_image, right_depth_array, getColorScheme(), getColorSchemeSize());
  }

  stopTimer("generatePixels()");
  
  cout << endl;
  
  return this;
};

void MandelbrotImage::toPixelData(unsigned char *pixel_data, int *depth_array, color_t * color_scheme, int color_scheme_size) {
  
  int j = 0;

  // Building the image pixels data
  for(int i = 0; i < req_width * req_height * 3; i+=3) {
    int depth = depth_array[j];
    float brightness;
    bool shadow = darken && depth > (int)start_darkening_depth;
    if (shadow) {
      brightness = 1.0L / (1.0L + ((coord_t)depth - start_darkening_depth) / (coord_t)half_faded_depth);
    }
    for(int k = 0; k < 3; k++) {
      if (depth >= max_depth) {  // > is a necessary check because we sometimes dynamically determine max_depth based on auto_depth and look too far before we know better.
        pixel_data[i + k] = 0;
      } else {
        pixel_data[i + k] = color_scheme[depth % color_scheme_size].component[k];
        if (shadow) {
          pixel_data[i + k] = (int)(((float)pixel_data[i + k]) * brightness);
        }
      }
    }
    
    j++;
  }
}

unsigned char *MandelbrotImage::generatePNG(size_t *png_size_p) {
  if (png != NULL) {
    cerr << "Error (mandelbrot.c): PNG generated multiple times.\n";
  }
  if (pixel_data == NULL) {
    generatePixels();
  }
  
  startTimer();
  
  // Generate the png image
  unsigned error = lodepng_encode24(&png, png_size_p, pixel_data, req_width, req_height * (is_stereo ? 2 : 1));
  if(error) perror("Error in generating png");

  stopTimer("generatePNG()");
  return png;
};


/*
**
** Funcitons that return a color scheme as an array of &size colors.
**
*/

// Take a color scheme that is 1/3 populated and complete it by repeating the partial color scheme three times
// RGB-shifted each time. The scheme must have been allocated to a size of partial_size * 3.
void MandelbrotImage::completeRGBShiftedColorScheme(MandelbrotImage::color_t *partial_scheme, int partial_size) {
  for (int part = 1; part < 3; part++) {
    for (int color = part * partial_size; color < (part + 1) * partial_size; color++) {
      for (int comp = 0; comp < 3; comp++) {
        partial_scheme[color].component[comp] = partial_scheme[color % partial_size].component[(comp + part) % 3];
      }
    }
  }
}

// Allocate a color scheme that uses gradient colors around the six color cube edges connecting the non-black/white corners.
// Edges are:
//   R->Ye->G
//   B->Pu->R
//   G->Cy->B
// R,G,B points appear in the sequence twice.
MandelbrotImage::color_t * MandelbrotImage::allocGradientEdgePairColorScheme(int &size, int edge_increments) {
  int colors_per_part = edge_increments * 2 /* edges */ + 1 /* Extra fencepost-color for R,G,B corners */;
  size = colors_per_part * 3;  // 3 parts.
  color_t * color_scheme = (color_t *) malloc(sizeof(color_t) * size);
  
  // Create two edges (including three corner points).
  for (int i = 0; i < edge_increments; i++) {
    color_scheme[i].component[0] = 255;
    color_scheme[i].component[1] = i * 255 / edge_increments;
    color_scheme[i].component[2] = 0;
    color_scheme[i + edge_increments].component[0] = (edge_increments - i) * 255 / edge_increments;
    color_scheme[i + edge_increments].component[1] = 255;
    color_scheme[i + edge_increments].component[2] = 0;
  }
  color_scheme[edge_increments * 2].component[0] = 0;
  color_scheme[edge_increments * 2].component[1] = 255;
  color_scheme[edge_increments * 2].component[2] = 0;
  
  // Mimic these two edges to form the other four.
  completeRGBShiftedColorScheme(color_scheme, colors_per_part);
  //-for (int j = 0; j < size; j++) {
  //-  color_scheme[j].component[2] = (j % 4) * 64 + 32;
  //-}
  
  return color_scheme;
}

// Allocate a color scheme that uses gradient colors along six surface diagonals of the cube edges connecting the non-black/white corners.
// Edges are:
//   Pu->Ye
//   B->R
//   Cy->Pu
//   G->B
//   Ye->Cy
//   R->G
// Corner points appear in the sequence twice.
MandelbrotImage::color_t * MandelbrotImage::allocGradientDiagonalColorScheme(int &size, int increments) {
  int colors_per_part = increments + 1 /* Extra for fenceposting corner-to-corner */;
  size = colors_per_part * 6;  // 6 diagonals.
  color_t * color_scheme = (color_t *) malloc(sizeof(color_t) * size);
  
  // Create two diagonals.
  for (int i = 0; i < colors_per_part; i++) {
    int going_up = i * 255 / increments;
    int going_down = (increments - i) * 255 / increments;
    color_scheme[i].component[0] = 255;
    color_scheme[i].component[1] = going_up;
    color_scheme[i].component[2] = going_down;
    color_scheme[i + colors_per_part].component[0] = going_up;
    color_scheme[i + colors_per_part].component[1] = 0;
    color_scheme[i + colors_per_part].component[2] = going_down;
  }
  
  // Mimic these two edges to form the other four.
  completeRGBShiftedColorScheme(color_scheme, colors_per_part * 2);
  
  return color_scheme;
}

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
  if (timer_level) {
    clock_gettime(CLOCK_MONOTONIC_RAW, &timer_start_time);
  }
}
timespec MandelbrotImage::stopTimer(string tag) {
  timespec end;
  if (timer_level) {
    uint64_t delta_us;
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    delta_us = (end.tv_sec - timer_start_time.tv_sec) * 1000000 + (end.tv_nsec - timer_start_time.tv_nsec) / 1000;
    cout << "Execution time of " << tag << ": " << delta_us << " [us]\n";
  }
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
