class MandelbrotSettings {
  //   max_depth: Max number of iterations for calculation.
  //   renderer: "python", "cpp", or "fpga".
  //   brighten: depth by which to adjust the start of darkening.
  //   eye_adjust: adjustment in depths for the position of the eye.
  //   var1/var2: Integer variables that influence the image.
  //   three_d: 3-D image.
  //   eye_separation: separation of eyes in pixels.
  //   image_separation: separation of stereo images in pixels.
  //   darken: Flag to enable darkening of inner depths.
  //   smooth: Flag to enable smoothing.
  //   full_image: Flag indicating that this is a full image, which can enable auto adjustments.
  //   colors: Encoded bits that control the color scheme.
  //   spot_depth: Depth of a spot used to help find stereo image.
  //   colors: An encoded representation of color scheme.
  //   texture: An encoded representation of texture.
  //   edge_style: An encoded representation of the edge style (aka divergence function).
  //   theme: An encoded representation of the pre-defined theme to apply (0 for none).
  //   cast_tag: Tag/directory to which to "cast" images.
  //   test_flags/vars: Flags/variables (as an array) for testing.
  constructor() {
  }
  
  set(max_depth, renderer, brighten, eye_adjust, var1, var2,
      three_d, stereo, eye_separation, image_separation, darken, smooth, full_image, spot_depth, colors, texture, edge_style, theme, cycle, cast_tag, test_flags, test_vars, updateTimeBasedSettingsFn) {
    this.max_depth = max_depth;
    this.renderer = renderer;
    this.brighten = brighten;
    this.eye_adjust = eye_adjust;
    this.var1 = var1;
    this.var2 = var2;
    this.three_d = three_d && full_image;  // No 3-d if tiled.
    this.darken = darken;
    this.stereo = stereo;
    this.eye_separation = eye_separation;
    this.image_separation = image_separation;
    // For stereoscopic images, the given parameters are for an eye between the two eyes. These provide
    // adjustments from that point for each eye.
    // For stereoscopic images, the horizontal (width) offset from the center of the left image of the vanishing point (negative of this for right).
    this.center_offset = this.stereo ? parseInt((image_separation - eye_separation) / 2.0) : 0;
    this.smooth = smooth;
    this.full_image = full_image;
    // TODO: Replace transmission of individual fields with just modes.
    this.modes =
         (((this.renderer == "python") ? 1 : 0) << 0) |
         (((this.renderer == "cpp") ? 1 : 0) << 1) |
         (((this.renderer == "fpga") ? 1 : 0) << 3) |  // enable optimizations currently using FPGA setting
         (((this.full_image) ? 1 : 0) << 6) |  // full image render
         ((this.smooth ? 1 : 0) << 7);
    this.spot_depth = spot_depth;
    this.colors = colors;
    this.texture = texture;
    this.edge_style = edge_style;
    this.theme = theme;
    this.cycle = cycle; // Time-based value. (Set by updateTimeBasedSettings().)
    this.cast_tag = cast_tag;
    this.test_flags = test_flags;
    this.test_vars = [];
    for (let i = 0; i < test_vars.length; i++) {
      this.test_vars[i] = test_vars[i];
    }
    // Initially an empty function.
    this.updateTimeBasedSettingsFn = updateTimeBasedSettingsFn;
    return this;
  }
  
  updateTimeBasedSettings(ms) {
    this.updateTimeBasedSettingsFn(this, ms);
  }
  
  copy() {
    return new MandelbrotSettings().set(this.max_depth, this.renderer,
                                        this.brighten, this.eye_adjust, this.var1, this.var2, this.three_d, this.stereo, this.eye_separation,
                                        this.image_separation, this.darken, this.smooth, this.full_image, this.spot_depth, this.colors, this.texture,
                                        this.edge_style, this.theme, this.cycle, this.cast_tag, this.test_flags, this.test_vars, this.updateTimeBasedSettingsFn);
  }
  
