#include <math.h>
#include <cstdlib>
#include "mandelbrot.h"

using namespace std;

#define IS_BIG_ENDIAN (*(uint16_t *)"\0\xff" < 0x100)

const int MandelbrotImage::VERBOSITY = 0;

MandelbrotImage::MandelbrotImage(double *params, bool fpga) {
  // "Static" init (hack).
  if (!static_init_done) {
    // Allocate color schemes (never deallocated).
    MandelbrotImage::num_color_schemes = 3;
    MandelbrotImage::color_scheme_size = (int *) malloc(sizeof(int) * MandelbrotImage::num_color_schemes);
    MandelbrotImage::color_scheme = (color_t **) malloc(sizeof(color_t *) * MandelbrotImage::num_color_schemes);
    MandelbrotImage::color_scheme[0] = allocGradientsColorScheme(MandelbrotImage::color_scheme_size[0], 8, 64);
    MandelbrotImage::color_scheme[1] = allocRandomColorScheme(MandelbrotImage::color_scheme_size[1], 32);
    //MandelbrotImage::color_scheme[2] = allocGradientsColorScheme(MandelbrotImage::color_scheme_size[2], 8, 64);
    MandelbrotImage::color_scheme[2] = allocGradientDiagonalColorScheme(MandelbrotImage::color_scheme_size[2], 5);
    static_init_done = true;
  }
  
  enableTimer(0);
  
    
  depth_array = right_depth_array = NULL;
  fractional_depth_array = right_fractional_depth_array = NULL;
  pixel_data = NULL;
  png = NULL;
  req_width = req_height = 0;
  calc_width = calc_height = 0;
  x = y = pix_x = pix_y = (coord_t)0.0L;
  is_3d = (params[9] > 0.0L);
  int modes = (int)(params[16]);  // Bits, lsb first: 0: python(irrelevant here), 1: C++, 2: reserved, 3: optimize1, 4-5: reserved, 6: full-image, ...
  enable_step = ((modes >> 3) & 1) && !fpga;
  full_image = (modes >> 6) & 1;
  smooth = ((modes >> 7) & 1) && !fpga;
  if (smooth) {enable_step = false;}  // Need to compute every pixel for smoothing.
  //+int color_scheme = (int)(params[17]);
  spot_depth = (int)(params[18]);
  show_spot = spot_depth >= 0;
  brighten = (int)(params[13]);
  eye_adjust = params[14];
  eye_separation = params[15];
  adjustment = params[7] / 100.0L;
  adjustment2 = params[8] / 100.0L;
  adjust = (adjustment != 0.0L || adjustment2 != 0.0L) && !fpga;
  need_derivatives = adjust || enable_step;
  
  // For darkening distant 3D depths.
  darken = (params[12] > 0.0L);
  half_faded_depth = 30;
  
  auto_dive = full_image;  // (Relevant for 3D/Stereo-3D.)
  auto_darken = full_image;
  
  assert(! IS_BIG_ENDIAN);

  setColorScheme(is_3d ? 1 : 2);
  
  x = (coord_t)params[0];
  y = (coord_t)params[1];
  pix_x = (coord_t)params[2];
  pix_y = (coord_t)params[3];
  req_width  = (int)params[4];
  req_height = (int)params[5];
  calc_width  = req_width;   // assuming not 3d and not limited by FPGA restrictions
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
  if (VERBOSITY)
    cout << "New image: center coords = (" << x << ", " << y << "), pix_size = (" << pix_x << ", " << pix_y
         << ")" /* << ", calc_img_size = (" << calc_width << ", " << calc_height << "), calc_center = (" << calc_center_w << ", " << calc_center_h
         << "), max_depth = " << max_depth */ << ", modes = " << modes << ", full = " << full_image << ". ";
  
  
  // TODO: I think there's currently a limitation that width must be a multiple of 16 for the FPGA.
  if (fpga) {
    int multiple = 16;
    calc_width = (calc_width + multiple - 1) / multiple * multiple;  // Round up to nearest 16.
  }

};
 
