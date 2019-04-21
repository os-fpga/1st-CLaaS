/*
BSD 3-Clause License

Copyright (c) 2018, alessandrocomodi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#include <math.h>
#include <cstdlib>
#include "mandelbrot.h"

using namespace std;


//
// Generic stuff that's out of place.
//

#define IS_BIG_ENDIAN (*(uint16_t *)"\0\xff" < 0x100)

int otherHash(int i) {
  srand(i);
  return rand();
};

int myHashOld(int v)
{
    return (v * 2654435761) >> 32;
}

// This was thrown together without any expertise.
// x: value to hash
// p: number of bits in result
inline int myHash(const int x, const int p) {
    union {
      double f;
      std::uint64_t i;
    } m;
    m.f = (float)x / (float)M_PI;
    return ((int)(((std::uint32_t)x * (std::uint32_t)2654435769) >> (32 - p)) ^ m.i ^ (m.i >> 46) ^ (m.i >> 60)) & ((1 << p) - 1);
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


// ===========================================================================================
// A Mandelbrot image.
//

MandelbrotImage::MandelbrotImage(json &j) {
  params_json = j;

  // // Print sizeof(stuff)
  //cout << "int: " << sizeof(int) << ", long: " << sizeof(long) << ", long long: " << sizeof(long long) << ", float: " << sizeof(float) << ", double: " << sizeof(double) << ", long double: " << sizeof(long double) << endl;

  fpga = param<string>("renderer", "fpga") == "fpga";  // Currently we restrict image settings based on whether the FPGA was _requested_ (whether available/used or not).
  param("test_flags", test_flags, 0);
  for (int i = 0; i < 16; i++) {
    try {
      j["test_vars"][i].get_to(test_vars[i]);
    } catch (nlohmann::detail::exception) {
      test_vars[i] = 0.0L;
    }
  }

  verbosity = (int)getTestVar(15, -10.0, 10.0);
  if (verbosity < 0) {verbosity = 0;}

  // "Static" init (hack). (We waited till verbosity was extracted to do this, just in case it's needed.)
  if (!static_init_done) {
    // Allocate color schemes (never deallocated).
    num_color_schemes = 4;
    color_scheme_size = (int *) malloc(sizeof(int) * num_color_schemes);
    color_scheme = (color_t **) malloc(sizeof(color_t *) * num_color_schemes);
    color_scheme[0] = allocGradientsColorScheme(color_scheme_size[0], 8, 32);
    color_scheme[1] = allocRandomColorScheme(color_scheme_size[1], 32);
    //color_scheme[2] = allocGradientsColorScheme(color_scheme_size[2], 8, 64);
    color_scheme[2] = allocGradientDiagonalColorScheme(color_scheme_size[2], 8);
    color_scheme[3] = allocRainbowColorScheme(color_scheme_size[3]);
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
  x = y = req_pix_size = calc_pix_size = (coord_t)0.0L;
  param("three_d", is_3d, false);
  int modes;
  param("modes", modes, 0); // Bits, lsb first: 0: python(irrelevant here), 1: C++, 2: reserved, 3: optimize1, 4-5: reserved, 6: full-image, ...
  int colors;
  param("colors", colors, 0);


  // Active color scheme
  active_color_scheme_index = colors & 65535;
  if (active_color_scheme_index >= num_color_schemes) {active_color_scheme_index = 0;}
  active_color_scheme = color_scheme[active_color_scheme_index];
  active_color_scheme_size = color_scheme_size[active_color_scheme_index];

  electrify = (bool)((colors >> 25) & 1);
  color_shift = ((colors >> 16) & 255) * color_scheme_size[active_color_scheme_index] / 100;  // amount to shift color scheme given as 0-99 (percent) and adjusted for color scheme size.
  full_image = (bool)((modes >> 6) & 1);
  //+int color_scheme = (int)(params[17]);
  param("spot_depth", spot_depth, -1);
  show_spot = spot_depth >= 0;
  param("brighten", brighten, 0);
  param<coord_t>("eye_adjust", eye_adjust, 0.0L);
  int eye_sep_adjust = (int)(getTestVar(14, -500.0f, 500.0f));
  req_eye_separation = param("eye_sep", 0.0L) + eye_sep_adjust;
  adjustment = param<coord_t>("var1", 0.0L) / 100.0L;
  adjustment2 = param<coord_t>("var2", 0.0L) / 100.0L;
  adjust = (adjustment != 0.0L || adjustment2 != 0.0L) && !fpga;

  int texture = fpga ? 0 : param<int>("texture", 0);
  string_lights = (bool)((texture >> 0) & 1);
  fanciful_pattern = (bool)((texture >> 1) & 1);
  shadow_interior = (bool)((texture >> 2) & 1);
  round_edges   = (bool)((texture >> 3) & 1);

  ornaments = getTestFlag(22);
  light_brightness = getTestVar(13, 1.0f, 5.2f);

  power_divergence = getTestFlag(6);
  int edge_style = (fpga || power_divergence) ? 0 : param<int>("edge", 0);
  square_divergence = edge_style == 1;
  y_squared_divergence = edge_style == 2;
  normal_divergence = !(power_divergence || square_divergence || y_squared_divergence || ornaments);
  int theme = fpga ? 0 : param<int>("theme", 0);
  no_theme = theme == 0;
  xmas_theme = theme == 1;

  param("cycle", cycle, 0);
  test_texture = getTestFlag(0);
  lighting = string_lights || fanciful_pattern || shadow_interior || round_edges;
  textured = (test_texture || lighting) && !fpga;
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
  use_derivatives = getTestFlag(15);

  // For darkening distant 3D depths.
  param("darken", darken, false);
  texture_max = !darken && getTestFlag(27);  // Apply texture to max depth. Note that use_next has no effect on max-depth texture, as next_* have not been updated for max_depth.
                                             // Do not darken if debugging max depth, as it could change dynamically.
  half_faded_depth = 30;

  auto_dive = full_image && is_3d;
  auto_darken = full_image;  // (Even if we aren't darkening, we use the darken-depth to determing max_depth.)

  inf_color = BLACK;
  if (getTestFlag(0)) {inf_color.component[0] = inf_color.component[1] = inf_color.component[2] = 0x80;}  // Use grey for debug so it can be lightened/darkened.


  // Apply theme overrides.
  if (!no_theme) {
    if (xmas_theme) {
      textured = true;
      lighting = true;
      string_lights = true;
      smooth = false;
      shadow_interior = true;
      round_edges = true; //?
      normal_divergence = false;
      square_divergence = true;
      light_brightness = 3.5f;
      ornaments = true;
      fanciful_pattern = true;
      //inf_color.component[0] = inf_color.component[1] = inf_color.component[2] = (unsigned char)255;
    }
  }


  need_derivatives = adjust || use_derivatives;


  assert(! IS_BIG_ENDIAN);

  x = param<coord_t>("x", 0.0L);
  y = param<coord_t>("y", 0.0L);
  param<coord_t>("pix_x", req_pix_size, 0.0L);  // (assuming same size x and y, even though both are sent)
  param("width", req_width, 0);
  param("height", req_height, 0);
  calc_width  = req_width;   // assuming not 3d and not limited by FPGA restrictions
  calc_height = req_height;  // "

  param("max_depth", spec_max_depth, 250);
  max_depth = -1000;   // garbage value
  if (getTestFlag(2)) {spec_max_depth = sqrt(spec_max_depth) - 4;}
  req_eye_offset = param<int>("offset_w", 0) - (eye_sep_adjust >> 1);
  is_stereo = is_3d && req_eye_separation > 0;
  req_center_w = req_width  >> 1;  // (adjusted by req_eye_offset for stereo 3D)
  req_center_h = req_height >> 1;

  coord_t divergent_radius_coarse = getTestVar(0, -8.0L, 8.0L);
  divergent_radius = ((smooth || (string_lights && ! fanciful_pattern)) ? 32.0L : 2.0L) * ((divergent_radius_coarse == 0.0L) ? 1.0L : fastPow(2.0L, divergent_radius_coarse)) * getTestVar(1, -1.0, 3.0L);
                                            // Greater values take longer to compute but reduce layer transitions for smoothing.
  divergent_radius_sq = divergent_radius * divergent_radius;


  // For 3D images, we compute larger 2D images for sufficient resolution of the 3D image at all depths.
  // Close depths will require finer pixel x/y size, and far depths require coarser pixels. We must account for the
  // entire range with a single choice of pixel size and x/y expanse.
  req_pix_per_calc_pix = calc_pix_per_req_pix = scale_per_depth = recip_scale_per_depth = eye_depth_fit = natural_depth = expansion_factor_3d = 0.0L;
  calc_pix_size = req_pix_size;

  if (is_3d) {
    req_pix_per_calc_pix = 1.0L;
    scale_per_depth = 0.9487L;
    eye_depth_fit = 20.0L;
    natural_depth = 10.0L;

    // Modify parameters for VR viewer.
    if (is_stereo && (req_width < ((int)req_eye_separation + req_eye_offset * 2 - 10))) {
      // We're creating images for a VR viewer. TODO: Above, we use the fact that there is a gap between images as an indicator of a VR viewer. This should be explicit.
      // Use eye close to screen, keeping structure the same. This means the resulting 3D image shrinks.
      natural_depth /= 3.0L;
      req_pix_per_calc_pix = 3.0L;

      // Seems to be good to push the structure back a bit.
      eye_adjust += 20.0L;
      brighten -= 20;
    }

    expansion_factor_3d = (1.0L / (1.0L - scale_per_depth)) / natural_depth;
         // Determines how much extra h/w needs to be calculation to account for shrinking at greater depth.
         // This equals distance from eye to most-distant visible depth / distance from eye to screen.
         // Distance at each depth is a geometric series, so the distance of max depth (approximated as infinite depth) is given by
         // SUM(scale_per_depth ^ n) = 1/(1-scale_per_depth).

    if (is_stereo) {
      // A single 3d image covers both eyes. For width, trace line of sight for inner and outer eye image edge (symmetric for each eye).
      coord_t calc_width_inner = (coord_t)(req_center_w - req_eye_offset) * expansion_factor_3d * 2.0L - (coord_t)req_eye_separation;  // (not yet reflective of req_pix_per_calc_pix)
      coord_t calc_width_outer = (coord_t)(req_center_w + req_eye_offset) * expansion_factor_3d * 2.0L + (coord_t)req_eye_separation;  //   "
      calc_width = int(((calc_width_inner > calc_width_outer) ? calc_width_inner : calc_width_outer) / req_pix_per_calc_pix) + 1;  // (essentially +1 is round up)
      //cout << calc_width << " = ((" << calc_width_inner << " > " << calc_width_outer << ") ? " << calc_width_inner << " : " << calc_width_outer << ") / " << req_pix_per_calc_pix << ";" << endl;
    } else {
      calc_width = (int)((coord_t)req_width * expansion_factor_3d / req_pix_per_calc_pix) + 1;  // (essentially +1 is round up)
    }
    calc_height = (int)((coord_t)req_height * expansion_factor_3d / req_pix_per_calc_pix) + 1;  // (essentially +1 is round up)

    req_pix_size *= req_pix_per_calc_pix;  // Client scales image based on height, but we should adjust this to be sized
    calc_pix_size = req_pix_size * req_pix_per_calc_pix;
    calc_eye_separation = (coord_t)req_eye_separation / req_pix_per_calc_pix;
  }
  // Pre-computed reciprocals to avoid division.
  calc_pix_per_req_pix = 1.0L / req_pix_per_calc_pix;
  recip_scale_per_depth = 1.0L / scale_per_depth;
  recip_natural_depth = 1.0L / natural_depth;

  calc_center_w = (calc_width  >> 1);
  calc_center_h = (calc_height >> 1);

  if (verbosity > 3)
    cout << "New image: center coords = (" << x << ", " << y << "), req_pix_size = " << req_pix_size
         /* << ", calc_img_size = (" << calc_width << ", " << calc_height << "), calc_center = (" << calc_center_w << ", " << calc_center_h
         << "), spec_max_depth = " << spec_max_depth */ << ", modes = " << modes << ", full = " << full_image << ". ";

  // FPGA image dimensions are restricted.
