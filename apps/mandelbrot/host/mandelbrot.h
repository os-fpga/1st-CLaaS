#include <stdio.h>
#include <cstdlib>
#include <assert.h>
#include <iostream>
#include <stdint.h>
#include <string>
#include <time.h>
#include <cmath>
#include "lodepng.h"

using namespace std;

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
  typedef long double coord_t;
  
  //
  // Constructors (with optional arguments for some settings)
  //
  
  MandelbrotImage(bool _is_3d = false, bool _darken = false);
  MandelbrotImage(double *params, bool _is_3d = false, bool _darken = false);  // Construct, setColorScheme(), setBounds(), generateImage()
  ~MandelbrotImage();
  
  
  //
  // Configuration Methods
  //
  
  // Set data from an array of double-precision parameter values (as passed from webserver over socket).
  MandelbrotImage * setBounds(double *params);
  // Enable 3D effect.
  MandelbrotImage * enable3D();
  // Set to default color scheme.
  MandelbrotImage * setColorScheme();  // (Currently taken care of by construction.)
  // Enable time reporting at varying levels.
  // Levels are:
  //   0: nothing
  //   1: construction to destruction (not currently supported)
  //   2: each step
  //   3: (1 & 2) (not currently supported)
  MandelbrotImage * enableTimer(int level = 2);  
  
  //
  // Compute Methods
  //
  
  // Generate the depth array for the image.
  // Generate an image from parameters and depth data.
  MandelbrotImage * generateDepthArray();
  // Convert the depth array into one that has been adjusted for 3-D. This will alter the size of the image
  // according to parameters. Each layer is more distant, centered around the center of the image.
  // It is not necessary to call this explicitly, as it is called by generagePixels(..) based on settings.
  MandelbrotImage * make3d();
  
  
  //
  // Generate Pixels
  //
  
  // Generate pixel color data according to the color scheme from a [width][height] array of pixel depths.
  // The depths array can be:
  //   - provided as an argument
  //   - have been produced already
  //   - be generated automatically if necessary, internal to this method (via generateDepthArray())
  MandelbrotImage * generatePixels(int *data = NULL);
  
  
  //
  // Produce Image
  //
  
  // Generate a PNG image from the pixel data.
  // If generatePixels() has not been called, it will be called by this method.
  unsigned char * generatePNG(size_t *png_size_p);
  

private:
  
  // Types
  
  typedef union {
    int color;
    unsigned char component[3];
  } color_t;

  /*
  typedef struct color_transition {
    color_t color_transition[256];
  } color_transition_t;
  */

  // 3-D parameters
  static const int RESOLUTION_FACTOR_3D;  // Multiply hight/width by this factor for 3D to pad edges (non-integer would require care).
  static const coord_t SCALE_PER_DEPTH;  // The scale of the 3D object, grows by 1/SCALE_PER_DEPTH with each depth of zoom. Empirical.
                                         // To look deeper as we zoom, go further from 1.0. Note that zooming should be in depth
                                         // increments, so the controlling software should be in sync with this factor.
  static const coord_t NATURAL_DEPTH;  // Depth from eye at which the 3D scaling factor == the 2D scaling factor.
  static const coord_t EYE_DEPTH_FIT;  // Depth from the eye of the plane-0 circle when 2D-scaled to fit (height).
  //

  static bool static_init_done;
  static int default_color_scheme_size;  // Size of default_color_scheme.
  static color_t *default_color_scheme;  // The default color scheme.
  
  int timer_level;
  // check timing
  timespec timer_start_time;


  color_t * color_scheme;  // The color scheme (not freed)
  int color_scheme_size;   // The number of colors in color_scheme.
  int width, height;  // Image size in pixels.
  coord_t x, y;  // Position of the upper-left corner of the image.
  coord_t pix_x, pix_y;  // Size of a pixel.
  int max_depth;  // Max number of iterations for Mandelbrot calculation.
  bool is_3d;
  coord_t adjustment; // A parameter that can be varied to impact the mandelbrot algorithm (exactly how is currently a matter of experimentation.)
  
  // For darkening distant 3D depths.
  bool darken;
  int start_darkening_depth;
  int half_faded_depth;

  // Storage structures. These are freed upon destruction.
  int *depth_array;  // Image array of depth integers.
  unsigned char *pixel_data;  // Pixel data for the set, as int [component(R,G,B)][width][height].
  unsigned char *png;  // The PNG image.

  // Center points.
  //-coord_t getCenterX();
  //-coord_t getCenterY();
  void startTimer();
  timespec stopTimer(string tag);
  void stopStartTimer(string tag);
  int *get_bits(int n, int bitswanted);
  int extract_bits(int value, int bit_quantity, int start_from);
  color_t * allocGradientsColorScheme(int &, int, int);
  color_t * allocRandomColorScheme(int &, int);
  coord_t log(coord_t base, coord_t exp);
  
};
