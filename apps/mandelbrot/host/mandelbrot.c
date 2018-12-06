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
    num_color_schemes = 3;
    color_scheme_size = (int *) malloc(sizeof(int) * num_color_schemes);
    color_scheme = (color_t **) malloc(sizeof(color_t *) * num_color_schemes);
    color_scheme[0] = allocGradientsColorScheme(color_scheme_size[0], 8, 32);
    color_scheme[1] = allocRandomColorScheme(color_scheme_size[1], 32);
    //color_scheme[2] = allocGradientsColorScheme(color_scheme_size[2], 8, 64);
    color_scheme[2] = allocGradientDiagonalColorScheme(color_scheme_size[2], 8);
    static_init_done = true;
    
    BLACK.component[0] = BLACK.component[1] = BLACK.component[2] = (unsigned char)0;
  }
  
  enableTimer(0);
  
    
  depth_array = right_depth_array = NULL;
  fractional_depth_array = right_fractional_depth_array = NULL;
  color_array = right_color_array = NULL;
  pixel_data = NULL;
  png = NULL;
  req_width = req_height = 0;
  calc_width = calc_height = 0;
  x = y = pix_x = pix_y = (coord_t)0.0L;
  is_3d = (params[9] > 0.0L);
  int modes = (int)(params[16]);  // Bits, lsb first: 0: python(irrelevant here), 1: C++, 2: reserved, 3: optimize1, 4-5: reserved, 6: full-image, ...
  int colors = (int)(params[17]);
  
  // Active color scheme
  active_color_scheme_index = colors & 65535;
  if (active_color_scheme_index >= num_color_schemes) {active_color_scheme_index = 0;}
  active_color_scheme = color_scheme[active_color_scheme_index];
  active_color_scheme_size = color_scheme_size[active_color_scheme_index];
  
  electrify = (bool)((colors >> 25) & 1);
  color_shift = ((colors >> 16) & 255) * color_scheme_size[active_color_scheme_index] / 100;  // amount to shift color scheme given as 0-99 (percent) and adjusted for color scheme size.
  full_image = (bool)((modes >> 6) & 1);
  //+int color_scheme = (int)(params[17]);
  spot_depth = (int)(params[18]);
  show_spot = spot_depth >= 0;
  brighten = (int)(params[13]);
  eye_adjust = params[14];
  eye_separation = params[15];
  adjustment = params[7] / 100.0L;
  adjustment2 = params[8] / 100.0L;
  adjust = (adjustment != 0.0L || adjustment2 != 0.0L) && !fpga;
  
  int texture = fpga ? 0 : (int)(params[19]);
  string_lights = (bool)((texture >> 0) & 1);
  fanciful_pattern = (bool)((texture >> 1) & 1);
  shadow_interior = (bool)((texture >> 2) & 1);
  round_edges   = (bool)((texture >> 3) & 1);
  power_divergence = getTestFlag(6);
  int edge_style = (fpga || power_divergence) ? 0 : (int)(params[20]);
  square_divergence = edge_style == 1;
  y_squared_divergence = edge_style == 2;
  normal_divergence = !(power_divergence || square_divergence || y_squared_divergence);
  
  test_flags = (int)(params[21]);
  for (int i = 0; i < 8; i++) {
    test_vars[i] = (int)(params[22+i]);
  }
  
  test_texture = getTestFlag(0);
  textured = (test_texture | string_lights | fanciful_pattern | shadow_interior | round_edges) && !fpga;
  smooth = ((modes >> 7) & 1) && !fpga;
  if (!test_texture) {  // Force texture-based smoothing unless testing (just playing here; change this).
    smooth_texture = false;
    // For texture and non-normal edges, use a different smoothing approach based on effective divergence.
    // For texture the edge must be preserved (TODO: should they be with log smoothing?), and for altered edges effective divergence must be used.
    if (smooth && (textured || !normal_divergence)) {
      smooth = false;
      smooth_texture = true;
      textured = true;
    }
  } else {
    smooth_texture = getTestFlag(3);
    if (smooth_texture) {smooth = false;}
  }
  cutouts = false; // for now; for most textures it's not possible to determine the texture in the shadow of an upper layer from depth alone
  
  // For darkening distant 3D depths.
  darken = (params[12] > 0.0L);
  half_faded_depth = 30;
  
  auto_dive = full_image;  // (Relevant for 3D/Stereo-3D.)
  auto_darken = full_image;
  
  inf_color = BLACK;
  if (getTestFlag(0)) {inf_color.component[0] = inf_color.component[1] = inf_color.component[2] = 0x80;}  // Use grey for debug so it can be lightened/darkened.
  enable_step = ((modes >> 3) & 1) && !textured && !smooth && !fpga;

  need_derivatives = adjust || enable_step;
  
  assert(! IS_BIG_ENDIAN);
  
  x = (coord_t)params[0];
  y = (coord_t)params[1];
  pix_x = (coord_t)params[2];
  pix_y = (coord_t)params[3];
  req_width  = (int)params[4];
  req_height = (int)params[5];
  calc_width  = req_width;   // assuming not 3d and not limited by FPGA restrictions
  calc_height = req_height;  // "
  max_depth = (int)params[6];
  if (getTestFlag(2)) {max_depth = (int)(sqrt(params[6])) - 5;}
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
  if (VERBOSITY > 3)
    cout << "New image: center coords = (" << x << ", " << y << "), pix_size = (" << pix_x << ", " << pix_y
         << ")" /* << ", calc_img_size = (" << calc_width << ", " << calc_height << "), calc_center = (" << calc_center_w << ", " << calc_center_h
         << "), max_depth = " << max_depth */ << ", modes = " << modes << ", full = " << full_image << ". ";
  
  
  // TODO: I think there's currently a limitation that width must be a multiple of 16 for the FPGA.
  //       We will generate an image with width extended to a multiple of 16, where the extended pixels
  //       should not be displayed (because the redered image for 3D is sized to support the requested size).
  if (fpga) {
    int multiple = 16;
    calc_width = (calc_width + multiple - 1) / multiple * multiple;  // Round up depth array width to nearest 16.
  }
  
  start_darkening_depth = getZoomDepth() - eye_adjust - (coord_t)brighten;   // default assuming no auto-darkening
  if (VERBOSITY > 0)
    cout << "Settings: smooth: " << smooth << ", smooth_texture: " << smooth_texture << ", divergence_fn: " << power_divergence << y_squared_divergence << square_divergence << normal_divergence
         << ", string_lights: " << string_lights << endl;
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
  if (color_array != NULL) {
    free(color_array);
  }
  if (right_color_array != NULL) {
    free(right_color_array);
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
  if (VERBOSITY > 3)
    cout << "{Zoom info: " << pix_y_fit << ", " << zoom << "}. ";
    return log(SCALE_PER_DEPTH, zoom);
}