#ifdef OPENCL
  if (fpga) {
    cout << "Adjusting image sizes for FPGA (if needed)." << endl;
    // FPGA has an upper bound on image size. I don't think this shrinkage will break anything catastrophically, but it's not tested.
    if (calc_width > COLS) {calc_width = COLS;}
    if (calc_height > ROWS) {calc_height = ROWS;}

    // TODO: I think there's currently a limitation that width must be a multiple of 16 for the FPGA.
    //       We will generate an image with width extended to a multiple of 16, where the extended pixels
    //       should not be displayed (because the redered image for 3D is sized to support the requested size).
    int multiple = 16;
    calc_width = (calc_width + multiple - 1) / multiple * multiple;  // Round up depth array width to nearest 16.
  }
#endif

  start_darkening_depth = getZoomDepth() - eye_adjust - (coord_t)brighten;   // default assuming no auto-darkening


  if (verbosity > 0)
    cout << "Settings: smooth: " << smooth << ", smooth_texture: " << smooth_texture << ", divergence_fn: " << power_divergence << y_squared_divergence << square_divergence << normal_divergence
         << ", string_lights: " << string_lights << "expansion_factor_3d: " << expansion_factor_3d << "req: (" << req_width << ", " << req_height << "), calc: (" << calc_width << ", " << calc_height << ")" << endl;
}


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
  return x + pix_size * calc_width / 2.0;
};