  equals(settings2) {
    let test_vars_match = this.test_vars.length == settings2.test_vars.length;
    for (let i = 0; i < this.test_vars.length; i++) {
      test_vars_match = test_vars_match && (this.test_vars[i] == settings2.test_vars[i]); 
    }
    return settings2 != null &&
           this.max_depth == settings2.max_depth &&
           //-this.renderer == settings2.renderer &&
           this.brighten == settings2.brighten &&
           this.eye_adjust == settings2.eye_adjust &&
           this.var1 == settings2.var1 &&
           this.var2 == settings2.var2 &&
           this.three_d == settings2.three_d &&
           this.stereo == settings2.stereo &&
           (!this.stereo || (this.eye_separation == settings2.eye_separation &&
                             this.image_separation == settings2.image_separation)) &&
           this.darken == settings2.darken &&
           //-this.smooth == settings2.smooth &&
           this.modes == settings2.modes &&
           this.colors == settings2.colors &&
           //-this.full_image == settings2.full_image &&
           this.spot_depth == settings2.spot_depth &&
           this.test_flags == settings2.test_flags &&
           this.texture == settings2.texture &&
           this.edge_style == settings2.edge_style &&
           this.theme == settings2.theme &&
           this.cycle == settings2.cycle &&
           this.cast_tag === settings2.cast_tag &&  // (Not necessary to assert settings change when casting is disabled, but we do.)
           test_vars_match;
  }
  
  
  // Merge into the JSON object expected in the URL. (There is no need for some of these names to differ.)
  getJSONObj(json_obj) {
    return Object.assign(
      json_obj,
      this.mapQueryArgsObj(),
      {
        three_d: this.three_d,
        offset_w: this.center_offset,
        offset_h: 0,
        eye_sep: (this.stereo ? this.eye_separation : 0),
        eye_adjust: this.eye_adjust
      },
      (this.spot_depth < 0) ? {} : {spot_depth: this.spot_depth},
      this.cycle ? {cycle: this.cycle} : {},
      this.cast_tag ? {cast: this.cast_tag} : {}
    );
  }
  
  mapQueryArgsObj() {
    let ret = {
      test_flags: this.test_flags,
      darken: this.darken,
      brighten: this.brighten,
      modes: this.modes,
      colors: this.colors,
      texture: this.texture,
      edge: this.edge_style,
      var1: this.var1,
      var2: this.var2,
      renderer: this.renderer,
      theme: this.theme,
      test_vars: this.test_vars
    };
    return ret;
  }
  
  mapQueryArgs() {
    return `json=${JSON.stringify(this.mapQueryArgsObj(), null, 0)}`;
  }
  
  mapQueryArgsOld() {
    let test_args = "&test_flags=" + this.test_flags;
    for (let i = 0; i < this.test_vars.length; i++) {
      test_args += `&test${i}=${this.test_vars[i]}`;
    }
    return "darken=" + this.darken + "&brighten=" + this.brighten + "&modes=" + this.modes +"&colors=" + this.colors + "&texture=" + this.texture + "&edge=" + this.edge_style +
           "&var1=" + this.var1 + "&var2=" + this.var2 + "&renderer=" + this.renderer + "&theme=" + this.theme + test_args;
  }
}


class MandelbrotView {
  // Params:
  //   center_x/y: Mandelbrot coords of center point.
  //   scale: 1 is Mandelbrot circle fit to image height.
  //   height/width: Image height/width.
  constructor(center_x, center_y, scale, width, height, settings) {
    this.center_x = center_x;
    this.center_y = center_y;
    this.height = height;  // Image height/width.
    this.width = width;
    this.scale = scale;   // One level for each factor of e (Euler's constant).
    this.settings = settings;
  }
  
  // Setters/Getters
  set height(v) {this._height = v;}
  get height() {return this._height;}
  set width(v) {this._width = v;}
  get width() {return this._width;}
  
  set zoom_level(v) {this._zoom_level = v;}
  get zoom_level() {return this._zoom_level;}
  
  set scale(v) {this.zoom_level = Math.log(v);}
  get scale() {return Math.exp(this.zoom_level);}
  
  // Scale of 1.0 has size_y of 4.0.
  get image_size_x() {return this.pix_size_x * this.width;}
  get image_size_y() {return 4 / this.scale;}
  
