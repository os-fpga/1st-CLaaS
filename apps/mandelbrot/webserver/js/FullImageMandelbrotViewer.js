// A class for the full-image Mandelbrot viewer.
class FullImageMandelbrotViewer {
  
  // Construct.
  constructor(host, port, view) {
    
    // Constants for interaction.
    
    this.PINCH_SLUGGISHNESS = 30;

    // {int} A bit mask of the zoom button bit for interactjs event.button.
    this.ZOOM_BUTTON_MASK = 4;
    // {int} Controls the sensitivity of mouse-drag zoom.
    this.ZOOM_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of pinch zoom.
    this.PINCH_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PIXELS = 600;//200;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_LINES = 30;//10;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PAGES = 1;
    
    // Initialize members.
    this.base_url = `http://${host}:${port}/img`;
    // The image last requested.
    this.requested_image_properties = null;
    // The most recent image loaded (requested and returned).
    this.available_image_properties = null;
    
    this.destroyed = false;
    // `true` if the content is being dragged, and click events for highlighting should be ignored.
    this.dragging = false;

    // Each image request is given a unique sequential ID.
    this.image_id = 0;

    // Empty the target div to remove any prior Map and add content for full-image viewer.
    $("#myImage" ).html(`<div class="img_container" width=${view.width} height=${view.height}><img></div>`);
    $("#myImage2").html(`<div class="img_container" width=${view.width} height=${view.height} style="left: ${view.width}px"><img></div>`);
    $("#image_row").css("height", `${view.height}`);

    this.setView(view);

    // Load the next image, non-stop until destroyed.
    this.updateImage();
    
    // Make images interactive.
    interact(".img_container")
      .draggable({
        inertia: true
      })
      .gesturable({
        onmove: (e) => {
          e.preventDefault();
          // This isn't the right formula for pinch action. Quick and dirty, untested.
          this.debugMessage(`OnMove: e = ${e.ds}`);
          let before_scale = this.desired_image_properties.scale;
          let before_zoom = this.desired_image_properties.zoom_level;
          this.desired_image_properties.scaleBy(1 + e.ds);
          this.debugMessage(`  Scale: before: ${before_scale}, after: ${this.desired_image_properties.scale}`)
          this.debugMessage(`  Zoom:  before: ${before_zoom}, after: ${this.desired_image_properties.zoom_level}`)
        }
      })
      // Prevent "scroll-down to reload the page" on mobile while moving the content around
      .on('touchmove', (e) => {
        this.debugMessage(`TouchMove: e = ${e}`);
        e.preventDefault();
      })
      // Set flag `dragging` to disable mouseclicks
      .on('dragstart', (e) => {
        this.dragging = true;
      })
      // Remove flag `dragging` to re-enable mouseclicks.
      // Uses setTimeout to ensure that actions currently firing (on mouseup at the end of a drag)
      // are still blocked from changing the content.
      .on('dragend', (e) => {
        setTimeout (() => {this.dragging = false;}, 0)
      })
      // Zoom and pan the content by dragging.
      .on('dragmove', (e) => {
        this.debugMessage(`DragMove: e = ${e}`);
        e.preventDefault();
        if ((e.buttons & this.ZOOM_BUTTON_MASK) != 0) {
          this.desired_image_properties.zoomBy(e.dy / this.ZOOM_SLUGGISHNESS);
        } else {
          this.desired_image_properties.panBy(e.dx, e.dy);
        }
      })
      .on("wheel", (e) => {
        this.debugMessage(`Wheel: e = ${e}`);
        e.preventDefault();
        if (!this.exists(e, ["originalEvent", "deltaY"]) || !this.exists(e.originalEvent, ["deltaMode"])) {
          return;
        }
        let sluggishness;
        if (e.originalEvent.deltaMode == 0) {
          sluggishness = this.WHEEL_ZOOM_SLUGGISHNESS_PIXELS;
        } else if (e.originalEvent.deltaMode == 1) {
          sluggishness = this.WHEEL_ZOOM_SLUGGISHNESS_LINES;
        } else {
          sluggishness = this.WHEEL_ZOOM_SLUGGISHNESS_PAGES;
        }
        this.desired_image_properties.zoomBy(- e.originalEvent.deltaY / sluggishness);
      });
    
  }
  
  updateDOM() {
    $("#myImage2").css("display", this.desired_image_properties.stereo ? "inline" : "none");
  }
  
  setView(view) {
    this.desired_image_properties = view;
    this.updateDOM();
  }
  
  destroy() {
    this.destroyed = true;
  }
  
  debugMessage(msg) {
    if (window.debug) {
      let el = $("#debugLog");
      el.append(`<p>${msg}</p>`);
      //el.text(el.text() + String.fromCharCode(13, 10) + msg);
    }
  }
  
  // Get the URL for the current desired image and, once loaded, call the callback.
  // Params:
  //  eye: "left", "right", "-" (anything)
  //  cb: callback
  getImage(eye, cb) {
    let urlSource = `${this.base_url}?data=${this.desired_image_properties.getImageURLParamsArrayJSON(eye === "right")}` +
                    `&${this.desired_image_properties.getImageURLQueryArgs(eye === "right")}`;
    console.log(`Image URL: ${urlSource}`);
    this.requested_image_properties = this.desired_image_properties.copy();
    let image = new Image(this.w, this.h);
    image.setAttribute("eye", eye);
    image.src = urlSource;
    image.onload = cb;
    return image;
  }

  // Load the next image if needed, non-stop until destroyed.
  updateImage() {
    if (!this.desired_image_properties.equals(this.requested_image_properties)) {  // TODO: Rounding error might cause this check to fail.
      // New image needed.
      var image_id = this.image_id++;  // For access from callback.
      var request_time = Date.now();
      var viewer = this;  // For access from callback.
      var outstanding = this.desired_image_properties.stereo ? 2 : 1;
      var images = {};  // images that have called back (saved for processing when both return)
      var cb = function (evt) {
        let time = Date.now() - request_time;
        console.log(`Image ${image_id} loaded after ${time} ms.`);
        // Not sure if the callback will trigger (image onload) after the image is removed from the DOM.
        // In case it does, check.
        if (!viewer.destroyed) {
          images[evt.target.getAttribute("eye")] = evt.target;
          if (--outstanding <= 0) {
            for (let eye of Object.keys(images)) {
              let old_img = $((eye == "right") ? "#myImage2 img" : "#myImage img");
              old_img.replaceWith(images[eye]);
            }
            // Load next, but give control back to the browser first to render the loaded image.
            viewer.updateImage();
          }
        }
      }
      this.getImage("left", cb);
      if (this.desired_image_properties.stereo) {
        this.getImage("right", cb);
      }
    } else {
      // Current desired image is already loaded. Wait a bit and poll again.
      setTimeout(() => {this.updateImage()}, 50)
    }
  }

  // An out-of-place utility function.
  
  // Check for the existence and non-nullness of an object path.
  exists(obj, names) {
    while (names.length > 0) {
      if (typeof obj[names[0]] === "undefined" || obj[names[0]] === null) {
        return false;
      }
      obj = obj[names.shift()];
    }
    return true;
  }
}