coord_t MandelbrotImage::getCenterY() {
  return y + pix_size * calc_height / 2.0;
};
*/

// Number of depths zoomed from fit depth.
MandelbrotImage::coord_t MandelbrotImage::getZoomDepth() {
  coord_t pix_y_fit = 4.0L / (coord_t)req_height;  // Pixel size at which plane-0 (the circle) is fit to the image.
  coord_t zoom = req_pix_size / pix_y_fit;
  if (verbosity > 3)
    cout << "{Zoom info: " << pix_y_fit << ", " << zoom << "}. ";
    return log(scale_per_depth, zoom);
}

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
// Lighten/darken by amount (between 0.0..1.0, non-inclusive).
inline void MandelbrotImage::lightenColor(color_t &color, float inv_amount, int component_mask, bool cap) {
  capColorAmount(inv_amount, cap);
  if (verbosity > 0) {
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
  if (verbosity > 0) {
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
    // We make this half-absorbent, meaning half the light of a component color gets absorbed relative to the base color and half is not.
    //int v = (int)((float)(color.component[c]) * amts[c]);  // 100% absorbent
    int v = (int)((float)((color.component[c] + 255) / 2) * amts[c]);  // 50% absorbent
    //int v = (int)(255.0f * amts[c]);  // 0% absorbent
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
  // separation between each plane is scaled by a scaling factor scale_per_depth (< 1.0) from
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
  //     1/scale_per_depth of scaling, the eye moves inward one depth, and the structure grows by
  //     1/scale_per_depth. So, pixel size determines both the structure size and the depth of the eye.
  //   o The other is determined dynamically, based on the image. This is only possible if the full image
  //     is created (not tiled). The minimum depth found within a given region of the image, is positioned
  //     at a given distance from the eye.
  //
  // Image Generation:
  // ----------------
  // To generate the 3D image, we first generate the 2D image (as a depth array). This defines the
  // cut-outs at each depth. (The cut-out for depth n is where the depth in the depth array > n.)
  // We then ray-trace each pixel of the 3D image through the cut-outs at each depth beyond the eye until
  // a depth is reached where the ray point is not in the cut-out. natural_depth is a scaling
  // factor for the generated image/surface. It specifies the depth at which the 2D image is
  // scaled 1:1 with the 3D image. Since a ray can contact outside the requested 2D image, we
  // generate a larger 2D image than requested. The image must be large enough for the projection
  // of the natural image onto the worst-case maximum depth plane. This is not computed; we
  // use a hardcoded constant, expansion_factor_3d. Eye depth is used to determine where
  // darkening begins if darkening is enabled. Adjustments to scale_per_depth, eye depth, and
  // darkening constant could be provided as user inputs, but currently are not. The shape of
  // each plane is given by the depth data array of the Mandelbrot set already computed.

  // Assumptions:
  //   o pix_size reflect a whole number of depths of zoom. (TODO: Not currently the case, but it looks okay anyway.)
  int direction = right ? -1 : 1;  // Invert calculations for the right eye.
  coord_t center_w_2d = (coord_t)calc_center_w;
  coord_t center_h_2d = (coord_t)calc_center_h;
  coord_t center_w_3d = (coord_t)req_center_w;
  coord_t center_h_3d = (coord_t)req_center_h;
  if (is_stereo) {
    center_w_2d -= (coord_t)direction * (calc_eye_separation / 2.0L);  // Center is where the eye is.
    center_w_3d +=  (coord_t)(direction * req_eye_offset);
  }

  int *depth_array_3d = (int *)malloc(req_width * req_height * sizeof(int));
  if (smooth) {
    fractional_depth_array_3d = (unsigned char *)malloc(req_width * req_height * sizeof(unsigned char));
  }
  if (textured) {
    color_array_3d = (color_t *)malloc(req_width * req_height * sizeof(color_t));
  }

  // Iterate the depths in front of the eye, so begin with the first depth plane in front of the eye.
  int first_depth = ((int)(eye_depth + 1000.0L + 0.01L)) - 1000 + 1;
     // Round up (+1000.0 used to ensure positive value for (int); +0.01 to avoid depth w/ infinite pix_size; +1 to round up, not down).

  //coord_t max_multiplier = 0.0;
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
        coord_t depth_expansion_factor = dist_from_eye * recip_natural_depth;
        /*
        // Check that multiplier doesn't exceed expansion_factor_3d.
        if (depth == max_depth - 1) {
          if (max_multiplier < depth_expansion_factor) {
            max_multiplier = depth_expansion_factor;
          }
        }
        */

        coord_t tmp_mult = depth_expansion_factor * calc_pix_per_req_pix;
        w_2d = round(center_w_2d + w_from_center_3d * tmp_mult);
        h_2d = round(center_h_2d + h_from_center_3d * tmp_mult);
        if (w_2d < 0 || w_2d >= calc_width ||
            h_2d < 0 || h_2d >= calc_height) {
          // Outside the 2d image. Make everything solid starting w/ depth 0.
          if (depth >= 0) {
            cout << "Looking outside 2D image: (" << depth << ": {" << w_3d << ", " << h_3d << "} [" << w_from_center_3d << ", " << h_from_center_3d << "] " << "tmp_mult: " << tmp_mult << " [" << center_w_2d << ", " << center_h_2d << "]  " << w_2d << ", " << h_2d << "). " << flush;
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
        depth_separation *= scale_per_depth;
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
              if (shadow_interior) {
                color = BLACK;
              } else {
                color = depthToColor(depth, 0);
                darkenForDepth(color, depth, 0);
              }
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

  eye_depth = (auto_dive ? (coord_t)(((auto_depth << 8) + auto_depth_frac)) / 256.0L : getZoomDepth()) - eye_depth_fit - eye_adjust;
  if (verbosity > 3)
    cout << "Eye depth: " << eye_depth << ". ";
  // Adjust spot_depth to be relative to eye.
  if (show_spot) {
    spot_depth = (int)eye_depth + natural_depth + spot_depth;  // somewhere in front of the screen (because its not adjusted for changing separation of depths)
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




// Convert x,y coordinates to an angle (float).
// Rightward will be 0.0, extending positive in a counterclockwise direction and negative clockwise to +/-1.0 pointing left.
inline float MandelbrotImage::cartesianToAnglef(float x, float y) {
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
// Convert x,y coordinates to an angle.
// Rightward will be 0.0, extending positive in a counterclockwise direction and negative clockwise to +/-1.0 pointing left.
inline double MandelbrotImage::cartesianToAngle(double x, double y) {
  double ret;
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

// Used for debug to provide output only for the center pixel.
inline bool MandelbrotImage::isCenter(int w, int h) {
  return w == calc_center_w && h == calc_center_h;
}

// Compute the depth of a pixel. Also populate fractional_depth_array and color_array as needed.
// Used by generateMandelbrot.
// TODO: Math would be a little simpler if divergent_radius was always 2.0, and x0 & y0 were scaled down instead.
inline int MandelbrotImage::pixelDepth(int w, int h, bool trying) {

  // Initialization.

  bool high_risk_coastline = false;  // Flag that coastline calculation is bad. This is okay as long as the point is inside the set (max_depth).
  bool coastline_flipped = false;  // For debugging coastline.

  coord_t xx = 0.0;
  coord_t yy = 0.0;

  int depth = 0;
  int frac = 0;   // Fractional depth

  // X0, Y0

  coord_t next_xx = wToX(w);
  coord_t next_yy = hToY(h);


  if (false) {
    // For debug:
    // This generates a square at depth 0.
    bool inside = next_xx < 0.3 && next_xx > -0.3 &&
                  next_yy < 0.3 && next_yy > -0.3;
    depth = inside ? 0 : spec_max_depth;
    frac = 0;
  } else {

    // Configuration of depth calculation.

    // For ornaments:
    bool random_ornaments = false;
    float ornament_probability = 1.0f;
    float ornament_shrink = 0.0f;
    if (ornaments) {
      random_ornaments = getTestFlag(21);
      ornament_probability = getTestVar(11, 0.0, 1.0);
      ornament_shrink = getTestVar(12, 0.0f, 2.0f);
    }
    bool random_lights = false;
    float dim_factor = 0.0f;
    if (string_lights) {
      random_lights = getTestFlag(21);
      dim_factor = 0.0f; // > 0.0f, < 1.0f
    }
    bool coastline_needed = test_texture || random_ornaments || random_lights;


    coord_t scaled_adjustment  = adjustment  * (req_width + req_height) * req_pix_size * 0.06;
    coord_t scaled_adjustment2 = adjustment2 * (req_width + req_height) * req_pix_size * 0.06;


    bool ornament_pixel = false;  // Assert if this pixel is an ornament.
    bool force_diverge = false;  // For special decoration, like ornaments, detected during divergence calculation. Force divergence and provide color.
    color_t color;  // Pixel color.

    // Radial inversion and Xmas settings.
    if (getTestFlag(23) || xmas_theme) {
      if (xmas_theme) {
        divergent_radius = 3.0L;
        divergent_radius_sq = 9.0L;
        random_lights = true;
        dim_factor = 0.3f;
        random_ornaments = true;
        ornament_probability = 0.4f;
        ornament_shrink = 0.35f;
      }
      // To avoid issues w/ 90% angles.
      next_xx += 0.0001L;
      next_yy += 0.0001L;
      // Radially invert so that divergent radius is 0.0 and visa-versa.
      // First go to radial coords, then invert, then go back.
      // to radial
      // Offset slightly from 0,0
      coord_t r = sqrt(next_xx * next_xx + next_yy * next_yy) / 2.0L;
      coord_t a = cartesianToAngle(next_xx, next_yy);  // TODO: This should be double.
      // invert
      if (r > 2.0L) {
        // Max-depth short-circuit.
        depth = spec_max_depth;
        color = inf_color;
        force_diverge = true;
      } else {
        r = (2.0L - r) * (2.0L - r) / 2.0L;
      }
      // back to cartesian
      next_xx = r * sin(a * M_PI);
      next_yy = r * cos(a * M_PI);
    }





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

    // TODO: Through observation: dxx_dx0 == dyy_dy0 and dxx_dy0 == -dyy_dx0. Optimize code for this.
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

    // Each depth doubles the number of times with which the angle cycles going along the border. This value is a reflection of that cycle, though it is not perfect.
    // It can be used for macroscopic patterning.
    unsigned long coastline = 0uL;
    unsigned long coastline_mask = 0uL; // A mask reflecting which bits of coastline are valid. This is (1 << depth) - 1.
    unsigned long next_coastline = 0uL;
    unsigned long next_coastline_mask = 0uL;
    unsigned long coastline_msbs = 0uL;  // The MSBs of coastline. Used to color based on full loop. MSBs of 'coastline' variable can be lost as they shift out.

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
        if (square_divergence && !(xmas_theme && ((depth + color_shift) % 6 == 0))) {
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
        if (ornaments) {
          bool has_ornament = true;
          int ornament = 0;
          if (ornament_probability < 1.0f) {
            int prob16 = (int)(ornament_probability * (float)0xFFFF);
            // Random value seeded by coastline location.
            int val = random_ornaments ? myHash((((int)coastline) << 5) + depth, 16) : (int)coastline;
            has_ornament = (val < prob16) && (depth > 1);
            ornament = (val % 6) + 1;  // Color cube corner colors, except black and white.
          }
          if (has_ornament && !((next_effective_radius_sq > divergent_radius_sq) || (depth >= spec_max_depth))) {
            float outward = ((float)next_xx - (float)next_yy) / divergent_radius / 2.0f;
            if (outward > ornament_shrink) {
              // Inside the ornament.
              ornament_pixel = true;
              // Use ornament (0-6)
              for (int c = 0; c < 3; c++) {
                color.component[c] = (((ornament >> c) & 1) == 1) ? 0 : 150;
              }
              force_diverge = true;
              // Ornament is inside the edge. Rounding edge effect would put it in complete shadow. Use rounded edge on ornament instead.
              if (round_edges) {
                float beyond = divergent_radius + (outward - ornament_shrink) / 1.5f * divergent_radius; // Divisor increases rounding.
                next_effective_radius_sq = beyond * beyond;
              }
            }
          }
        }
      }

      // Experimental approximations for determining convergence and stopping the search on convergence as well as divergence:
      // These are interesting and worth enabling.
      bool conv = false;
      /*
      // Look at fixed windows of radius history and compare.
      x_hist[depth % 16] = xx * xx + yy * yy;
      // Is there a convergent trend.
      if (depth > 16) {
        coord_t diff = 0.0L;
        for (int i = 0; i < 8; i++) {
          diff += x_hist[(depth - i - 8) % 16] - x_hist[(depth - i ) % 16];
        }
        conv = diff > sqrt(x0 * x0 + y0 * y0);
      }
      */
      /*
      // Keep two weighted radius histories with different decay. If that slower decay has a larger value, there's convergence.
      if (depth == 0) {
        exp = 0.0L;
        exp2 = 0.0L;
      } else {
        exp = 0.95L * exp + 0.05L * (xx * xx + yy * yy);
        exp2 = 0.98L * exp2 + 0.02L * (xx * xx + yy * yy);
      }
      conv = exp < 0.99L * exp2;
      */
      next_diverges = next_effective_radius_sq > divergent_radius_sq ||
                      //next_effective_radius_sq < 0.01 ||  // Creates dots inside (mostly) convergent region.
                      //(dxx_dx0 * dxx_dx0 + dyy_dx0 * dyy_dx0 < 0.01 && depth > 0) ||  // Creates dots inside (mostly) convergent region. (need_derivatives must be true)
                      conv ||
                      force_diverge;


      // DONE?
      if (next_diverges || (depth >= spec_max_depth)) {break;}
      // -----------------------------------------------------------------------------------



      if (coastline_needed) {
        // Coastline location
        // Coastline doubles every depth and stays roughly consistent with splitting the previous depth's locations in half, but not perfectly.
        // We compare the next angle partitioning into four with the predicted partitioning from the current, and make corrections.
        // This works well along the coast, but in the middle the crossover points jump around and one depth to the next. Several depths deeper, the coast can intrude on this
        // instability. The error will be a multiple of two, so within a given multiple of two the algorithm seems to work. This allows for more-macroscopic texturing.
        // There are debug flags to help identify where the algorithm fails.
        // Coastline is zero at 3:00 (yy == 0, xx > 0) and increases clockwise.
        // Next coastline
        // Correction for last coastline component of this coastline.

        if (depth > 0) {  // Depth 0 is a full coastline w/ zero bits - no update.
          // Next coastline.

          // Update LSB based on prediction from current.
          next_coastline = (coastline << 1) + ((yy < 0.0L) ? 1L : 0L);
          next_coastline_mask = (coastline_mask << 1) | 1L;

          bool odd_quadrant = (yy < 0.0f) ^ (xx < 0.0f);
          bool next_odd_half = next_yy < 0.0f;
          // Odd quadrant aligns roughly with next odd half.
          // If not, make a correction.
          if (odd_quadrant != next_odd_half) {
            //if (xx * xx > yy * yy) {
            if (next_xx > 0.0f) {
              // Closer to a crossover than not.
              if (odd_quadrant) {
                next_coastline++;
              } else {
                next_coastline--;
              }
              // Make increment/decrement cyclic.
              next_coastline = next_coastline & next_coastline_mask;
              coastline_flipped = true;
            }
            if (xx < 0.0f) {
              // Correction that was far from crossover.
              high_risk_coastline = true;
            }
          }
        }
      }



      // Update to next
      //

      depth += 1;

      if (coastline_needed) {
        coastline = next_coastline;
        coastline_mask = next_coastline_mask;
        // If all bits of coastline are filled, capture MSBs (coastline LSBs for depths 2..65 (if sizeof(long) is 64).
        if (depth == ((int)sizeof(long) * 8 + 1)) {
          coastline_msbs = coastline;
        }
      }
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



      // Delta sensitivity (x/y dirivatives w.r.t. top-level).
      if (need_derivatives) {
        // Derivatives for this depth.
        // (These assume un-adjusted Mandelbrot equations.)
        next_dxx_dx0 = 2.0L * (xx * dxx_dx0 - yy * dyy_dx0) + 1.0L;
        next_dxx_dy0 = 2.0L * (xx * dxx_dy0 - yy * dyy_dy0);    // TODO: Redundant (== -next_dyy_dx0)
        next_dyy_dx0 = 2.0L * (xx * dyy_dx0 + yy * dxx_dx0);
        next_dyy_dy0 = 2.0L * (xx * dyy_dy0 + yy * dxx_dy0) + 1.0L;  // TODO: Redundant (== next_dxx_dx0)
        assert((next_dxx_dx0 == next_dyy_dy0) && (next_dxx_dy0 == -next_dyy_dx0));  // TODO: Optimize based on this.
      }

      // Mandelbrot equations:
      next_xx = (xx * xx) - (yy * yy) + x0 * getTestVar(9, 0.0f, 2.0f);  // TODO: Optimize by calculating squares only once.
      next_yy = 2.0L * (xx * yy) + y0 * getTestVar(10, 0.0f, 2.0f);
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

    if (fractional_depth_array != NULL || trying) {
      if (depth < spec_max_depth) {
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

    // Provide texture (color of "pixel").
    if (color_array != NULL) {

      // Characterize coloring/shading.

      // Note: Some of this computation could be done once for the image, not for every pixel, but there's deep computation per pixel anyway.
      // Note: Smooth is generally false, so frac is generally 0, but some textures might overlay on a smoothed scheme (that's not a smooth_texture).

      bool smooth_map = ! getTestFlag(7);
      bool no_color_scheme = getTestFlag(12);
      bool radial = getTestFlag(1) || smooth_texture;
      float a_granularity = ((float)(1 << (int)getTestVar(5, 0.0, 12.0))) / 64.0f; //fastPow(2.0L, (double)(int)getTestVar(5, -6.0, 6.0));
      float b_granularity = ((float)(1 << (int)getTestVar(6, 0.0, 12.0))) / 64.0f; //fastPow(2.0L, (double)(int)getTestVar(6, -6.0, 6.0));
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
      bool a_gradient = getTestFlag(17);
      bool b_gradient = getTestFlag(18);
      bool sawtooth_smoothing = getTestFlag(5);
      // Local versions for hacks, so as not to alter the members.
      bool local_string_lights = string_lights;
      bool local_test_texture = test_texture;
      float ambient_illumination = 1.0;
      // For colored lights:
      bool illuminate_surface = false;
      float surface_illumination[3]; // by component
      float light_probability = getTestVar(11, 0.0, 1.0);

      bool color_coastline = getTestFlag(25);
      bool color_coastline_loop = getTestFlag(26);
      bool force_pixel = false;    // Force color to force_color without any shading effects (for debug).
      color_t force_color = BLACK;
      bool coastline_angle_needed = coastline_needed;  // TOOD: && ??.
      bool coastline_fractional_angle_needed = coastline_angle_needed; // TODO: && ??.
      float coastline_angle = 0.0f;
      if (coastline_needed) {
        if (depth < ((int)sizeof(long) * 8 + 1)) {
          // MSBs not already filled and assigned.
          coastline_msbs = coastline << (((int)sizeof(long) * 8 + 1) - depth);
        }
      }

      if (local_string_lights) {
        fade += 0.85f;
        ambient_illumination = 0.5;
      }

      if (fanciful_pattern) {
        radial = false;
        a_gradient = false;
        b_gradient = true;
        b_granularity = 2.0f;
        use_next = true;
        cycle_texture = true;
        invert_radius = false;
        local_test_texture = true;
      }

      if (!no_theme) {
        if (xmas_theme) {
          fade = 0.0;
          light_probability = 0.7f;
          ambient_illumination = 0.85f;
        }
      }


      // Color/shade.

      // Start with non-textured color(s) (unless force_diverge, which already determined color).
      if (!force_diverge) {
        if (no_color_scheme) {
          // Use grey for base color.
          color.component[0] = color.component[1] = color.component[2] = 0x80;
        } else {
          // Use color scheme for base color.
          color = depthToColor(depth, frac);
        }
      }

      if (coastline_angle_needed) {
        coastline_angle = (float)(coastline_msbs >> (unsigned long)((sizeof(long) * 8) - 16)) / (float)0x10000;  // 0.0..1.0
        if (coastline_fractional_angle_needed) {
          if (depth < 16) {
            coastline_angle += (cartesianToAnglef(-xx, -yy) + 1.0f) / (float)(1 << depth);
          }
        }
      }
      if (color_coastline) {
        if (texture_max || depth < spec_max_depth) {
          //color = depthToColor(coastline & 0xf, 0);
          for(int k = 0; k < 3; k++) {
            color.component[k] = active_color_scheme[(((unsigned int)coastline + (unsigned int)color_shift) % 16) % active_color_scheme_size].component[k];
          }
          if ((high_risk_coastline && getTestFlag(20)) | (coastline_flipped && getTestFlag(19))) {
            for(int k = 0; k < 3; k++) {
              force_color.component[k] = 255;
            }
            force_pixel = true;
          }
        }
      }
      if (color_coastline_loop) {
        if (texture_max || depth < spec_max_depth) {
          force_color.component[0] = (unsigned char)(coastline_angle * 255.0f);
          force_color.component[1] = 0;
          force_color.component[2] = (unsigned char)0;
          force_pixel = true;
        }
      }

      if (texture_max || (depth < spec_max_depth)) {
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
        if (local_test_texture &&
            !(xmas_theme && (ornament_pixel || ((depth + color_shift) % 6 == 0)))) {  // For Xmas, only texture the tree (no ornaments or ribbons).
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
          if (use_derivatives) {
            // Override x,y to reflect sensitivity of x,y to delta x0,y0 (square of derivatives).
            if (use_next) {
              x = next_dxx_dx0;
              y = next_dyy_dx0;
            } else {
              x = dxx_dx0;
              y = dyy_dx0;
            }
            float factor = req_pix_size * req_height * getTestVar(11, 0.0L, 1.0L);  // Normalize to a percentage of the image height. (Overload another variable for this factor.)
            x *= factor;
            y *= factor;
            r_sq = x * x + y * y;
          }

          // A/B are coordinates based in some way on x/y or next_x/y.
          if (radial) {
            // Use radial coords.
            // b is radius.
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
            a = cartesianToAnglef(x, y);  // -1.0..1.0
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
            if (scaled_a >= 2.0f) {
              scaled_a = 1.9999f;
            } else if (scaled_a < 0.0f) {
              scaled_a = 0.0f;
            }
            if (scaled_b >= 2.0f) {
              scaled_b = 1.9999f;
            } else if (scaled_b < 0.0f) {
              scaled_b = 0.0f;
            }
          }

          float a_inv_amt = smooth_map ? scaled_a / 2.0f - floor(scaled_a / 2.0f) : ((int)scaled_a % 2 == 0) ? 0.75f : 1.0f;
          float b_inv_amt = smooth_map ? scaled_b / 2.0f - floor(scaled_b / 2.0f) : ((int)scaled_b % 2 == 0) ? 0.75f : 1.0f;
          if (a_gradient) {lightenColor(color, a_inv_amt, a_component_mask);}
          if (b_gradient) {darkenColor(color, b_inv_amt, b_component_mask);}
          /*
          if (isCenter(w, h)) {
            cout << "("<< x << ", " << y << ")" << "[" << dxx_dx0 << ", " << dxx_dy0 << "|" << dyy_dx0 << ", " << dyy_dy0  << "]" << "{" << a << ", " << b << "}" << endl;
            force_pixel = true;
            force_color.component[0] = 255; force_color.component[1] = 255; force_color.component[2] = 255;
          }
          */

          if (false) { // dark for big radius values
            float big_bound = 0.9f;
            bool big = a > big_bound;
            if (big) {
              color = BLACK;
            }
          }
        }
        if (local_string_lights || getTestFlag(24)) {
          // String lights.

          // Decide which light to use for this pixel or none.
          float diag_dist = ((float)xx + (float)yy) / divergent_radius / 2.0f;
          bool even_light = diag_dist > 0.0f;  // Each coastline position has two lights.
          bool has_light = true;
          int light = 0; // 0-6 color of light. (Each 0 bit is a color component at max.)
          bool use_depth_color = false;  // true to depth color as light color.
          if (random_lights) {
            int prob16 = (int)(light_probability * (float)0xFFFF);
            // Correction for coastline cut-off (so entire light is within a single coastline value).
            long adj_coast = coastline;  // Determines whether light exists and its color.
            if (even_light && yy < 0.0L) {
              adj_coast = (adj_coast + 1);
            }
            int val = myHash(((int)(adj_coast & 0x1FL & coastline_mask) >> 1) + even_light + (cycle << 6) + (depth << 9), 16);
            has_light = prob16 > val;
            light = ((val >> 16) ^ (val)) % 0x7;
          }

          // Illuminate the light.
          if (has_light) {
            // Corner to color.
            float dist = diag_dist - dim_factor;
            if (dist > 0.0f) {
              illuminate_surface = true;
              float diag_dist_sq = dist * dist;
              float factor = light_brightness * diag_dist_sq;
              if (use_depth_color) {
                for (int c = 0; c < 3; c++) {
                  surface_illumination[c] = (float)(light_color.component[c]) / 255 * factor;
                }
              } else {
                // Use light (0-6)
                for (int c = 0; c < 3; c++) {
                  surface_illumination[c] = (((light >> c) & 1) == 1) ? 0.0f : 0.8f * factor;
                }
              }
            }
          } else {
            illuminate_surface = false;
          }
        }
        if (scales) {
          //...
        }
      }

      // Apply illumination and colored illumination to surface and shadow to rounded edge.

      // Shadow the outer edge using a parabolic (of parabolic segment) drop just before edge.
      // Apply ambient and surface illumination.
      if (lighting) {
        // Illumination
        float illum[3];
        for (int c = 0; c < 3; c++) {
          illum[c] = ambient_illumination + (illuminate_surface ? surface_illumination[c] : 0.0f);
        }
        illuminateColor(color, illum);
        // Apply rounded corner.
        float divergence;
        if (round_edges && (((divergence = next_effective_radius_sq / divergent_radius_sq - 1.4f)) < 0.0f)) {
          divergence *= divergence;
          darkenColor(color, (1.0f - divergence * 3.0f), 7, true);
        }
      }
      // Apply color.
      color_array[h * calc_width + w] = force_pixel ? force_color : color;
    }

  }

  // Darken heuristic
  // If this pixel is within the rectangle used to determine auto-depth, see if we found the lowest depth yet, and if
  // we did, update spec_max_depth to reflect it to save time in the future.
  updateAutoDepth(w, h, w, h, depth, frac);

  return depth;
}



int MandelbrotImage::tryPixelDepth(int w, int h) {
  return pixelDepth(w, h, true);
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
  auto_depth = spec_max_depth;  // reduced dynamically
  auto_depth_frac = 0;
  // Use a different auto-depth bounding box for different modes:
  //   2-D: Auto-depth (darkening) at depth that touches 2/3-scaled requested rectangle.
  //   3-D: Auto-depth (darkening and screen depth) at depth that touches 3/4-scaled requested rectangle.
  //   Stereo 3-D: Auto-depth (darkening) and screen depth) at depth touching rectangle between eyes in width and 3/4 requested height.
  auto_depth_w = is_stereo ? req_eye_separation / 2 :   // Align the eye with auto-depth (screen depth)
                 is_3d     ? (req_width * 3 / 4) / 2 :  // 3/4-scaled center rectangle touches auto-depth (screen depth)
                             (req_width * 2 / 3) / 2;   // 2/3-scaled center rectangle touches auto-depth.
  auto_depth_h = is_stereo ? (req_height * 3 / 4) / 2 :
                 is_3d     ? (req_height * 3 / 4) / 2 :
                             (req_height * 2 / 3) / 2;
}


// Allocate and fill depth_array and fractional_depth_array and/or color_array as needed.
// For textured, color is computed and depth need only be captured if 3-D.
// This also determines auto_depth and max_depth.
// TODO: This is now misnamed.
MandelbrotImage *MandelbrotImage::generateMandelbrot() {
  startTimer();
  debug_cnt = 0;

  // Since auto_depth can be used to determine darkening which determines spec_max_depth, we don't know max_depth
  // before we need it. To address this, we determine an initial conservative value for auto_depth to use here
  // by trying the four corners of the rectangle within which we look for depth. Likely these will find the
  // least depth. If not, we waste some time. Depth array may fill with values > max_depth. Max depth is updated
  // as each pixel is processed.
  //
  // For FPGA computation of depth_array, auto_depth is set based on a 16x16 image in
  // this bounding box, and is not updated during computation.
  //
  setAutoDepthBounds();
  adjust_depth = 0.0f;
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
  if (!textured || is_3d || darken || fpga) {
    depth_array = (int *)malloc(calc_width * calc_height * sizeof(int));
    if (smooth) {
      fractional_depth_array = (unsigned char *)malloc(calc_width * calc_height * sizeof(unsigned char));
    }
  }
  if (textured) {
    color_array = (color_t *)malloc(calc_width * calc_height * sizeof(color_t));
  }


  // Apply adjustments based on auto_depth, but adjustments must be applied as depths are computed, so we use this
  // initial approximation.
  if (adjust) {
    // Matched to eye depth.
    adjust_depth = start_darkening_depth;  // Begin adjustment where we begin darkening (both should be around first visible level)
  }
  if (verbosity > 3)
    cout << "adjust: " << adjust << ", adjust_depth: " << adjust_depth << ", auto_depth" << auto_depth << ", adjustment: " << adjustment << ", smooth: " << smooth << flush;

  generateMandelbrotGuts();

  // Max depth is no longer speculative.
  max_depth = spec_max_depth;

  // Darkening for depth can only be applied once auto-depth is computed (which it now is).
  darkenDepthArray();

  if (debug_cnt > 0) {
    cout << "\nDebug cnt: " << debug_cnt << endl;
  }
  stopTimer("generateMandelbrot()");

  return this;
}

void MandelbrotImage::generateMandelbrotGuts() {
  for (int h = 0; h < calc_height; h++) {
    for (int w = 0; w < calc_width; w++) {
      int depth;
      depth = pixelDepth(w, h, false);
      writeDepthArray(w, h, depth);  // TODO: Move back into pixelDepth.
    }
  }

  if (verbosity > 3)
    cout << ", auto_depth: " << auto_depth << ", brighten: " << brighten << ". ";
}

// Set spec_max_depth based on darkening. This must be called multiple times because auto_darken is determined
// dynamically during depth array generation. We conservatively estimate first, then correct if necessary.
void MandelbrotImage::updateAutoDepth(int new_auto_depth, unsigned char new_auto_depth_frac) {
  if ((new_auto_depth << 8) + (int)new_auto_depth_frac < (auto_depth << 8) + (int)auto_depth_frac) {
    auto_depth = new_auto_depth;
    auto_depth_frac = new_auto_depth_frac;
    if (auto_darken) {
      start_darkening_depth = ((float)((auto_depth << 8) + (int)auto_depth_frac)) / 256.0f - eye_adjust - (coord_t)brighten;
      int dark_depth = (int)start_darkening_depth + half_faded_depth * 6;  // Light fades exponentially w/ depth. After 6 half_faded_depth's, brightness is 1/32.
      if (spec_max_depth > dark_depth) {
        spec_max_depth = dark_depth;
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
    generateMandelbrot();
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

  if (verbosity > 3)
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
    toPixelData(0, depth_array, fractional_depth_array, color_array);
    if (is_stereo) {
      // Generate the stereo image
      toPixelData(req_width * 3, right_depth_array, right_fractional_depth_array, right_color_array);
    }
  }

  stopTimer("generatePixels()");

  if (verbosity > 3)
    cout << endl;

  return this;
};


void MandelbrotImage::darkenDepthArray() {
  // Darken for depth.
  if (darken && (color_array != NULL)) {
    for (int h = 0; h < calc_height; h++) {
      for (int w = 0; w < calc_width; w++) {
        int i = h * calc_width + w;
        darkenForDepth(color_array[i], depth_array[i], smooth ? fractional_depth_array[i] : (unsigned char)0);
      }
    }
  }
}


inline void MandelbrotImage::darkenForDepth(color_t &color, int depth, int fractional_depth) {
  if (depth >= max_depth) {
    assert(max_depth > 0);
    color = inf_color;  // Set here because max_depth is known.
  } else {
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
}
inline MandelbrotImage::color_t MandelbrotImage::depthToColor(int depth, int fractional_depth) {
  color_t color = inf_color;
  if (depth >= spec_max_depth) {
    // darkenForDepth(..) is responsible for setting pixel color based on max_depth. Max_depth may not be known here.
    if (verbosity > 0 && !texture_max) {
      // For debug, set color to red to make sure it is overridden.
      // (Not if texture_max, in which case a real color is needed.)
      color.component[0] = 255; color.component[1] = 0; color.component[2] = 0;
    }
  } else if (depth < 0) {
    color.component[0] = 255; color.component[1] = 255; color.component[2] = 255;
  } else {
    int color_depth = depth + color_shift;
    if (no_theme) {
      // Use color scheme.
      for(int k = 0; k < 3; k++) {
        if (smooth) {
          color.component[k] = (unsigned char)(((int)(active_color_scheme[color_depth % active_color_scheme_size].component[k]) * (256 - fractional_depth) +
                                                (int)(active_color_scheme[(color_depth + 1) % active_color_scheme_size].component[k]) * fractional_depth) / 256) ;
        } else {
          color.component[k] = active_color_scheme[color_depth % active_color_scheme_size].component[k];
        }
      }
    } else {
      // Hard-coded cholor scheme.
      if (xmas_theme) {
        if ((color_depth % 6) == 0) {
          color.component[0] = 255;
          color.component[1] = 0;
          color.component[2] = 0;
        } else {
          color.component[0] = 0;
          color.component[1] = 80;
          color.component[2] = 20;
        }
      }
    }
  }
  return color;
}

void MandelbrotImage::toPixelData(int char_offset, int *depth_array, unsigned char *fractional_depth_array, color_t *color_array) {

  int j = 0;
  int i = 0;  // Char position within pixel_array.

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
        pixel_data[i+k+char_offset] = color.component[k];
      }

      j++;
      i += 3;
    }
    if (is_stereo) {
      i += req_width * 3;  // Skip over other eye.
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
  unsigned error = lodepng_encode24(&png, png_size_p, pixel_data, req_width * (is_stereo ? 2 : 1), req_height);
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

// Allocate a simple ROYGBP color scheme.
MandelbrotImage::color_t * MandelbrotImage::allocRainbowColorScheme(int &size) {
  size = 6;
  color_t * color_scheme = (color_t *) malloc(sizeof(color_t) * size);
  for (int i = 0; i < 3; i++) {
    color_scheme[i*2].component[(i + 0) % 3] = 255;
    color_scheme[i*2].component[(i + 1) % 3] = 0;
    color_scheme[i*2].component[(i + 2) % 3] = 0;
    color_scheme[i*2+1].component[(i + 0) % 3] = 255;
    color_scheme[i*2+1].component[(i + 1) % 3] = 255;
    color_scheme[i*2+1].component[(i + 2) % 3] = 0;
  }
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




// TODO: Cleanup (after this is working on FPGA).
void HostMandelbrotApp::get_image(int sock) {

  json json_obj = read_json(sock);
  //cout << "C++ read JSON: " << json_obj << endl;

  MandelbrotImage * mb_img_p = newMandelbrotImage(json_obj);

  int * depth_data = NULL;
#ifdef OPENCL
  if (mb_img_p->fpga) {
    input_struct input;

    // Determine autodepth by generating a coarse-grained image for the auto-depth bounding box (using current spec_max_depth (max_depth from request)).
    if (mb_img_p->auto_dive || mb_img_p->auto_darken) {
      cout << "Determining depth by pre-computing small image (" << mb_img_p->auto_dive << ", " << mb_img_p->auto_darken << ")." << endl;
      mb_img_p->setAutoDepthBounds();
      input.width = 16;
      input.height = 8;
      input.coordinates[0] = mb_img_p->wToX(mb_img_p->calc_center_w - mb_img_p->auto_depth_w);
      input.coordinates[1] = mb_img_p->hToY(mb_img_p->calc_center_h - mb_img_p->auto_depth_h);
      input.coordinates[2] = mb_img_p->calc_pix_size * mb_img_p->auto_depth_w * 2 / (input.width - 1);
      input.coordinates[3] = mb_img_p->calc_pix_size * mb_img_p->auto_depth_h * 2 / (input.height - 1);
      input.max_depth = (long)(mb_img_p->spec_max_depth);

      // Generate this coarse image on FPGA (allocated by handle_get_image).
      // TODO: Hmmm... currently depths are modulo 256, so this approach won't work well.
      handle_get_image(sock, &depth_data, &input);

      // Scan all depths to determine auto-depth.
      for (int w = 0; w < input.width; w++) {
        for (int h = 0; h < input.height; h++) {
          mb_img_p->updateAutoDepth(depth_data[h * input.width + w], (unsigned char)0);
        }
      }
      free(depth_data);
    } else {
      cout << "(No auto-depth determination needed for FPGA image.)" << endl;
    }

    // Populate depth_data from FPGA.
    // X,Y are center position, and must be passed to FPGA as top left.
    input.coordinates[0] = mb_img_p->wToX(0);
    input.coordinates[1] = mb_img_p->hToY(0);
    input.coordinates[2] = mb_img_p->calc_pix_size;
    input.coordinates[3] = mb_img_p->calc_pix_size;
    input.width  = (long)(mb_img_p->getDepthArrayWidth());
    input.height = (long)(mb_img_p->getDepthArrayHeight());
    input.max_depth = (long)(mb_img_p->spec_max_depth);  // may have been changed based on auto-depth.

    handle_get_image(sock, &depth_data, &input);

    // TODO: Cut-n-paste.
    // Max depth is no longer speculative.
    mb_img_p->max_depth = mb_img_p->spec_max_depth;
    // Darkening for depth can only be applied once auto-depth is computed (which it now is).
    mb_img_p->darkenDepthArray();

  }
#endif

  mb_img_p->generatePixels(depth_data);  // Note that depth_array is from FPGA for OpenCL (and given here to mb_img to free), or NULL to generate in C++.

  size_t png_size;
  unsigned char *png;
  png = mb_img_p->generatePNG(&png_size);

  //cout << "C++ Image Generated" << endl;

  // Call the utility function to send data over the socket
  handle_read_data(sock, png, (int)png_size);
  delete mb_img_p;
}
