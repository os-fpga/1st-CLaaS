#ifndef MANDELBROT_H
#define MANDELBROT_H

#include <stdio.h>
#include <cstdlib>
#include <limits.h>
#include <assert.h>
#include <iostream>
#include <stdint.h>
#include <string>
#include <time.h>
#include <cmath>
#include <ieee754.h>
#include "lodepng.h"
#include "server_main.h"

using namespace std;


// TODO: Use this.
class Color {

private:

  void capAmount(float &amount, bool cap) {
    if (cap) {
      if (amount > 1.0L) {
        amount = 1.0L;
      }
      if (amount < 0.0L) {
        amount = 0.0L;
      }
    }
  }
  
public:

  Color(unsigned char r, unsigned char g, unsigned char b) {
    component[0] = r;
    component[1] = g;
    component[2] = b;
  }
  Color(const Color &c) {
    color = c.color;
  }
  
  // Lighten/darken by amout [0.0..1.0]. If outside
  void lightenComponent(int c, float inv_amount) {
    component[c] = (unsigned char)(255 - (int)((float)(255 - (int)(component[c])) * inv_amount));
  }
  void lighten(float inv_amount, bool cap = false) {
    capAmount(inv_amount, cap);
    for (int c = 0; c < 3; c++) {
      lightenComponent(c, inv_amount);
    }
  }
  void darkenComponent(int c, float inv_amount) {
    component[c] = (unsigned char)((float)(component[c]) * inv_amount);
  }
  void darken(float inv_amount, bool cap = false) {
    capAmount(inv_amount, cap);
    for (int c = 0; c < 3; c++) {
      darkenComponent(c, inv_amount);
    }
  }
  
  void blend(Color color2) {
    for (int c = 0; c < 3; c++) {
      component[c] = (unsigned char)((int)(component[c]) + ((int)(color2.component[c]) >> 1));
    }
  }

  union {
    int color;
    unsigned char component[3];
  };
};

/*
 * A class for generating Mandelbrot images (without external assistance).
 *
 * Creating a mandelbrot image with this class requires the following steps:
 *   - Construct.
 *   - Configure.
 *   - Compute (or provide computation) (producing depth data)
 *   - Generate pixels.
 *   - Produce image.
 *
 * Some methods may perform multiple steps (often only if needed).
 *
 */
class MandelbrotImage {
public:
  typedef double coord_t;
  
  // TODO: replace w/ Color.
  typedef union {
    int color;
    unsigned char component[3];
  } color_t;
  
  //
  // Constructors (with optional arguments for some settings)
  //
  
  MandelbrotImage(json &params);
  virtual ~MandelbrotImage();
  
  
  //
  // Produce Image
  //
  
  // Generate a PNG image from the pixel data.
  // If generatePixels() has not been called, it will be called by this method.
  unsigned char * generatePNG(size_t *png_size_p);
  
  // Generate pixel color data according to the color scheme from a [width][height] array of pixel depths.
  // The depths array can be:
  //   - provided as an argument
  //   - have been produced already
  //   - be generated automatically if necessary, internal to this method (via generateMandelbrot())
  MandelbrotImage * generatePixels(int *data = NULL);

protected:
  //
  // Configuration Methods
  //
  
  // Enable time reporting at varying levels.
  // Levels are:
  //   0: nothing
  //   1: construction to destruction (not currently supported)
  //   2: each step
  //   3: (1 & 2) (not currently supported)
  MandelbrotImage * enableTimer(int level = 2);
  
  template <class T>
  void param(const string name, T &var, const T def) {
    try {
      params_json.at(name).get_to(var);
    } catch (nlohmann::detail::type_error) {
      cerr << "Param " << name << " has wrong type." << endl;
      var = def;
    } catch (nlohmann::detail::out_of_range) {
      if (verbosity > 1) {
        cout << "Defaulting param " << name << " = " << def << endl;
      }
      var = def;
    }
  }
  
  template <class T>
  T param(const string name, const T def) {
    T var;
    param(name, var, def);
    return var;
  }
  
  //
  // Compute Methods
  //
  