MandelbrotImage::~MandelbrotImage() {
  if (depth_array != NULL) {
    free(depth_array);
  }
  if (right_depth_array != NULL) {
    free(right_depth_array);
  }
  if (fractional_depth_array != NULL) {
    free(fractional_depth_array);
  }
  if (right_fractional_depth_array != NULL) {
    free(right_fractional_depth_array);
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
  if (VERBOSITY)
    cout << "{Zoom info: " << pix_y_fit << ", " << zoom << "}. ";
    return log(SCALE_PER_DEPTH, zoom);
}

const int MandelbrotImage::RESOLUTION_FACTOR_3D = 2;  // TODO: Chosen empirically as an integer. It should be: distance from eye to most-distant visible depth / distance from eye to screen (and should be float).
const MandelbrotImage::coord_t MandelbrotImage::SCALE_PER_DEPTH = 0.9L;
const MandelbrotImage::coord_t MandelbrotImage::EYE_DEPTH_FIT = 10.0L;
const MandelbrotImage::coord_t MandelbrotImage::NATURAL_DEPTH = 5.0L;

int * MandelbrotImage::makeEye(bool right, unsigned char * &fractional_depth_array_3d) {
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
  // with the 2D surface based on two techniques.
  //   o One is purely based on the provided pix_[x/y]. As the structure scales, it moves closer to the eye such
  //     that the separation between depths remains constant relative to the eye. So, with each
  //     1/SCALE_PER_DEPTH of scaling, the eye moves inward one depth, and the structure grows by
  //     1/SCALE_PER_DEPTH. So, pixel size determines both the structure size and the depth of the eye.
  //   o The other is determined dynamically, based on the image. This is only possible if the full image
  //     is created (not tiled). The minimum depth found within a given region of the image, is positioned
  //     at a given distance from the eye.
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
  if (smooth) {
    fractional_depth_array_3d = (unsigned char *)malloc(req_width * req_height * sizeof(unsigned char *));
  }
  
  // Iterate the depths in front of the eye, so begin with the first depth plane in front of the eye.
  int first_depth = ((int)(eye_depth + 1000.0L + 0.01L)) - 1000 + 1;
     // Round up (+1000.0 used to ensure positive value for (int); +0.01 to avoid depth w/ infinite pix_x/y; +1 to round up, not down).
  
  coord_t max_multiplier = 0.0;
  for (int h_3d = 0; h_3d < req_height; h_3d++) {
    coord_t h_from_center_3d = (coord_t)h_3d - center_h_3d;
    for (int w_3d = 0; w_3d < req_width; w_3d++) {
      coord_t w_from_center_3d = (coord_t)w_3d - center_w_3d;
      //int depth_from_eye = 1;
      int depth = first_depth;
      int w_2d = 0; int h_2d = 0;
      coord_t depth_separation = 1.0L; // Absolute separation between subsequent depths.
      coord_t dist_from_eye = depth_separation; // Absolute distance from eye in units of first-depth-distance.
      while (depth < max_depth) {
        coord_t multiplier_3d_to_2d = dist_from_eye / NATURAL_DEPTH;
        // Check that multiplier doesn't exceed RESOLUTION_FACTOR_3D.
        if (depth == max_depth - 1) {
          if (max_multiplier < multiplier_3d_to_2d) {
            max_multiplier = multiplier_3d_to_2d;
          }
        }
        
        w_2d = round(center_w_2d + w_from_center_3d * multiplier_3d_to_2d);
        h_2d = round(center_h_2d + h_from_center_3d * multiplier_3d_to_2d);
        if (w_2d < 0 || w_2d >= calc_width ||
            h_2d < 0 || h_2d >= calc_height) {
          // Outside the 2d image. Make everything solid starting w/ depth 0.
          if (depth >= 0) {
            cout << "(" << depth << ": " << w_2d << ", " << h_2d << "). ";
            break;
          }
        } else {
          // Normal case. Break if we are at depth in 2d image.
          
          // But, first handle the spot.
          if (show_spot && depth == spot_depth) {
            int spot_w = w_2d - calc_center_w;
            int spot_h = h_2d - calc_center_h;
            if (spot_w * spot_w + spot_h * spot_h < calc_height * calc_height / 900) {
              depth = -1;  // Used to signify spot.
              break;
            }
          }
          
          // Now, break if we're at depth.
          if (depth_array[h_2d * calc_width + w_2d] <= depth) {
            break;
          }
        }
        
        // Next
        depth++;
        //depth_from_eye++;
        depth_separation *= SCALE_PER_DEPTH;
        dist_from_eye += depth_separation;
      }
      if (depth < 0) {
        // Spot.
        depth_array_3d[h_3d * req_width + w_3d] = 0;  // Use depth 0 color.
        fractional_depth_array_3d[h_3d * req_width + w_3d] = (unsigned char)0;
      } else {
        depth_array_3d[h_3d * req_width + w_3d] = depth;
        if (smooth) {
          fractional_depth_array_3d[h_3d * req_width + w_3d] =
               (depth_array[h_2d * calc_width + w_2d] < depth)
                  ? (unsigned char)0  // in the shadow of a closer layer.
                  : fractional_depth_array[h_2d * calc_width + w_2d];
        }
      }
    }
  }
  //cout << "max_multiplier: " << max_multiplier << endl;
  return depth_array_3d;
}

MandelbrotImage * MandelbrotImage::make3d() {
  startTimer();
  
  eye_depth = (auto_dive ? (coord_t)(((auto_depth << 8) + auto_depth_frac)) / 256.0L : getZoomDepth()) - EYE_DEPTH_FIT - eye_adjust;
  if (VERBOSITY)
    cout << "Eye depth: " << eye_depth << ". ";
  // Adjust spot_depth to be relative to eye.
  if (show_spot) {
    spot_depth = (int)eye_depth + NATURAL_DEPTH + spot_depth;
  }
  
  // Make the spot by changing the depth of the center circle.
  if (false && show_spot) {
    for (int h = calc_center_h - calc_height / 30; h < calc_center_h + calc_height / 30; h++) {
      for (int w = calc_center_w - calc_height / 30; w < calc_center_w + calc_height / 30; w++) {
        if (true) {
          // Inside the circle.
          int ind = h * calc_width + w;
          if (depth_array[ind] >= spot_depth) {
            depth_array[ind] = spot_depth;
            fractional_depth_array[ind] = 0;
          }
        }
      }
    }
  }

  // Compute new 3D-iffied depth array(s) from depth_array.
  unsigned char *fractional_depth_array_3d;
  int * depth_array_3d = makeEye(false, fractional_depth_array_3d);
  if (is_stereo) {
    right_depth_array = makeEye(true, right_fractional_depth_array);  // (freed upon destruction)
  }
  
  // Replace depth_array w/ 3d depth array.
  free(depth_array);
  depth_array = depth_array_3d;
  // Same for fractional_depth_array.
  if (smooth) {
    free(fractional_depth_array);
    fractional_depth_array = fractional_depth_array_3d;
  }

  stopTimer("make3d()");
  
  return this;
};

inline int MandelbrotImage::pixelDepth(int w, int h, int & step) {
  step = 1; // Just provide on pixel, unless othewise determined.
  
  coord_t scaled_adjustment  = adjustment  * (req_width + req_height) * pix_x * 0.06;
  coord_t scaled_adjustment2 = adjustment2 * (req_width + req_height) * pix_x * 0.06;

  coord_t next_xx = wToX(w);
  coord_t next_yy = hToY(h);
  coord_t xx = 0.0;
  coord_t yy = 0.0;
  
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
  coord_t next_dxx_dx0 = 1.0L;
  coord_t next_dxx_dy0 = 0.0L;
  coord_t next_dyy_dx0 = 0.0L;
  coord_t next_dyy_dy0 = 1.0L;
  
  int depth = 0;
  unsigned char frac = 0;   // Fractional depth
  bool next_diverges = true;
  if (false) {
    // For debug:
    // This generates a square at depth 0.
    depth = (next_xx < 0.3 && next_xx > -0.3 &&
             next_yy < 0.3 && next_yy > -0.3) ? 0 : max_depth;
  } else {
    // Mandelbrot pixel calc.
    coord_t x0 = next_xx;
    coord_t y0 = next_yy;
    coord_t radius = smooth ? 1024.0L : 4.0L; // (< 2 * 2) TODO: this can be increased (exponentially); put a knob to it.
    do {
      next_diverges = (next_xx * next_xx + next_yy * next_yy) > radius;

      if (//(
            next_diverges
            //) ^
            //(//((xx - floor(xx) < 0.05 || ceil(xx) - xx < 0.05) ||
             // (yy - floor(yy) < 0.05 || ceil(yy) - yy < 0.05)
             //) &&
             //(((xx > 0.0) ^ (yy > 0.0)) &&
             // ((((int)(xx * 4.0) + 1000) % 2 == 0) ^
             //  (((int)(yy * 4.0) + 1000) % 2 == 0)
             // ) &&
             // (depth > (int)getZoomDepth() - (int)eye_adjust + brighten && depth < (int)getZoomDepth() - (int)eye_adjust + brighten + 3)
             //)
            //)
           || depth >= max_depth) {break;}
            

      // Update to next
      //
      
      yy = next_yy;
      xx = next_xx;
      if (need_derivatives) {
        // Update derivatives based on last depth.
        dxx_dx0 = next_dxx_dx0;
        dxx_dy0 = next_dxx_dy0;
        dyy_dx0 = next_dyy_dx0;
        dyy_dy0 = next_dyy_dy0;
      }
      
      depth += 1;
      
      
      // Delta sensitivity (x/y dirivatives w.r.t. top-level).
      if (need_derivatives) {
        // Derivatives for this depth.
        // (These assume un-adjusted Mandelbrot equations.)
        next_dxx_dx0 = 2.0L * (xx * dxx_dx0 - yy * dyy_dx0) + 1.0L;
        next_dxx_dy0 = 2.0L * (xx * dxx_dy0 - yy * dyy_dy0);
        next_dyy_dx0 = 2.0L * (xx * dyy_dx0 + yy * dxx_dx0);
        next_dyy_dy0 = 2.0L * (xx * dyy_dy0 + yy * dxx_dy0) + 1.0L;
      }
      
      // Mandelbrot equations:
      next_xx = (xx * xx) - (yy * yy) + x0;  // TODO: Optimize by calculating squares only once.
      next_yy = 2.0L * (xx * yy) + y0;
      // Apply adjustment beyond the adjust_depth, and apply fractionally within that depth.
      int int_adj_depth = (int)ceil(adjust_depth);
      if (adjust && depth >= int_adj_depth) {
        coord_t next_xx_adj = scaled_adjustment2 * next_dyy_dy0;
        coord_t next_yy_adj = scaled_adjustment  * next_dxx_dx0;
        if (depth == int_adj_depth) {
          coord_t prorate = (coord_t)depth - (coord_t)adjust_depth;
          next_xx_adj *= prorate;
          next_yy_adj *= prorate;
        }
        next_xx += next_xx_adj;
        next_yy += next_yy_adj;
      }
      /*
      coord_t adj = adjustment;
      int int_adjust_depth = (int)(adjust_depth + 1000.0L) - 1000 + 1;  // +1000,-1000 to keep (int) operating on positive number. +1 to round up.
      if (adjust && (depth >= int_adjust_depth)) {
        if (depth == int_adjust_depth) {
          // prorate adj.
          coord_t prorate_factor = (coord_t)depth - adjust_depth;
          adj *= prorate_factor;
        }
        xtemp += adj / 2.0L; //  (((coord_t)depth - adjust_depth) / 200.0L);
      }
      */
    } while (true);
    
    // Done pixel.
    // next_* reflect divergent level. * (not next_) reflect last non-divergent level.
    
    // For smoothing, compute fractional depth. Use computation from https://en.wikipedia.org/wiki/Mandelbrot_set.
    
    if (smooth) {
      if (depth < max_depth) {
        coord_t log_zn = std::log(next_xx * next_xx + next_yy * next_yy) / 2.0L;
        coord_t log_2 = std::log(2.0L);
        coord_t nu = std::log( log_zn / log_2 ) / log_2;
        int int_frac = (int)((1.0L - nu) * 256.0L);   // 256 (byte) granularity, but this fraction can be out of range (multiple negative depths).
        // Account for depth adjustments to get frac within a depth.
        if (int_frac < 0) {
          int depth_decr = ((-int_frac + 255) >> 8);
          depth -= depth_decr;
          int_frac += depth_decr << 8;
          // but not less than depth 0.
          if (depth < 0) {
            depth = 0;
            int_frac = 0;
          }
        } else if (int_frac >= 256) {
          int depth_incr = int_frac >> 8;
          cout << "\nWARNING: Unexpected smoothing adjustment of " << depth_incr << " (frac: " << int_frac << ").\n";
          depth += depth_incr;
          int_frac -= depth_incr << 8;
        }
        frac = int_frac;  // Cast to char.
        if ((int)frac != int_frac) {
          //cout << "[" << log_zn << "](" << next_xx << ", " << next_yy << ")" << flush;
          cout << "BUG: Smoothing fraction out of range [" << log_zn << ":" << nu << "]" << flush;
          cout << "{" << depth << "+" << int_frac << "=" << (int)frac << "}" << flush;
        }
      }
      fractional_depth_array[h * calc_width + w] = frac;
    }
    
    // step
    //
    
    step = 1;
    if (enable_step && depth > 0) {
      if (next_diverges) {
        // Diverged.
        // See how many pixels ahead we can look before divergence changes.
        // First estimate when the last non-diverged level will diverge. If that was behind us, see
        // when the divergent level will no longer diverge.
        
        // Divergence value (r) is (xx*xx + yy*yy) (which is tested for < 2*2).
        // So, dr/dx0 = 2*(xx*dx/dx0 + yy*dy/dx0)
        // For non-diverged depth:
        //coord_t dr_dx0 = 2.0L * (xx * dxx_dx0 + yy * dyy_dx0);
        // For diverged depth:
        //coord_t next_dr_dx0 = 2.0L * (next_xx * next_dxx_dx0 + next_yy * next_dyy_dx0);
        //if (dr_dx0 > 0.0L) {
        //  // Diverging to the right.
          coord_t step_xx = xx;
          coord_t step_yy = yy;
          coord_t r;
          coord_t next_step_xx = next_xx;
          coord_t next_step_yy = next_yy;
          coord_t next_r;
          step = 0;
          do {
            step++;
            step_xx += dxx_dx0 * pix_x;
            step_yy += dyy_dx0 * pix_y;
            r = step_xx * step_xx + step_yy * step_yy;
            next_step_xx += next_dxx_dx0 * pix_x;
            next_step_yy += next_dyy_dx0 * pix_y;
            next_r = next_step_xx * next_step_xx + next_step_yy * next_step_yy;
          } while((r < 4.0L - step * 0.2) &&         // remain converged at depth &&
                  ((next_r > 4.0L + step * 0.2) ||   // remain diverged at next_depth
                   depth >= max_depth)               //  (which doesn't matter at max depth)
                                                     // based on constant dx/dx0 and dy/dy0 assumption
                                                     // with fudge factors that are far from perfect.
                 );
          //if (depth >= max_depth) {
          //  cout << "<" << next_r << " = " << next_step_xx << " ** 2 + " << next_step_yy << " ** 2>" << endl;
          //}
          /*
            // Last non-divergent layer will diverge to the right.
            step = 0;
            do {
              step++;
              r = 
            }
            coord_t est_divergent_delta_x0 = (4.0 - r) / dr_dx0;
            coord_t est_divergent_delta_w = est_divergent_delta_x0 / pix_x;
            // Jump 1/3 of the estimate (as a quick hack)
            step = (int)(est_divergent_delta_w / 3.0) + 1;
            // No more than 5 pixels.
            if (step > 5) {
              step = 5;
            }
          */
        //} else {
          //coord_t delta...
        //}
        //...coord_t diver
        //coord_t to_next_depth
      } else {
        // Reached max depth.
        //...
      }
    
      if (step < 1) {
        cerr << "\nERROR (mandelbrot.c): Illegal step: " << step << endl;
      }
    }

  }
  
  // Darken heuristic
  // If this pixel is within the rectangle used to determine auto-depth, see if we found the lowest depth yet, and if
  // we did, update max_depth to reflect it to save time in the future.
  if (depth <= auto_depth &&
      (abs(w - calc_center_w) <= auto_depth_w) &&
      (abs(h - calc_center_h) <= auto_depth_h)
     ) {
    updateMaxDepth(depth, frac);
  }
  return depth;
}

int MandelbrotImage::tryPixelDepth(int w, int h) {
  int step;
  return pixelDepth(w, h, step);
}

inline void MandelbrotImage::writeDepthArray(int w, int h, int depth) {
  if (w >= calc_width || h >= calc_height) {
    cerr << "\nERROR (mandelbrot.c): Outside depth array bounds" << endl;
    exit(5);
  }
  depth_array[h * calc_width + w] = depth;
}

MandelbrotImage *MandelbrotImage::generateDepthArray() {
  startTimer();
  
  // Fill depth_array with depth for each pixel.
  
  depth_array = (int *)malloc(calc_width * calc_height * sizeof(int));
  if (smooth) {
    fractional_depth_array = (unsigned char *)malloc(calc_width * calc_height * sizeof(unsigned char));
  }
  auto_depth = max_depth;  // Current heuristic is to use the minimum depth within a 2/3-w/h rectangle around the center.
  auto_depth_frac = 0;
  
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
  // Adjustment depth must be determined before determining depths. We'll determine it here based on the four corners
  // (TODO: which is less than ideal).
  // (This also sets initial start_darkening_depth.) Assumption no adjustment for this determination.
  if (auto_darken || auto_dive) {
    bool real_adjust = adjust;
    adjust = false;
    tryPixelDepth(req_center_w - auto_depth_w, req_center_h - auto_depth_h);
    tryPixelDepth(req_center_w + auto_depth_w, req_center_h - auto_depth_h);
    tryPixelDepth(req_center_w - auto_depth_w, req_center_h + auto_depth_h);
    tryPixelDepth(req_center_w + auto_depth_w, req_center_h + auto_depth_h);
    adjust = real_adjust;
  }
  
  adjust_depth = 0.0f;
  // Apply adjustments based on auto_depth, but adjustments must be applied as depths are computed, so we use this
  // initial approximation.
  if (adjust) {
    // Matched to eye depth.
    adjust_depth = start_darkening_depth;  // Begin adjustment where we begin darkening (both should be around first visible level) //- getZoomDepth() - EYE_DEPTH_FIT - eye_adjust;
  }
  if (VERBOSITY)
    cout << "adjust_depth: " << adjust_depth << ", adjustment: " << adjustment << ", smooth: " << smooth << ". " << flush;

  int num_pixels = calc_width * calc_height;
  int num_steps = 0;
  for (int h = 0; h < calc_height; h++) {
    // For remembering the step that brought us here.
    int stepped = 1;        // previous step value
    int stepped_depth = -1; // previous depth value
    for (int w = 0; w < calc_width;) {
      int step;
      int dummy_step;
      int depth;
      depth = pixelDepth(w, h, step);
      num_steps++;
      if (enable_step) {
        // While the depth isn't right, step back and re-compute.
        int step_back_depth = depth;
        for (int step_back = 1; (step_back_depth != stepped_depth) && (step_back < stepped); step_back++) {
          step_back_depth = pixelDepth(w - step_back, h, dummy_step);
          num_steps++;  // Count step-backs as steps.
          // Correct depth array.
          writeDepthArray(w - step_back, h, step_back_depth);   // Use max_depth to make step-back visible.
        };
        // Now, looking forward, don't step past last pixel. We must do this last one.
        if (w >= calc_width - 1) {
          // Last pixel in the row; single step.
          step = 1;
        } else {
          // Don't step past the last pixel.
          if (w + step >= calc_width) {
            step = calc_width - 1 - w;  // Step to last pixel.
          }
        }
      }
      // Remember what we will have stepped.
      stepped = step;
      stepped_depth = depth;
      // Fill array for this step.
      bool first = true;
      for (; step > 0; w++, step--) {
        writeDepthArray(w, h, first ? depth : depth);  // !!! first used for debug
        first = false;
      }
    }
  }
  
  if (VERBOSITY)
    cout << ", % guessed pixels: %" << (int)((coord_t)(num_pixels - num_steps) / (coord_t)num_pixels * 100.0L) << ", auto_depth: " << auto_depth << ", brighten: " << brighten << ". ";
  
  stopTimer("generateDepthArray()");

  return this;
}

// Set max_depth based on darkening. This must be called multiple times because auto_darken is determined
// dynamically during depth array generation. We conservatively estimate first, then correct if necessary.
void MandelbrotImage::updateMaxDepth(int new_auto_depth, unsigned char new_auto_depth_frac) {
  if ((new_auto_depth << 8) + new_auto_depth_frac < (auto_depth << 8) + auto_depth_frac) {
    auto_depth = new_auto_depth;
    auto_depth_frac = new_auto_depth_frac;
    start_darkening_depth = (auto_darken ? ((float)((auto_depth << 8) + (int)auto_depth_frac)) / 256.0f
                                         : getZoomDepth()) - eye_adjust - (coord_t)brighten;
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
    generateDepthArray();   // This produces more than just depth_array, and FPGA doesn't. FIXME!!!
  }
  if (pixel_data != NULL) {
    cerr << "ERROR (mandelbrot.c): Pixels generated multiple times.\n";
  }
  // TODO: Optimization: Currently for 3-D we generate two images independently, but we could generate a single
  //       DepthArray, and 3-D-ify it twice.
  if (is_3d) {
    make3d();
  }
  
  startTimer();

  if (VERBOSITY)
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
  // Generate pixel data.
  if (pixel_data == NULL) {
    int chars_per_image = req_width * req_height * 3;
    pixel_data = (unsigned char *) malloc(chars_per_image * (is_stereo ? 2 : 1));
    toPixelData(pixel_data, depth_array, fractional_depth_array, getColorScheme(), getColorSchemeSize());
    if (is_stereo) {
      toPixelData(pixel_data + sizeof(char) * chars_per_image, right_depth_array, right_fractional_depth_array, getColorScheme(), getColorSchemeSize());
    }
  }

  stopTimer("generatePixels()");
  
  if (VERBOSITY)
    cout << endl;
  
  return this;
};

void MandelbrotImage::toPixelData(unsigned char *pixel_data, int *depth_array, unsigned char *fractional_depth_array, color_t * color_scheme, int color_scheme_size) {
  
  int j = 0;

  // Building the image pixels data
  for(int i = 0; i < req_width * req_height * 3; i+=3) {
    int depth = depth_array[j];
    float smooth_depth = (float)depth + (smooth ? (float)fractional_depth_array[j] / 256.0f : 0.0f);
    float brightness;
    bool shadow = darken && smooth_depth > start_darkening_depth;
    if (shadow) {
      brightness = 1.0L / (1.0f + (smooth_depth - start_darkening_depth) / (float)half_faded_depth);
    }
    unsigned int frac = smooth ? (unsigned int)fractional_depth_array[j] : 0u;
    for(int k = 0; k < 3; k++) {
      if (depth >= max_depth) {  // > is a necessary check because we sometimes dynamically determine max_depth based on auto_depth and look too far before we know better.
        pixel_data[i + k] = 0;
      } else {
        if (smooth) {
          pixel_data[i + k] = (unsigned char)(((unsigned int)(color_scheme[depth % color_scheme_size].component[k]) * (256 - frac) +
                                               (unsigned int)(color_scheme[(depth + 1) % color_scheme_size].component[k]) * frac) / 256) ;
        } else {
          pixel_data[i + k] = color_scheme[depth % color_scheme_size].component[k];
        }
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
    cerr << "\nERROR (mandelbrot.c): PNG generated multiple times.\n";
  }
  if (pixel_data == NULL) {
    generatePixels();
  }
  
  startTimer();
  
  // Generate the png image
  unsigned error = lodepng_encode24(&png, png_size_p, pixel_data, req_width, req_height * (is_stereo ? 2 : 1));
  if(error) perror("\nERROR (mandelbrot.c): Error in generating png");

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