const int MandelbrotImage::RESOLUTION_FACTOR_3D = 2;  // TODO: Chosen empirically as an integer. It should be: distance from eye to most-distant visible depth / distance from eye to screen (and should be float).
const MandelbrotImage::coord_t MandelbrotImage::SCALE_PER_DEPTH = 0.9487L;
const MandelbrotImage::coord_t MandelbrotImage::EYE_DEPTH_FIT = 20.0L;
const MandelbrotImage::coord_t MandelbrotImage::NATURAL_DEPTH = 10.0L;

inline void MandelbrotImage::meldWithColor(color_t &color, color_t color2, float amount, bool cap) {
  capColorAmount(amount, cap);
  for (int c = 0; c < 3; c++) {
    color.component[c] = (unsigned char)((float)(color.component[c]) * (1.0 - amount) + (float)(color2.component[c]) * amount);
  }
}
inline void MandelbrotImage::lightenColor(color_t &color) {
  for (int c = 0; c < 3; c++) {
    color.component[c] = (unsigned char)(255 - ((255 - (int)(color.component[c])) >> 1) - ((255 - (int)(color.component[c])) >> 2));  // 3/4
  }
}
inline void MandelbrotImage::darkenColor(color_t &color) {
  for (int c = 0; c < 3; c++) {
    color.component[c] = (unsigned char)(((int)(color.component[c]) >> 1) + ((int)(color.component[c]) >> 2));  // 3/4
  }
}
// Lighten/darken by amout (between 0.0..1.0, non-inclusive).
inline void MandelbrotImage::lightenColor(color_t &color, float inv_amount, int component_mask, bool cap) {
  capColorAmount(inv_amount, cap);
  if (VERBOSITY > 0) {
    if (inv_amount < 0.0 || inv_amount > 1.0) {
      cout << "\ninv_amount = " << inv_amount << endl;
    }
  }
  for (int c = 0; c < 3; c++) {
    if ((component_mask & 1) != 0) {
      color.component[c] = (unsigned char)255 - (unsigned char)((float)(255 - (int)color.component[c]) * inv_amount);
    }
    component_mask = component_mask >> 1;
  }
}
inline void MandelbrotImage::darkenColor(color_t &color, float inv_amount, int component_mask, bool cap) {
  capColorAmount(inv_amount, cap);
  if (VERBOSITY > 0) {
    if (inv_amount < 0.0 || inv_amount > 1.0) {
      cout << "\ninv_amount = " << inv_amount << endl;
    }
  }
  for (int c = 0; c < 3; c++) {
    if ((component_mask & 1) != 0) {
      color.component[c] = (unsigned char)((float)(color.component[c]) * inv_amount);
    }
    component_mask = component_mask >> 1;
  }
}
// Illuminate color. Illumination should be additive, and this method should be called once with the total illumination, per component, to
// be applied to a base color. After illumination, the base color is lost.
inline void MandelbrotImage::illuminateColor(color_t &color, float * amts) {
  for (int c = 0; c < 3; c++) {
    int v = (int)((float)(color.component[c]) * amts[c]);
    color.component[c] = (v < 255) ? v : 255;
  }
}

