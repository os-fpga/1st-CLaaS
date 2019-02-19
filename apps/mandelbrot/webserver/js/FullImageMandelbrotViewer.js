// A class for the full-image Mandelbrot viewer.
class FullImageMandelbrotViewer {
  
  // Construct.
  constructor(host, port, motion) {
    
    this.DEFAULT_IMAGE_GAP = 4;
    this.DEFAULT_EYE_SEPARATION = 386;
    this.stereo_image_gap = this.DEFAULT_IMAGE_GAP;  // Pixels of gap between stereo images.
    this.eye_separation = this.DEFAULT_EYE_SEPARATION;  // Distance between eyes in pixels.
    this.image_horizontal_padding = 0;   // Used to position images for stereo viewers.
    this.image_vertical_padding = 0;
    
    // VR parameters
    this.VR_SENSITIVITY_FACTOR = 3.0;  // Increase sensitivity of controls in VR viewer to compensate for lense.
    this.vr = false; // True if configured for viewing in a VR viewer.
    

    // Settings Updates, Motion, and Image Updates
    //
    // Settings are updated by DOM triggers and reflected in desired_image_properties.
    // Every MOTION_TIMEOUT, panning and zooming is applied to desired_image_properties for the timeout time delta (not for the real time delta).
    // Independently, the image is refreshed as needed. The last requested image properties are reflected in requested_image_properties.
    // After one image is loaded, desired_image_properties are compared with requested_image_properties, and if anything has changed, a new image
    // is requested. If not, we'll try again in a few milliseconds.
    
    // Video flythrough
    //
    // For video, we can capture a sequence of frames as image properties. Only position is captured, not settings. Different settings can
    // be applied after the recording. A frame is captured in motion processing callbacks after TIMEOUTS_PER_FRAME motion timeouts.
    //
    // Playback is done in separate DOM resources in separate timeout event handlers. Playback uses settings at the time playback is started.
    // Playback can optionally "burn" video on the server in the process by including query args. Nomal playback presents frames based on
    // wall-clock time. Burning processes and displays one frame at a time.
    
    
    // Flythrough video capture.
    //
    this.frame_rate = 25;  // Frames per second (roughly)
    this.video_speedup = 1.4;  // Factor by which video will be sped up vs. realtime capture. (Just factors into frame_rate.)
    // Recording state:
    this.recording = false;
    this.frame_timeout_cnt = 0;  // Countdown for timeouts within frame.
    // Playback state:
    this.playback = false;
    this.playback_time_zero = null;
    this.playback_properties = null;  // The properties for playback/burning.
    this.playback_id = 0;  // Incremented for each new playback. The allows lingering playbacks to self-destruct.
    this.playback_frame = 0;  // The frame being burned or observed.
    this.burning = false;    // True if "burning" a video. this.playback will also be true.
    this.burn_dir = null;    // Dir to which to burn (captured at burn start from DOM).
    this.observing = false;  // True if "observing".
    this.observe_dir = null; // Dir from which to observe (captured at observe start from DOM).
    
    this.time_str = new Date().getMilliseconds();  // A unique value for the run for URL uniquification.
    
    
    
    this.timeouts_per_frame = 2;
    this.MOTION_TIMEOUT = Math.round(1000 / this.frame_rate * this.video_speedup / this.timeouts_per_frame);
    
    // Constants for interaction.
    
    this.PINCH_SLUGGISHNESS = 30;

    // {int} A bit mask of the zoom button bit for interactjs event.button.
    this.ZOOM_BUTTON_MASK = 4;
    // {int} Controls the sensitivity of mouse-drag zoom.
    this.ZOOM_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of pinch zoom.
    this.PINCH_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PIXELS = 600;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_LINES = 30;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PAGES = 3;
    // {float} Multiplier for velocity.
    this.VELOCITY_FACTOR = 1 / this.MOTION_TIMEOUT;  // Move by mouse position every second.
    // {float} Multiplier for zoom velocity.
    this.ZOOM_VELOCITY_FACTOR = this.VELOCITY_FACTOR * 0.6;
    // {float} Multiplier for acceleration.
    this.ACCELERATION_FACTOR = this.VELOCITY_FACTOR / this.MOTION_TIMEOUT; // Every second, increase velocity by mouse position/sec.
    // {float} Multiplier for zoom acceleration.
    this.ZOOM_ACCELERATION_FACTOR = this.ACCELERATION_FACTOR * 0.6;
    
    
    // Initialize members.
    this.root_url = `http://${host}:${port}`;
    this.base_url = `${this.root_url}/img`;
    
    // A reference time.
    this.ref_time = new Date();
    this.no_cache_cnt = 0;  // A count of the number of no-cached image requests for uniquification.
    
    // The image last requested.
    this.requested_image_properties = null;
    
    this.destroyed = false;
    // `true` iff the content is being dragged.
    this.dragging = false;
    this.motion = motion;
    this.motion_x = 0;
    this.motion_y = 0;
    this.motion_z = 0;
    this.velocity_x = 0;
    this.velocity_y = 0;
    this.velocity_z = 0;

    // Each image request is given a unique sequential ID.
    this.image_id = 0;
  }
  