  // Generate the depth array for the image.
  // Generate an image from parameters and depth data.
  MandelbrotImage * generateMandelbrot();
  virtual void generateMandelbrotGuts();  // The guts of generateMandelbrot().
  // Convert the depth array into one that has been adjusted for 3-D. This will alter the size of the image
  // according to parameters. Each layer is more distant, centered around the center of the image.
  // It is not necessary to call this explicitly, as it is called by generagePixels(..) based on settings.
  MandelbrotImage * make3d();
  
  
  //
  // Generate Pixels
  //
  // Fill one eye of data into pixel_data. 
  //   char_offset: The starting char position to fill (depending on eye).
  void toPixelData(int char_offset, int *depth_array, unsigned char *fractional_depth_array, color_t *color_array);
  
  
  
  // Get depth array dimensions. Initially this is the depth array to generate; after 3D-iffication, this is the requested h/w.
  int getDepthArrayWidth()  {return calc_width; }
  int getDepthArrayHeight() {return calc_height;}
  coord_t wToX(int w) {return x + (w - calc_center_w) * calc_pix_size;}
  coord_t hToY(int h) {return y + (h - calc_center_h) * calc_pix_size;}
  int getMaxDepth() {return max_depth;}

protected:
  friend class HostMandelbrotApp; // TODO: Contains functionality that should be moved here.
  
  // Types

  /*
  typedef struct color_transition {
    color_t color_transition[256];
  } color_transition_t;
  */
  
  int verbosity;  // 0-10 For debug. >0 enables checking.
  int debug_cnt;  // Printed after image generation if non-zero.

  // 3-D parameters
  coord_t expansion_factor_3d; // Multiply hight/width by this factor for 3D (slightly different for stereo) to pad edges.
                               // The real distance at max depth / real distance from eye to screen to account for
                               // x/y visibility at max depth.
  coord_t req_pix_per_calc_pix; // The relationship between the pixel size of the 2d 'calc' image and the 3d requested image pixel size at the screen.
  coord_t scale_per_depth;  // The scale of the 3D object, grows by 1/SCALE_PER_DEPTH with each depth of zoom. Empirical.
                            // To look deeper as we zoom, go further from 1.0. Note that zooming should be in depth
                            // increments, so the controlling software should be in sync with this factor.
  coord_t natural_depth;    // Depth from the eye (really, absolute distance in units of first-depth-distance) of the screen.
  coord_t eye_depth_fit;    // Distance of structure from eye (and structure size). Specifically, for auto-depth, the depth from the eye of the auto-depth,
                            //   and without auto-depth, the depth from the eye of the plane-0 circle when sized to fit the height.
  // Pre-calculated values:
  coord_t calc_pix_per_req_pix; // Inverse of req_pix_per_calc_pix.
  coord_t recip_scale_per_depth; // 1 / scale_per_depth.
  coord_t recip_natural_depth;  // 1 / natural_depth.

  // Several color schemes are statically allocated in an array.
  // A color scheme is some number of color_t's indexed by depth % num_colors.
  static bool static_init_done;
  
  // Color scheme
  static int num_color_schemes;      // The number of color schemes.
  static int * color_scheme_size;   // Size of each color_scheme.
  static color_t ** color_scheme;  // The color schemes.
  int active_color_scheme_index;  // The index of the current color scheme.
  color_t * active_color_scheme;  // The active one.
  int active_color_scheme_size;   // "
  

  json params_json;  // JSON parameters.

  bool electrify;
  int color_shift;
  
  coord_t divergent_radius;
  coord_t divergent_radius_sq;
  

  
  bool fpga;  // True if depths are to be determined by FPGA.
  int auto_depth;   // Heuristically-determined depth of view computed during depth array calculation.
  unsigned char auto_depth_frac;  // Fractional portion of auto_depth.
  bool auto_dive;   // Enable eye movement based on auto_depth (vs. scaling based on zoom).
  bool auto_darken; // Enable darkening based on auto_depth (vs. scaling based on zoom).
  int auto_depth_w, auto_depth_h;
  
  float adjust_depth;   // Depth at which adjustment begins.
  
  int spot_depth;  // Depth of the "spot," used to help lock in on the stereo image. (Initially -1, or 0..n, then adjusted to be relative to eye.)
  bool show_spot;  // Show the spot (spot_depth is initially -1).
  