  // Bound and center coordinates.
  set center_x(v) {this._center_x = v;}
  get center_x() {return this._center_x;}
  set center_y(v) {this._center_y = v;}
  get center_y() {return this._center_y;}
  // These would need center_offset applied, but not used anyway:
  //get left_x() {return this.center_x - this.image_size_x / 2;}
  //get top_y() {return this.center_y - this.image_size_y / 2;}
  //get right_x() {return this.center_x + this.image_size_x / 2;}
  //get bottom_y() {return this.center_y + this.image_size_y / 2;}
  
  // Pixel x/y are same, based on height.
  get pix_size_x() {return this.pix_size_y;}
  get pix_size_y() {return this.image_size_y / this.height;}
  
  set max_depth(v) {this._max_depth = v;}
  get max_depth() {return this._max_depth;}
  
  //get x_offset() {return this.stereo ? - this.eye_separation / 2.0 * this.pix_size_x : 0.0;}

  
  // Copy "constructor".
  // Optional settings arg. If not provided a copy of the original settings is created.
  copy(settings) {
    return new MandelbrotView(this.center_x, this.center_y, this.scale, this.width, this.height, settings ? settings : this.settings.copy());
  }
  
  // Image comparison.
  equals(img2) {
    // Compare using same parameters as construction. Even through these aren't necessarily the object properties,
    // it's easier not to miss something.
    return img2 != null &&
           this.center_x == img2.center_x &&
           this.center_y == img2.center_y &&
           this.scale == img2.scale &&
           this.height == img2.height &&
           this.width == img2.width &&
           this.settings.equals(img2.settings);
  }
  
  // Set position to that of another MandelbrotView.
  // Height and width are not changed.
  positionAs(pos) {
    this.center_x = pos.center_x;
    this.center_y = pos.center_y;
    this.scale = pos.scale;
  }
  
  
  zoomBy(v) {
    this.zoom_level += v;
  }
  zoomByAt(v, offset_x, offset_y) {
    let scale_up = Math.exp(v);
    console.log(`v: ${v}, offset_x: ${offset_x}, offset_y: ${offset_y}, scale_up: ${scale_up}`)
    this.zoom_level += v;
    this.center_x += offset_x * (scale_up - 1) / scale_up;
    this.center_y += offset_y * (scale_up - 1) / scale_up;
  }
  
  scaleBy(v) {
    this.scale *= v;
  }
  
  panBy(horiz_pix, vert_pix) {
    this.center_x -= horiz_pix * this.pix_size_x;
    this.center_y -= vert_pix  * this.pix_size_y;
  }
  
  // Apply change for given delta time at a constant zoom and pan rate.
  // This involves calculus as the rate of change of position changes over time.
  // TODO: Undoubtedly I got the calculus wrong. Debug. Not currently used. Current approach applies deltas
  //       at consistent time deltas.
  zoomAndPan(delta_t, zoom_rate, pan_rate) {
    this.x += pan_rate / zoom_rate * Math.exp(-this.zoom_level) * (1 - Math.exp(-zoom_rate * delta_t))
    this.zoom_level += zoom_rate * delta_t;
  }
  
  getImageURLQueryArgs(extra_params = {}) {
    let json_obj = {
      x: this.center_x,
      y: this.center_y,
      pix_x: this.pix_size_x,
      pix_y: this.pix_size_y,
      width: this.width,
      height: this.height,
      max_depth: this.settings.max_depth
    }
    json_obj = this.settings.getJSONObj(Object.assign(extra_params, json_obj));
    console.log(json_obj);
    return `?json=${JSON.stringify(json_obj, null, 0)}`;
  }
  

  resetPosition() {
    this.center_x = 0.0;
    this.center_y = 0.0;
    this.zoom_level = 0.0;
  }
  
  // Jumps to a good place in the image for trying stereo 3-D.
  goToGoodPlace() {
    this.center_x =  0.43821971;
    this.center_y = -0.34128329;
    this.zoom_level = 7.0;
  }

}