// Make an image for an eye from the 2D "calc" image.
// Inputs:
//   depth_array (member)
//   fractional_depth_array (member) (if smooth)
//   color_array (member) (if textured)
// Outputs:
//   [return value] & fractional_depth_array_3d (if smooth): the new depth array for the eye
//   color_array_3d (if textured)
int * MandelbrotImage::makeEye(bool right, unsigned char * &fractional_depth_array_3d, color_t * &color_array_3d) {
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
    fractional_depth_array_3d = (unsigned char *)malloc(req_width * req_height * sizeof(unsigned char));
  }
  if (textured) {
    color_array_3d = (color_t *)malloc(req_width * req_height * sizeof(color_t));
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
          int d = depth_array[h_2d * calc_width + w_2d];
          if (depth >= d) {
            // unless we're not treating layers as infinite (only the cut-out).
            if (!cutouts || depth == d) {
              break;
            }
          }
        }
        
        // Next
        depth++;
        //depth_from_eye++;
        depth_separation *= SCALE_PER_DEPTH;
        dist_from_eye += depth_separation;
      }
      int ind_3d = h_3d * req_width + w_3d;
      int ind_2d = h_2d * calc_width + w_2d;
      if (depth < 0) {
        // Spot - use depth-0 color.
        depth_array_3d[ind_3d] = 0;
        if (smooth) {
          fractional_depth_array_3d[ind_3d] = (unsigned char)0;
        }
        if (textured) {
          color_array_3d[ind_3d] = depthToColor(0, 0);  // No depth darkening because we've lost real depth.
        }
      } else {
        // Normal case.
        // Set color_array_3d if textured, or [fractional_]depth_array_3d otherwise.
        bool shadowed = (textured || smooth) && depth_array[ind_2d] < depth;
        if (textured) {
          if (shadowed) {
            color_t color;
            // We're in the shadow of the layer above, so there's no corresponding color information in the 2D array.
            // Each texture scheme needs a policy for this handled here.
            //if (smooth) {
              // Use color of this layer.
              color = depthToColor(depth, 0);
              darkenForDepth(color, depth, 0);
            //} else {
            //  // Color shadow with a dark version of the layer above (like an edge).
            //  color = depthToColor(depth - 1, 0);
            //  // FIXME: ...need to apply texture...
            //  darkenColor(color);
            //}
            color_array_3d[ind_3d] = color;
          } else {
            // Normal case (not shadowed)
            color_array_3d[ind_3d] = color_array[ind_2d];
          }
        } else {
          depth_array_3d[ind_3d] = depth;
          if (smooth) {
            fractional_depth_array_3d[ind_3d] =
                 shadowed
                     ? (unsigned char)0  // in the shadow of a closer layer.
                     : fractional_depth_array[ind_2d];
          }
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
  if (VERBOSITY > 3)
    cout << "Eye depth: " << eye_depth << ". ";
  // Adjust spot_depth to be relative to eye.
  if (show_spot) {
    spot_depth = (int)eye_depth + NATURAL_DEPTH + spot_depth;
  }
  
  // Compute new 3D-iffied depth array(s) from depth_array.
  unsigned char *fractional_depth_array_3d;
  color_t *color_array_3d;
  int * depth_array_3d = makeEye(false, fractional_depth_array_3d, color_array_3d);
  if (is_stereo) {
    right_depth_array = makeEye(true, right_fractional_depth_array, right_color_array);  // (freed upon destruction)
  }
  
  // Replace depth_array w/ 3d depth array, and update calc_width/height to reflect new depth_array.
  free(depth_array);
  depth_array = depth_array_3d;
  calc_width = req_width;
  calc_height = req_height;
  // Same for fractional_depth_array and color_array.
  if (smooth) {
    free(fractional_depth_array);
    fractional_depth_array = fractional_depth_array_3d;
  }
  if (textured) {
    free(color_array);
    color_array = color_array_3d;
  }

  stopTimer("make3d()");
  
  return this;
};

// Convert x,y coordinates to an angle.
// Rightward will be 0.0, extending positive in a counterclockwise direction and negative clockwise to +/-2.0 pointing left.
inline float MandelbrotImage::cartesianToAngle(float x, float y) {
  float ret;
  if (x > y) {
    ret = atan(y/x) / M_PI;
    if (x < 0.0L) {
      if (ret > 0.0L) {
        ret -= 1.0L;
      } else {
        ret += 1.0L;
      }
    }
  } else {
    ret = -atan(x/y) / M_PI;
    if (y > 0.0L) {
      ret += 0.5L;
    } else {
      ret -= 0.5L;
    }
  }
  return ret;
}

// From Martin Ankerl.
inline double fastPow(double a, double b) {
  union {
    double d;
    int x[2];
  } u = { a };
  u.x[1] = (int)(b * (u.x[1] - 1072632447) + 1072632447);
  u.x[0] = 0;
  return u.d;
}

// Compute the depth of a pixel. Also populate fractional_depth_array and color_array as needed.
// Used by generateDepthArray.
// TODO: Math would be a little simpler if divergent_radius was always 2.0, and x0 & y0 were scaled down instead.
inline int MandelbrotImage::pixelDepth(int w, int h, int & step) {
  step = 1; // Just provide on pixel, unless othewise determined.
  
  coord_t next_xx = wToX(w);
  coord_t next_yy = hToY(h);
  coord_t xx = 0.0;
  coord_t yy = 0.0;

  int depth = 0;
  int frac = 0;   // Fractional depth
  if (false) {
    // For debug:
    // This generates a square at depth 0.
    bool inside = next_xx < 0.3 && next_xx > -0.3 &&
                  next_yy < 0.3 && next_yy > -0.3;
    depth = inside ? 0 : max_depth;
    frac = 0;
  } else {
    coord_t scaled_adjustment  = adjustment  * (req_width + req_height) * pix_x * 0.06;
    coord_t scaled_adjustment2 = adjustment2 * (req_width + req_height) * pix_x * 0.06;

    
    coord_t divergent_radius = ((smooth || (string_lights && ! fanciful_pattern)) ? 32.0L : 2.0L) * fastPow(2.0L, getTestVar(0, -8.0L, 8.0L)) * getTestVar(1, -1.0, 3.0L);
                                                      // Greater values take longer to compute but reduce layer transitions for smoothing.
    coord_t divergent_radius_sq = divergent_radius * divergent_radius;
    
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
    
    coord_t radius_sq = divergent_radius_sq;
    coord_t next_radius_sq;
    coord_t effective_radius_sq = radius_sq;
    coord_t next_effective_radius_sq;

    bool next_diverges = true;
    // Mandelbrot pixel calc.
    coord_t x0 = next_xx;
    coord_t y0 = next_yy;
    do {
      next_radius_sq = next_xx * next_xx + next_yy * next_yy;
      next_effective_radius_sq = next_radius_sq;
      // Alternate divergence tests to adjust the edge.
      if (!normal_divergence) {
        // Maybe override default divergence behavior. Also, be sure to provide next_effective_radius_sq which might be used for texturing.
        if (square_divergence) {
          // Diverge at x/y of varying power (1 by default for divergent square, 2 is normal circle, etc.).
          coord_t next_effective_radius = max(abs(next_xx), abs(next_yy));
          next_effective_radius_sq = next_effective_radius * next_effective_radius;
        } else if (power_divergence) {
          // Diverge using varying power (1 (default) for diamond, 2 for normal circle, etc.).
          coord_t power = getTestVar(2, -3.0L, 7.0L);
          coord_t next_effective_radius = fastPow((fastPow(abs(next_xx), power) + fastPow(abs(next_yy), power)), 1.0f / power);
          next_effective_radius_sq = next_effective_radius * next_effective_radius; // TODO: Could combine above.
        } else if (y_squared_divergence) {
          // Villi
          next_effective_radius_sq = /*next_xx * next_xx * getTestVar(2, -1.0L, 3.0L) + */ next_yy * next_yy;
        } else if (false) {
          // Hearts
          next_effective_radius_sq = (next_xx * getTestVar(2, -1.0L, 3.0L) + next_yy * next_yy);
        }
      }
      next_diverges = next_effective_radius_sq > divergent_radius_sq;
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
      radius_sq = next_radius_sq;
      effective_radius_sq = next_effective_radius_sq;
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
    
    if (fractional_depth_array != NULL) {
      if (depth < max_depth) {
        coord_t log_zn = std::log(getTestFlag(13) ? next_radius_sq : next_effective_radius_sq) / 2.0L;
        coord_t log_2 = std::log(2.0L);
        coord_t nu = std::log( log_zn / log_2 ) / log_2;
        frac = (int)((1.0L - nu) * 256.0L);   // 256 (byte) granularity, but this fraction can be out of range (multiple negative depths).
        // Account for depth adjustments to get frac within a depth.
        if (frac < 0) {
          int depth_decr = ((-frac + 255) >> 8);
          depth -= depth_decr;
          frac += depth_decr << 8;
          // but not less than depth 0.
          if (depth < 0) {
            depth = 0;
            frac = 0;
          }
        } else if (frac >= 256) {
          int depth_incr = frac >> 8;
          cout << "\nWARNING: Unexpected smoothing adjustment of " << depth_incr << " (frac: " << frac << ").\n";
          depth += depth_incr;
          frac -= depth_incr << 8;
        }
        if ((int)((unsigned char)frac) != frac) {
          //cout << "[" << log_zn << "](" << next_xx << ", " << next_yy << ")" << flush;
          cout << "\nBUG: Smoothing fraction out of range [" << log_zn << ":" << nu << "]" << "{" << depth << "." << frac << "}" << endl;
        }
      }
      if (fractional_depth_array != NULL) {
        fractional_depth_array[h * calc_width + w] = (unsigned char)frac;
      }
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
    
    // Provide texture (color of "pixel").
    if (color_array != NULL) {
      // Note: Some of this computation could be done once for the image, not for every pixel, but there's deep computation per pixel anyway.
      // Note: Smooth is generally false, so frac is generally 0, but some textures might overlay on a smoothed scheme (that's not a smooth_texture).
      
      bool smooth_map = ! getTestFlag(7);
      bool no_color_scheme = getTestFlag(12);
      bool radial = getTestFlag(1) || smooth_texture;
      float a_granularity = (float)fastPow(2.0, getTestVar(5, -6.0, 6.0));
      float b_granularity = (float)fastPow(2.0, getTestVar(6, -6.0, 6.0));
      //-bool fine_grained = getTestFlag(8);
      //-bool coarse_grained = getTestFlag(9);
      bool two_tone = getTestFlag(10);
      bool use_next = getTestFlag(11);
      float a_adj = getTestVar(3, 0.0f, 2.0f);
      float b_adj = getTestVar(4, 0.0f, 2.0f);
      bool invert_radius = getTestFlag(8) ^ use_next;  // By default, invert radius for diverged values.
      bool use_effective_radius = getTestFlag(14);
      bool cycle_texture = getTestFlag(9);
      float fade = getTestVar(7, -1.0f, 1.0f);  // Fade the color of the layer (before applying lighting).
      unsigned char fade_to = (unsigned char)0x90; // value to use for fade-to grey color components
      bool scales = false; //...
      bool texture_max = !use_next;  // apply texture to max depth; there's no next to use at max depth
      bool a_gradient = ! getTestFlag(4);
      bool b_gradient = ! getTestFlag(4);
      bool sawtooth_smoothing = getTestFlag(5);
      // Local versions for hacks, so as not to alter the members.
      bool local_string_lights = string_lights;
      bool local_test_texture = test_texture;
      float ambient_illumination = 1.0;
      // For colored lights:
      bool illuminate_surface = false;
      float surface_illumination[3]; // by component
      
      if (string_lights) {
        if (local_test_texture) {
          // Turns out this looks similar, but better than string_lights, so use this instead.
          local_string_lights = false;
          radial = false;
          a_gradient = true;
          b_gradient = true;
          use_next = false;
          invert_radius = false;
          local_test_texture = true;
        } else {
          fade += 0.85f;
          ambient_illumination = 0.5;
        }
      }
      
      if (fanciful_pattern) {
        radial = false;
        a_gradient = false;
        b_gradient = true;
        b_granularity = 2.0;
        use_next = true;
        cycle_texture = true;
        invert_radius = false;
        local_test_texture = true;
      }
      
      // Apply shading.

      // Start with non-textured color(s).
      color_t color;
      if (no_color_scheme) {
        // Use grey for base color.
        color.component[0] = color.component[1] = color.component[2] = 0x80;
      } else {
        // Use color scheme for base color.
        color = depthToColor(depth, frac);
      }
      
      if (texture_max || (depth < max_depth)) {
        float inward = 1.0; // From 0.0 at inner edge to 1.0 at outer edge.
        if (smooth_texture) {
          color_t deeper_color = depthToColor(depth + 1, frac); // next depth color (frac should be zero (!smooth))
          float r_norm = sqrt(effective_radius_sq / divergent_radius_sq);
          float next_r_norm = sqrt(next_effective_radius_sq / divergent_radius_sq);
          inward = (1.0f - r_norm) / (next_r_norm - r_norm);
          meldWithColor(color, deeper_color, sawtooth_smoothing ? 1.0 - inward : inward);
        }
        
        color_t light_color = color;
        if (fade > 0.0f) {
          color_t grey;
          grey.component[0] = grey.component[1] = grey.component[2] = fade_to;
          meldWithColor(color, grey, fade);
        }
        if (shadow_interior) {
          // Shadow (darken) the interior. The shadow will follow the upper layer.
          //darkenColor(color, 1.0f - effective_radius_sq / divergent_radius_sq / 4.0f);  // darken by 2/3, shadowed by upper layer.
          float from_no_dark = sqrt(effective_radius_sq) / divergent_radius - 0.75f;  // (sqrt is expensive)
          if (from_no_dark > 0.0f) {
            from_no_dark *= 3.0;
            ambient_illumination *= 1.0 - from_no_dark * from_no_dark;
          }
          
        }
        if (local_test_texture) {
          // Testing. Shade based on x/y, angle/radius under the influence of test flags/values. This is for experimenting w/ schemes and visually exposing
          // values to better understand the algorithm.
          // Use depth (converged) values or next depth (diverged) values.
          float x;
          float y;
          float a, b;
          float r_sq;
          if (use_next) {
            x = (float)next_xx;
            y = (float)next_yy;
            r_sq = use_effective_radius ? next_effective_radius_sq : next_radius_sq;
          } else {
            x = (float)xx;
            y = (float)yy;
            r_sq = use_effective_radius ? effective_radius_sq : radius_sq;
          }
          
          // A/B are coordinates based in some way on x/y or next_x/y.
          if (radial) {
            // Use radial coords.
            // b ifancifuls radius.
            if (smooth_texture) {
              // Use radial coords from 0.0..1.0.
              b = inward;
            } else {
              // Use radial coords with x/y == 0.0 is radius == 0.0, and divergence at 1.0.
              float r_sq_norm = r_sq / divergent_radius_sq;
              b = sqrtf(r_sq_norm);  // 0.0..1.0
              if (invert_radius) {b = 1.0f / b;}  // inf..0.5
            }
            // a is angle, Rightward angle will be 0.0, extending positive in a counterclockwise direction and negative clockwise to +/-2.0 pointing left.
            a = cartesianToAngle(x, y);  // -1.0..1.0
          } else {
            // Use x/y as a/b.
            a = x / divergent_radius;  // -1.0..1.0
            b = y / divergent_radius;  // -1.0..1.0
          }
          
          // Based on a/b, provide texture.
          
          // Texture based on a & b. Either darken for a < 0.0 and lighten for b < 0.0, or
          // smooth scale from saturated at zero upward to color and unsaturated at zero downward to color.
          int a_component_mask = two_tone ? 4 : 7;
          int b_component_mask = two_tone ? 1 : 7;
          
          float scaled_a = (a + a_adj) * a_granularity;
          float scaled_b = (b + b_adj) * b_granularity;
          if (!cycle_texture) {
            if (scaled_a > 2.0) {
              scaled_a = 2.0;
            } else if (scaled_a < 0.0) {
              scaled_a = 0.0;
            }
            if (scaled_b > 2.0) {
              scaled_b = 2.0;
            } else if (scaled_b < 0.0) {
              scaled_b = 0.0;
            }
          }
        
          float a_inv_amt = smooth_map ? scaled_a / 2.0f - floor(scaled_a / 2.0f) : ((int)scaled_a % 2 == 0) ? 0.75f : 1.0f;
          float b_inv_amt = smooth_map ? scaled_b / 2.0f - floor(scaled_b / 2.0f) : ((int)scaled_b % 2 == 0) ? 0.75f : 1.0f;
          if (a_gradient) {lightenColor(color, a_inv_amt, a_component_mask);}
          if (b_gradient) {darkenColor(color, b_inv_amt, b_component_mask);}
        
          if (false) { // dark for big radius values
            float big_bound = 0.9f;
            bool big = a > big_bound;
            if (big) {
              color = BLACK;
            }
          }
        }
        if (local_string_lights) {
          if (true) {
            // String lights.
            float diag_dist = ((float)xx + (float)yy) / divergent_radius / 2.0f;
            float diag_dist_sq = diag_dist * diag_dist;
            illuminate_surface = true;
            if (diag_dist > 0.0f) {
              // Corner to white.
              //lightenColor(color, 1.0f - diag_dist_sq, 7, true);  // Capping not needed for square divergence and no divergence, but we do it always.
              float amt = 3.1f * diag_dist_sq;
              for (int c = 0; c < 3; c++) {
                surface_illumination[c] = amt;
              }
            } else {
              // Corner to color.
              //meldWithColor(color, light_color, diag_dist_sq, true);  // Capping not needed for square divergence and no divergence, but we do it always.
              //illuminateColor(color, 3.1f * diag_dist_sq, light_color);
              float factor = 3.1f * diag_dist_sq;
              for (int c = 0; c < 3; c++) {
                surface_illumination[c] = (float)(light_color.component[c]) / 255 * factor;
              }
            }
          } else if (true) {
            // String lights.
            // FIXME (or delete)
            darkenColor(color, (xx / divergent_radius + 1.0f) * 0.8f, 7, true);
            lightenColor(color, (xx / divergent_radius + 1.0f) * 0.8f, 7, true);
          } else {
            // String lights.
            //float dist = a * a + b * b;
          }
        } else if (scales) {
          //...
        }
      }
      
      // Apply illumination and colored illumination to surface and shadow to rounded edge.
      
      // Shadow the outer edge using a parabolic (of parabolic segment) drop just before edge.
      if (color.color != 0) {
        // Apply ambient and surface illumination.
        float illum[3];
        for (int c = 0; c < 3; c++) {
          illum[c] = ambient_illumination + (illuminate_surface ? surface_illumination[c] : 0.0f);
        }
        illuminateColor(color, illum);
        // Apply rounded corner.
        float divergence;
        if (round_edges && (((divergence = next_effective_radius_sq / divergent_radius_sq - 1.4f)) < 0.0f)) {
          // Apply ambient illumination, shadowed for corner.
          divergence *= divergence;
          darkenColor(color, (1.0f - divergence), 7, true);
        }
      }
      
      // Apply color.
      color_array[h * calc_width + w] = color;
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
  if (depth_array != NULL) {  // which it will be for textured and (not 3D and not darken)
    if (w >= calc_width || h >= calc_height) {
      cerr << "\nERROR (mandelbrot.c): Outside depth array bounds" << endl;
      exit(5);
    }
    depth_array[h * calc_width + w] = depth;
  }
}

// Set up for auto-depth determination (for either C++ or FPGA mechanism).
void MandelbrotImage::setAutoDepthBounds() {
  auto_depth = max_depth;  // reduced dynamically
  auto_depth_frac = 0;
  // Use a different auto-depth bounding box for different modes:
  //   2-D: Auto-depth (darkening) at depth that touches 2/3-scaled requested rectangle.
  //   3-D: Auto-depth (darkening and screen depth) at depth that touches 3/4-scaled requested rectangle.
  //   Stereo 3-D: Auto-depth (darkening) and screen depth) at depth touching rectangle between eyes in width and 3/4 requested height.
  auto_depth_w = is_stereo ? eye_separation / 2 :  // Align the eye with auto-depth (screen depth)
                 is_3d     ? (req_width * 3 / 4) / 2 :  // 3/4-scaled center rectangle touches auto-depth (screen depth)
                             (req_width * 2 / 3) / 2;   // 2/3-scaled center rectangle touches auto-depth. 
  auto_depth_h = is_stereo ? (req_height * 3 / 4) / 2 :
                 is_3d     ? (req_height * 3 / 4) / 2 :
                             (req_height * 2 / 3) / 2;
}


// Allocate and fill depth_array and fractional_depth_array and/or color_array as needed.
// For textured, color is computed and depth need only be captured if 3-D.
// TODO: This is now misnamed.
MandelbrotImage *MandelbrotImage::generateDepthArray() {
  startTimer();
  
  // Since auto_depth can be used to determine darkening which determines max_depth, we don't know max_depth
  // before we need it. To address this, we determine an initial conservative value for auto_depth to use here
  // by trying the four corners of the rectangle within which we look for depth. Likely these will find the
  // least depth. If not, we waste some time. Depth array may fill with values > max_depth. Max depth is updated
  // as each pixel is processed.
  //
  // For FPGA computation of depth_array, auto_depth is set based on a 16x16 image in
  // this bounding box, and is not updated during computation.
  //
  setAutoDepthBounds();
  // Adjustment depth must be determined before computing depth_array. We'll determine it here based on the four corners
  // (TODO: which is less than ideal).
  // (This also sets initial start_darkening_depth (which is defaulted for no-auto-depth), where no adjustment is assumed for this determination).
  // We do this before allocating arrays to avoid populating them.
  if (auto_darken || auto_dive) {
    bool real_adjust = adjust;
    adjust = false;
    tryPixelDepth(calc_center_w - auto_depth_w, calc_center_h - auto_depth_h);
    tryPixelDepth(calc_center_w + auto_depth_w, calc_center_h - auto_depth_h);
    tryPixelDepth(calc_center_w - auto_depth_w, calc_center_h + auto_depth_h);
    tryPixelDepth(calc_center_w + auto_depth_w, calc_center_h + auto_depth_h);
    adjust = real_adjust;
  }
  
  // Allocate arrays to be filled by pixelDepth().
  if (!textured || is_3d || darken) {
    depth_array = (int *)malloc(calc_width * calc_height * sizeof(int));
    if (smooth) {
      fractional_depth_array = (unsigned char *)malloc(calc_width * calc_height * sizeof(unsigned char));
    }
  }
  if (textured) {
    color_array = (color_t *)malloc(calc_width * calc_height * sizeof(color_t));
  }
  
  adjust_depth = 0.0f;
  // Apply adjustments based on auto_depth, but adjustments must be applied as depths are computed, so we use this
  // initial approximation.
  if (adjust) {
    // Matched to eye depth.
    adjust_depth = start_darkening_depth;  // Begin adjustment where we begin darkening (both should be around first visible level) //- getZoomDepth() - EYE_DEPTH_FIT - eye_adjust;
  }
  if (VERBOSITY > 3)
    cout << "adjust: " << adjust << ", adjust_depth: " << adjust_depth << ", auto_depth" << auto_depth << ", adjustment: " << adjustment << ", smooth: " << smooth << flush;

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
  
  // Darkening for depth can only be applied once auto-depth is computed (which it now is).
  // Darken for depth.
  if (darken && (color_array != NULL)) {
    for (int h = 0; h < calc_height; h++) {
      for (int w = 0; w < calc_width; w++) {
        int i = h * calc_width + w;
        darkenForDepth(color_array[i], depth_array[i], smooth ? fractional_depth_array[i] : (unsigned char)0);
      }
    }
  }
  
  if (VERBOSITY > 3)
    cout << ", % guessed pixels: %" << (int)((coord_t)(num_pixels - num_steps) / (coord_t)num_pixels * 100.0L) << ", auto_depth: " << auto_depth << ", brighten: " << brighten << ". ";
  
  stopTimer("generateDepthArray()");

  return this;
}

// Set max_depth based on darkening. This must be called multiple times because auto_darken is determined
// dynamically during depth array generation. We conservatively estimate first, then correct if necessary.
void MandelbrotImage::updateMaxDepth(int new_auto_depth, unsigned char new_auto_depth_frac) {
  if ((new_auto_depth << 8) + (int)new_auto_depth_frac < (auto_depth << 8) + (int)auto_depth_frac) {
    auto_depth = new_auto_depth;
    auto_depth_frac = new_auto_depth_frac;
    if (auto_darken) {
      start_darkening_depth = ((float)((auto_depth << 8) + (int)auto_depth_frac)) / 256.0f - eye_adjust - (coord_t)brighten;
    }
    if (auto_darken) {
      int dark_depth = (int)start_darkening_depth + half_faded_depth * 6;  // Light fades exponentially w/ depth. After 6 half_faded_depth's, brightness is 1/32.
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
    cerr << "ERROR (mandelbrot.c): Pixels generated multiple times.\n";
  }
  // TODO: Optimization: Currently for 3-D we generate two images independently, but we could generate a single
  //       DepthArray, and 3-D-ify it twice.
  if (is_3d) {
    make3d();
  }
  
  startTimer();

  if (VERBOSITY > 3)
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
    toPixelData(pixel_data, depth_array, fractional_depth_array, color_array);
    if (is_stereo) {
      toPixelData(pixel_data + sizeof(char) * chars_per_image, right_depth_array, right_fractional_depth_array, right_color_array);
    }
  }

  stopTimer("generatePixels()");
  
  if (VERBOSITY > 3)
    cout << endl;
  
  return this;
};

inline void MandelbrotImage::darkenForDepth(color_t &color, int depth, int fractional_depth) {
  if (darken) {  // && (color != BLACK)
    float smooth_depth = (float)depth;
    if (smooth) {
      smooth_depth += (float)fractional_depth / 256.0f;
    }
    if (smooth_depth > start_darkening_depth) {
      darkenColor(color, 1.0f / (1.0f + (smooth_depth - start_darkening_depth) / (float)half_faded_depth));
    }
  }
}
inline MandelbrotImage::color_t MandelbrotImage::depthToColor(int depth, int fractional_depth) {
  color_t color = inf_color;
  if (depth >= max_depth) {  // (It is possible for depth to be > max_depth because of dynamic auto-darkening, and it should be treated as max.)
    color = inf_color;
  } else {
    int color_depth = depth + color_shift;
    for(int k = 0; k < 3; k++) {
      if (smooth) {
        color.component[k] = (unsigned char)(((int)(active_color_scheme[color_depth % active_color_scheme_size].component[k]) * (256 - fractional_depth) +
                                              (int)(active_color_scheme[(color_depth + 1) % active_color_scheme_size].component[k]) * fractional_depth) / 256) ;
      } else {
        color.component[k] = active_color_scheme[color_depth % active_color_scheme_size].component[k];
      }
    }
  }
  return color;
}

void MandelbrotImage::toPixelData(unsigned char *pixel_data, int *depth_array, unsigned char *fractional_depth_array, color_t *color_array) {
  
  int j = 0;
  int i = 0;

  // Building the image pixels data
  for(int h = 0; h < req_height; h++) {
    // Because depth array might be wider than req_width for FPGA, we must reset each row.
    j = h * calc_width;
    for(int w = 0; w < req_width; w++) {
      int depth = depth_array[j];
      color_t color;
      if (textured) {
        color = color_array[j];
      } else {
        int frac = smooth ? (int)(fractional_depth_array[j]) : 0;
        color = depthToColor(depth, frac);
        darkenForDepth(color, depth, frac);
      }
      for(int k = 0; k < 3; k++) {
        pixel_data[i+k] = color.component[k];
      }
      
      j++;
      i+=3;
    }
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
MandelbrotImage::color_t MandelbrotImage::BLACK;