  bool full_image;   // This is a full image, so decisions can be made with full knowledge (such as darkening and eye depth).
  bool smooth;       // Smooth the image using the approach on wikipedia.
  bool lighting;     // True if any lighting effects are in use.
  bool textured;     // Use color_arrays. Depth alone is not enough to determine color. Each layer has a texture.
  bool smooth_texture; // A different approach to smoothing. This is less computationally-intensive and has a nice property that it does not change coarse-grained depth.
                       // This means texturing effects based on layer edges will remain consistent.
  bool cutouts;      // True to not extend each layer infinitely, but rather treat each layer as a cutout from the one above.
  bool square_divergence;  // Edge style bound by x/y square.
  bool y_squared_divergence;  // Edge style using y-squared, aka "villi".
  bool normal_divergence;  // No special edge style.
  bool power_divergence;  // Edge style x^p + y^p.
  
  bool ornaments;  // Decarate with ornaments.
  
  int test_flags;
  int test_vars[16];
  
  int timer_level;  // 0 to disable timer.
  // check timing
  timespec timer_start_time;

  int req_width, req_height;  // The requested width/height.
  int req_eye_offset;  // Requested eye offset in requested-image pixels.
  coord_t x, y;  // Position of the center of the image.
  coord_t req_pix_size;  // X/Y size of a pixel in requested image.
  coord_t calc_pix_size; // X/Y size of a pixel in the 'calc' image.
  int max_depth;  // Max number of depths for Mandelbrot calculation. This can be determined dynamically.
  int spec_max_depth; // Max depth until it is non-speculative.
  int brighten;  // An adjustment for darkness, as a delta in darken_start_depth.
  coord_t eye_adjust;  // An adjustment for the depth of the eye.
  int req_eye_separation;  // The separation between the eyes in requested image pixels (should be a multiple of 2).
  coord_t calc_eye_separation; // Eye separation in 'calc' image pixels.
  bool is_3d;
  bool is_stereo;
  int req_center_w, req_center_h;  // w/h center point (aka vanishing point) of the requested image in pixel coords.
  coord_t adjustment; // A parameter that can be varied to impact the mandelbrot algorithm (exactly how is currently a matter of experimentation.)
  coord_t adjustment2; // A parameter that can be varied to impact the mandelbrot algorithm (exactly how is currently a matter of experimentation.)
  bool adjust;  // True if an adjustment is non-zero.
  // Texture effects:
  bool test_texture;  // True to enable test textures.
  bool use_derivatives;  // Texture based on derivative values.
  bool string_lights;  // True for string lights texture effect.
  bool fanciful_pattern;  // True for "fanciful" (X-gradient scale-4) texture.
  bool shadow_interior; // True for shadowed layers effect.
  bool round_edges; // True to shade edges between layers for rounded edges effect.
  // Decoding of theme.
  bool no_theme;
  bool xmas_theme;
  int cycle;  // Used to cycle through animation steps.
  
  float light_brightness;
  
  bool need_derivatives; // True if this image calculation needs to compute derivatives.
  int calc_width, calc_height;  // Size of the depth_array to compute. These may differ from req_width/height for 3d and for FPGA with width restrictions.
                                // Updated for 3D-iffied depth array.
  int calc_center_w, calc_center_h;  // Center point in the computed depth_array.
  coord_t eye_depth;  // Depth of the eye.
  
  color_t inf_color;  // Color at infinity.
  static color_t BLACK;
  
  // For darkening distant 3D depths.
  bool darken;
  bool texture_max;  // Color at max_depth (not possible if darken, as this sets max_depth dynamically). Mainly for debug.
  int half_faded_depth;
  float start_darkening_depth;
  
  // Experimental:
  coord_t x_hist[16], y_hist[16];
  coord_t exp; // Experimental
  coord_t exp2; // Experimental too