  // Must be called after construction and DOM configuration.
  init(view) {

    this.setView(view);

    // Load the next image, non-stop until destroyed.
    this.updateImage();
    
    
    // Make images interactive.
    interact("#fullImageViewerContainer")
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
      
      // Handle drag. We must recognize mouse-down as well for non-positional (velocity/acceleration) controls
      // because these must react to mousewheel only when the mouse button is down. Begin drag on mousedown and
      // end on mouse-up or enddrag. (TODO: Need to test on mobile.)
      .on('down', (e) => {
        // Set flag `dragging`.
        this.dragging = true;
        if (this.motion !== "position") {
          this.motion_x = e.offsetX - e.target.clientWidth / 2.0;
          this.motion_y = e.offsetY - e.target.clientHeight / 2.0;
          this.motion_z = 0;
          this.velocity_x = 0;
          this.velocity_y = 0;
          this.velocity_z = 0;
          this.setMotionTimeout();
        }
      })
      .on('up', (e) => {
        this.endDrag();
      })
      //.on('dragstart', (e) => {
      //  this.dragging = true;
      //})
      .on('dragend', (e) => {
        // Clear flag `dragging` to re-enable mouseclicks.
        // Uses setTimeout to ensure that actions currently firing (on mouseup at the end of a drag)
        // are still blocked from changing the content.
        this.endDrag();
      })
      // Zoom and pan the content by dragging.
      .on('dragmove', (e) => {
        this.debugMessage(`DragMove: e = ${e}`);
        e.preventDefault();
        if ((e.buttons & this.ZOOM_BUTTON_MASK) != 0) {
          // Mouse button & drag used for zoom (not currently enabled).
          let amt = e.dy / this.ZOOM_SLUGGISHNESS;
          if (this.motion === "position") {
            this.desired_image_properties.zoomBy(amt);
          } else {
            this.motion_z += amt;
          }
        } else {
          // Default for position.
          let dx = e.dx;
          let dy = e.dy;
          this.motion_x += dx;
          this.motion_y += dy;
          if (this.motion === "position") {
            this.panBy(dx, dy);
          }
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
        let amt = - e.originalEvent.deltaY / sluggishness;
        if (this.motion === "position") {
          this.desired_image_properties.zoomByAt(amt, (e.offsetX - e.target.clientWidth  / 2.0) * this.desired_image_properties.pix_size_x,
                                                      (e.offsetY - e.target.clientHeight / 2.0) * this.desired_image_properties.pix_size_y);
        } else {
          this.motion_z += amt;
        }
      });
    
  }
  
  panBy(dx, dy) {
    if (this.vr) {
      // Compensate for lense by increasing sensitivity.
      dx *= this.VR_SENSITIVITY_FACTOR;
      dy *= this.VR_SENSITIVITY_FACTOR;
    }
    this.desired_image_properties.panBy(dx, dy);
  }
  
  endDrag() {
    setTimeout (() => {this.dragging = false;}, 0);
  }
  
  setMotionTimeout() {
    setTimeout(() => {this.applyMotion();}, this.MOTION_TIMEOUT);
  }
  applyMotion() {
    if (this.dragging) {
      if (this.motion === "acceleration") {
        this.velocity_x += this.motion_x * - this.ACCELERATION_FACTOR;
        this.velocity_y += this.motion_y * - this.ACCELERATION_FACTOR;
        this.velocity_z += this.motion_z * this.ZOOM_ACCELERATION_FACTOR;
      } else {
        this.velocity_x = this.motion_x * - this.VELOCITY_FACTOR;
        this.velocity_y = this.motion_y * - this.VELOCITY_FACTOR;
        this.velocity_z = this.motion_z * this.ZOOM_VELOCITY_FACTOR;
      }
      this.panBy(this.velocity_x, this.velocity_y);
      this.desired_image_properties.zoomBy(this.velocity_z);
      this.setMotionTimeout();

  
      // Capture frame? (only while dragging and not w/ positional control)
      if (this.recording) {
        if (this.frame_timeout_cnt <= 0) {
          // Yes, capture frame.
          if (this.frames.length >= 2000) {
            console.log("Video exceeded maximum number of frames");
            this.setRecording(false);
          }
          console.log(`Frame #${this.frames.length}`)
          this.frames.push(this.desired_image_properties.copy(null));
          $("#num-frames").text(this.frames.length);
          
          this.frame_timeout_cnt = this.timeouts_per_frame;
        } else {
          this.frame_timeout_cnt--;
        }
      }
    }
  }
  
  // Set viewer or playback view based on the size of the container component.
  sizeViewer(container_el, stereo) {
    let c = container_el;
    let c_w = c.width();
    let w = c_w; // Assuming not stereo.
    let h = c.height();
    
    c.find(".rightEyeImage").css("display", stereo ? "inline" : "none");
    if (stereo) {
      // Do not allow the eye to be outside of the image in x/y as this will not render properly.
      let min_c_w = this.eye_separation + 2;
      if (c_w < min_c_w) {
        c_w = min_c_w;
        c.width(c_w);
      }
      w = (c_w - this.stereo_image_gap) / 2 - this.image_horizontal_padding;
      h -= this.image_vertical_padding * 2;
      
      // Position right eye image.
      c.find(".leftEyeImage").css("left", 6 + this.image_horizontal_padding);
      c.find(".mandelbrotImage").css("top", 6 + this.image_vertical_padding);
      c.find(".rightEyeImage").css("left", 6 + this.image_horizontal_padding + w + this.stereo_image_gap);
      c.find(".rightEyeImage").children().children().css("left", -w);  // Hide left-eye image contents in double-image.
    }
    w = Math.floor(w / 2) * 2;  // use multiples of two so center is a whole number.
    h = Math.floor(h / 2) * 2;
    let imgs = c.find(".mandelbrotImage");
    imgs.width(w);
    imgs.height(h);
  }
  
  // Start the spot at depth 0 and increment it to a certain depth as long as the spot_depth has not been reset by another call.
  sendSpot() {
    this.desired_image_properties.settings.spot_depth = -1;
    let spot_depth = -1;
    let cb = () => {
      if (spot_depth < 40 && this.desired_image_properties.settings.spot_depth == spot_depth) {
        console.log(`spot_depth: ${spot_depth}`);
        // As expected from last iteration; spot has not been reset.
        this.desired_image_properties.settings.spot_depth++;
        spot_depth++;
        if (spot_depth < 40) {
          setTimeout(cb, 5000 / (5 + this.desired_image_properties.settings.spot_depth));  // 1 sec to go to depth 2, 2 seconds at depth 10, 3 at 20, etc.
        } else {
          this.desired_image_properties.settings.spot_depth = -1;
        }
      }
    }
    cb();
  }
  
  setView(view) {
    this.desired_image_properties = view;
  }
  
  destroy() {
    interact("#fullImageViewerContainer").unset();
    this.destroyed = true;
  }
  
  debugMessage(msg) {
    if (window.debug) {
      let el = $("#debugLog");
      el.append(`<p>${msg}</p>`);
      //el.text(el.text() + String.fromCharCode(13, 10) + msg);
    }
  }
  
  getImageURL() {
    return `${this.base_url}${this.desired_image_properties.getImageURLQueryArgs()}`;
  }
  getFrameURL(burn, dir, frame, first, last) {
    let params = {};
    if (burn) {
      if (dir) {
        params.burn_dir = dir;
        params.burn_frame = frame;
        if (first) {
          params.burn_first = true;
        }
        if (last) {
          params.burn_last = true;
        }
        // Avoid caching
        params.uniquifier = this.playback_id;
      } else {
        console.log("Refusing to burn video with no name.")
      }
    }
    return `${this.base_url}${this.playback_properties.getImageURLQueryArgs(params)}`;
  }
  
  /*-
  // Get the URL for the current desired image and, once loaded, call the callback.
  // Params:
  //  url: the URL of the image
  //  cb: callback
  getImage(url, cb) {
    //console.log(`Image URL: ${urlSource}`);
    let image = new Image(this.w, this.h);
    image.src = url;
    image.onload = cb;
    return image;
  }
  */

  // Load the next image if needed, non-stop until destroyed.
  updateImage() {
    this.desired_image_properties.settings.updateTimeBasedSettings(new Date() - this.ref_time);
    if (!this.desired_image_properties.equals(this.requested_image_properties)) {  // TODO: Rounding error might cause this check to fail.
      // New image needed.
      var image_id = this.image_id++;  // For access from callback.
      var request_time = Date.now();
      var viewer = this;  // For access from callback.
      var cb = function (evt) {
        let time = Date.now() - request_time;
        console.log(`Image ${image_id} loaded after ${time} ms.`);
        // Not sure if the callback will trigger (image onload) after the image is removed from the DOM.
        // In case it does, check.
        if (!viewer.destroyed) {
          let src = evt.target.getAttribute("src");
          $("#leftEye img").attr("src", src);
          if (viewer.desired_image_properties.settings.stereo) {
            $("#rightEye img").attr("src", src);
          }
          // Update download link to hold this URL.
          $(".imgLink").attr("href", src);
          // Load next, but give control back to the browser first to render the loaded image.
          viewer.updateImage();
        }
      }
      let image = new Image(this.w, this.h);
      image.src = this.getImageURL();
      // If casting, force no-cache.
      if (this.casting) {
        image.src += `?no-cache=${this.time_str}-${this.no_cache_cnt}`;
        this.no_cache_cnt++;
      }
      image.onload = cb;
      this.requested_image_properties = this.desired_image_properties.copy();
      console.log(`Image URL: ${image.src}`);
    } else {
      // Current desired image is already loaded. Wait a bit and poll again.
      setTimeout(() => {this.updateImage()}, 50)
    }
  }
  
  
  // Video
  
  setRecording(val) {
    this.recording = val;
    this.frame_timeout_cnt = 0;
    if (val) {
      this.frames = [];
    }
  }

  startPlayback(burn, observe) {
    this.playback = true;
    this.burning = burn;
    this.observing = observe;
    this.playback_properties = this.desired_image_properties.copy();
    let v = $("#imagesContainer");
    let c = $("#playbackImagesContainer");
    c.width(v.width());
    c.height(v.height());
    this.sizeViewer(c, this.playback_properties.settings.stereo);
    $(".playback-only").css("display", "block");
    // Need to set img height/width? Shouldn't be necessary as it should use image size.
    this.playback_frame = -1;
    if (burn) {
      this.burn_dir = $("#burn-dir").val();
      // Increment the dir name to avoid accidental overwrites (hacky).
      $("burn-dir").val(this.burn_dir + "_");
    } else if (observe) {
      this.observe_dir = $("#observe-dir").val();
    } else {
      this.playback_time_zero = new Date();
    }
    this.playback_id++;
    this.updatePlaybackFrame(this.playback_id);
  }
  
  disablePlayback() {
    $("#play-recording, #burn-video, #observe-button").attr("state", "off");
    if (this.playback) {
      let pb_els = $(".playback-only");
      pb_els.css("display", "none");
    }
    this.playback = false;
    this.burning = false;
    this.observing = false;
  }

  // Request the next playback frame if necessary.
  updatePlaybackFrame(id) {
    console.log("updatePlaybackFrame()");
    if (this.playback && id == this.playback_id) {
      // This playback is still active.
      let old_frame = this.playback_frame;
      if (this.burning || this.observing) {
        this.playback_frame++;  // (not so meaningful for observing, but the "frame" must look new to code below)
      } else {
        let now = new Date();
        this.playback_frame = Math.floor((now - this.playback_time_zero) / this.frame_rate);
      }
      if (this.playback_frame > old_frame) {
        if (this.observing || this.playback_frame < this.frames.length) {
          let image = new Image();
          if (this.observing) {
            image.src = `${this.root_url}/observe_img/${this.observe_dir}?no-cache=${this.time_str}-${this.playback_id}-${this.playback_frame}`;
          } else {
            this.playback_properties.positionAs(this.frames[this.playback_frame]);
            this.playback_properties.settings.updateTimeBasedSettings(this.playback_frame * 1000 / this.frame_rate);
            image.src = this.getFrameURL(this.burning, this.burn_dir, this.playback_frame, this.playback_frame == 0, this.playback_frame == this.frames.length - 1);
          }
          image.onerror = (evt) => {
            // Errors are returned when image is not changed.
            // Nothing to update.
            setTimeout(() => {this.updatePlaybackFrame(id);}, 50);
          }
          image.onload = (evt) => {
            let src = evt.target.getAttribute("src");
            $("#playbackLeftEye img").attr("src", src);
            if (this.desired_image_properties.settings.stereo) {
              $("#playbackRightEye img").attr("src", src);
            }
            // Next frame.
            this.updatePlaybackFrame(id);
          };
        } else {
          // Done playback.
          this.disablePlayback();
        }
      } else {
        // Current frame already loaded. Wait a little and try again.
        setTimeout(() => {this.updatePlaybackFrame(id);}, 25);
      }
    }
  }
  
  
  // VR settings for various devices.
  VR_Cardboard_SG_S3() {
    this.vr = true;
    this.eye_separation = 475;
    this.image_vertical_padding = 120;
    this.image_horizontal_padding = 70;
    this.stereo_image_gap = 4 + 2 * 130;
    this.desired_image_properties.scale *= 3.0;  // Image scale will adjust with image hight. Let's adjust to keep more consistent.
  }
  
  VR_off() {
    this.vr = false;
    this.eye_separation = this.DEFAULT_EYE_SEPARATION;
    this.image_vertical_padding = 0;
    this.image_horizontal_padding = 0;
    this.stereo_image_gap = this.DEFAULT_IMAGE_GAP;
    this.desired_image_properties.scale /= 3.0;
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