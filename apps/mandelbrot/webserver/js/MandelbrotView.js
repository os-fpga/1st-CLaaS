class MandelbrotView {
  // Params:
  //   center_x/y: Mandelbrot coords of center point.
  //   scale: 1 is Mandelbrot circle fit to image height.
  //   height/width: Image height/width.
  //   max_depth: Max number of iterations for calculation.
  constructor(center_x, center_y, scale, height, width, max_depth, renderer, var1, var2, three_d, darken) {
    this.center_x = center_x;
    this.center_y = center_y;
    this.height = height;  // Image height/width.
    this.width = width;
    this.scale = scale;   // One level for each factor of e (Euler's constant).
    this.max_depth = max_depth;
    this.renderer = renderer;
    this.var1 = var1;
    this.var2 = var2;
    this.three_d = three_d;
    this.darken = darken;
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
  get left_x() {return this.center_x - this.image_size_x / 2;}
  get top_y() {return this.center_y - this.image_size_y / 2;}
  get right_x() {return this.center_x + this.image_size_x / 2;}
  get bottom_y() {return this.center_y + this.image_size_y / 2;}
  
  // Pixel x/y are same, based on height.
  get pix_size_x() {return this.pix_size_y;}
  get pix_size_y() {return this.image_size_y / this.height;}
  
  set max_depth(v) {this._max_depth = v;}
  get max_depth() {return this._max_depth;}
  
  
  // Copy "constructor".
  copy() {
    return new MandelbrotView(this.center_x, this.center_y, this.scale, this.height, this.width, this.max_depth, this.renderer, this.var1, this.var2, this.three_d, this.darken);
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
           this.max_depth == img2.max_depth &&
           this.renderer == img2.renderer &&
           this.var1 == img2.var1 &&
           this.var2 == img2.var2 &&
           this.three_d == img2.three_d &&
           this.darken == img2.darken;
  }
  
  
  zoomBy(v) {
    this.zoom_level += v;
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
  // TODO: Undoubtedly I got the calculus wrong. Debug.
  zoomAndPan(delta_t, zoom_rate, pan_rate) {
    this.x += pan_rate / zoom_rate * Math.exp(-this.zoom_level) * (1 - Math.exp(-zoom_rate * delta_t))
    this.zoom_level += zoom_rate * delta_t;
  }
  
  getImageURLParamsArrayJSON() {
    return "[" + this.left_x + "," +
                 this.top_y + "," +
                 this.pix_size_x + "," +
                 this.pix_size_y + "," +
                 this.width + "," +
                 this.height + "," +
                 this.max_depth + "," +
                 this.var1 + "," +
                 this.var2 + "," +
                 this.three_d + "," +
                 this.darken + "]";
  }
}