  // Storage structures. These are freed upon destruction.
  int *depth_array;  // Image array of depth integers.
  unsigned char *fractional_depth_array; // A fractional depth for smoothing. This value / 256 is added to depth (giving the ratio of depth color to depth+1 color).
  color_t *color_array;  // Colors for the image (corresponding to depth_array), used when depth alone is not enough to determine color. (These are later packed into an image.)
  int *right_depth_array; // For stereo images, depth_array is the left eye and this is the right. 
  unsigned char *right_fractional_depth_array;
  color_t *right_color_array;
  unsigned char *pixel_data;  // Pixel data for the set, as int [component(R,G,B)][width][height].
                              // For stereo images, this is a single array for both eyes, left-then-right.
  unsigned char *png;  // The PNG image.

  bool isCenter(int w, int h);  // For debug
  bool getTestFlag(int i) {return (bool)((test_flags >> i) & 1);}
  coord_t getTestVar(int i, coord_t min, coord_t max) {return min + (coord_t)(test_vars[i] + 100) / 200.0L * (max - min);}
  int getTestVar(int i) {return test_vars[i];}

  coord_t getZoomDepth();
  
  void setAutoDepthBounds();
  int pixelDepth(int w, int h, bool need_frac);
  int tryPixelDepth(int w, int h);   // A non-inlined version of pixelDepth.
  void writeDepthArray(int w, int h, int depth);
  void updateAutoDepth(int w1, int h1, int w2, int h2, int depth, unsigned char frac);
  void updateAutoDepth(int new_auto_depth, unsigned char new_auto_depth_frac);
  
  // Used by make3d() to make image for one eye.
  int * makeEye(bool right, unsigned char * &fractional_depth_array_3d, color_t * &color_array);

  // Center points.
  void startTimer();
  timespec stopTimer(string tag);
  void stopStartTimer(string tag);
  int *get_bits(int n, int bitswanted);
  int extract_bits(int value, int bit_quantity, int start_from);
  void completeRGBShiftedColorScheme(color_t *partial_scheme, int partial_size);
  color_t * allocGradientEdgePairColorScheme(int &size, int edge_increments);
  color_t * allocGradientDiagonalColorScheme(int &size, int increments);
  color_t * allocGradientsColorScheme(int &size, int num_gradients, int increments);
  color_t * allocRandomColorScheme(int &size, int num_colors);
  color_t * allocRainbowColorScheme(int &size);
  coord_t log(coord_t base, coord_t exp);
  
  
private:
  color_t depthToColor(int depth, int fractional_depth);
  
  void meldWithColor(color_t &color, color_t color2, float amount, bool cap = false);

  void lightenColor(color_t &color);
  void darkenColor(color_t &color);
  void lightenColor(color_t &color, float inv_amount, int component_mask = 7, bool cap = false);
  void darkenColor(color_t &color, float inv_amount, int component_mask = 7, bool cap = false);
  void darkenForDepth(color_t &color, int depth, int fractional_depth);
  void illuminateColor(color_t &color, float * amts);
  
  float cartesianToAnglef(float xx, float yy);
  double cartesianToAngle(double xx, double yy);

  void capColorAmount(float &amount, bool cap) {
    if (cap) {
      if (amount > 1.0L) {
        amount = 1.0L;
      }
      if (amount < 0.0L) {
        amount = 0.0L;
      }
    }
  }

};

// Inlined public/protected methods.

// Update auto depth (and spec_max_depth) for a given pixel or rectangle at a given depth.
inline void MandelbrotImage::updateAutoDepth(int w1, int h1, int w2, int h2, int depth, unsigned char frac) {
  // Update spec_max_depth. Note, we don't bother to do this if we go sub-pixel, since these are likely deep.
  if (depth <= auto_depth &&  // This is a course filter. It is checked again.
      ((w1 <= calc_center_w + auto_depth_w) ||
       (w2 >= calc_center_w - auto_depth_w)) &&
      ((h1 <= calc_center_h + auto_depth_h) ||
       (h2 >= calc_center_h - auto_depth_h))
     ) {
    updateAutoDepth(depth, frac);
  }
}





// ---------------------------------------------------------------------------------------------------------
class HostMandelbrotApp : public HostApp {

public:

#ifdef OPENCL
  cl_data_types get_image(cl_data_types cl, int sock);
#else
  void get_image(int sock);
#endif
  virtual MandelbrotImage * newMandelbrotImage(json &params) {return new MandelbrotImage(params);} // Can be extented to utilize a derived type.
};


#endif
