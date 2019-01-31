class demo {

// Generic methods:

getRequestFullscreenFn() {
  let root = document.documentElement;
  return root.requestFullscreen || root.webkitRequestFullscreen || root.mozRequestFullScreen || root.msRequestFullscreen;
}

// Methods to get parameter values from GUI.

// Get renderer from GUI as "python", "cpp", or "fpga".
getRenderer() {
  return $("#python").prop("checked") ? "python" : $("#cpp").prop("checked") ? "cpp" : "fpga";
}
getTiled() {
  return $("#tiled").prop("checked");
}
getEyeAdjust() {
  return $("#eye_adjust").prop("value");
}
getBrighten() {
  return $("#brighten").prop("value");
}
getVar1() {
  return $("#var1").prop("value");
}
getVar2() {
  return $("#var2").prop("value");
}
getMaxDepth() {
  let d = $("#sqrt_depth").prop("value");
  return d * d;
}
get3d() {
  return ! $("#2d").prop("checked") ? 1 : 0;
}
getStereo() {
  return $("#stereo").prop("checked") ? 1 : 0;
}
getDarken() {
  return $("#darken").prop("checked") ? 1 : 0;
}
getSmooth() {
  return $("#smooth").prop("checked") ? 1 : 0;
}
getMotion() {
  return $("#motionAcceleration").prop("checked") ? "acceleration" :
         $("#motionVelocity")    .prop("checked") ? "velocity"     :
                                                    "position";
}
getColorScheme() {
  return parseInt($("[name=color-scheme]:checked").attr("encoding"));
}
getColorShift() {
  return $("#color-shift").prop("value");
}
getStringLights() {
  return $("#string-lights").prop("checked") ? 1 : 0;
}
getFanciful() {
  return $("#fanciful").prop("checked") ? 1 : 0;
}
getShadow() {
  return $("#shadow").prop("checked") ? 1 : 0;
}
getRoundEdges() {
  return $("#round-edges").prop("checked") ? 1 : 0;
}
getElectrify() {
  return $("#electrify").prop("checked");
}
getEdgeStyle() {
  return parseInt($(".edge-style:checked").attr("encoding"));
}
getHeight() {
  return $("#leftEye").height();
}
getWidth() {
  return $("#rightEye").width();
}
getTestEnabled() {
  return $("#test0").css("display") != "none";
}
getTestFlag(num) {
  let ret = $(`#test-flag${num}`).prop("checked");
  return ret;
}
getTestVar(num) {
  return $(`#test${num}`).prop("value");
}
getTheme() {
  let ret =  parseInt($(".theme:checked").attr("encoding"));
  return ret;
}
getThemeName() {
  let ret = $(".theme:checked").attr("id");
  return ret;
}

// Configure for a theme appropriate for today's data.
setHolidayTheme() {
  let date = new Date();
  let month = date.getMonth();
  let day = date. getDate();
  let holiday = "none";
  if ((month == 11) && ((day <= 27) && (day > 5))) {
    holiday = "xmas";
  }
  if (holiday !== "none") {
    let holiday_el = $(`#${holiday}`);
    holiday_el.prop("checked", true);
    holiday_el.trigger("change");
  }
}


// Create a new view based on DOM inputs. Position of image is preserved from current view if existing, o.w. reset.
newView() {
  var reset = this.viewer == null || this.viewer.desired_image_properties == null;
  return new MandelbrotView(
               reset ? 0.0 : this.viewer.desired_image_properties.center_x,
               reset ? 0.0 : this.viewer.desired_image_properties.center_y,
               reset ? 1.0 : this.viewer.desired_image_properties.scale,
               this.getWidth(), this.getHeight(),
               this.settings
             );
}

// A function for settings to update settings that change over time, based on current time and other settings.
getUpdateTimeBasedSettingsFn() {
  return function (settings, ms) {
    if (settings.theme == 1) {
      // Xmas
      // Blink lights and wave branches.
        settings.cycle = Math.floor(ms / 1000) % 3;
      /*
      if (settings.cycle == 0) {
        settings.var1 = 0;
        settings.var2 = 0;
      } else if (settings.cycle == 1) {
        settings.var1 = 5;
        settings.var2 = 2;
      } else {
        settings.var1 = 2;
        settings.var2 = 5;
      }
      */
    } 
  }
}

// Settings or view size has changed in GUI and must be reflected.
settingsChanged() {
  let test_flags = 0;
  let test_vars = [];
  if (this.getTestEnabled()) {
    for (let i = 0; i < 16; i++) {
      // twice as many test flags as vars, so double up on flags here
      test_flags |= (this.getTestFlag(i*2) ? 1 : 0) << (i*2);
      test_flags |= (this.getTestFlag(i*2+1) ? 1 : 0) << (i*2+1);
      test_vars[i] = this.getTestVar(i);
    }
  }
  this.settings.set(
         this.getMaxDepth(), this.getRenderer(), this.getBrighten(), this.getEyeAdjust(),
         this.getVar1(), this.getVar2(), this.get3d(), this.getStereo(),
         this.viewer ? this.viewer.eye_separation : 0, // distance between eyes in pixels
         this.getWidth() + (this.viewer ? this.viewer.stereo_image_gap : 0), // distance between images in pixel
         //this.getStereo() ? parseInt((IMAGE_SEPARATION - eye_separation) / 2.0) : 0,
         //this.getStereo() ? eye_separation / 2.0 * pix_x,
         this.getDarken(), this.getSmooth(),
         !this.getTiled(),
         -1,  // spot_depth (no spot)
         this.getColorScheme() | this.getColorShift() << 16 | this.getElectrify() << 25,
         this.getStringLights() << 0 | this.getFanciful() << 1 | this.getShadow() << 2 | this.getRoundEdges() << 3,
         this.getEdgeStyle(),
         this.getTheme(),
         0,  // cycle
         this.cast_tag,  // (captured value, not straight from DOM)
         test_flags,
         test_vars,
         this.getUpdateTimeBasedSettingsFn()
       );  // The viewer is polling this structure for changes.
  if (this.map) {
    this.map_source.setUrl(this.getMapURL());
  }
  if (this.viewer) {
    this.viewer.setView(this.newView());
  }
}

sizeFullViewer() {
  let c = $("#imagesContainer");
  let w = c.width();
  let h = c.height();
  
  $("#img-width").text(w);
  $("#img-height").text(h);
  
  // For some reason 100% h/w isn't working in child?
  //c.children().width(w);
  //c.children().height(h);
  $("#eventRecipient").width(w);
  $("#eventRecipient").height(h);
  
  if (this.viewer) {
    this.viewer.sizeViewer(c, this.getStereo());
  }
}

resized() {
  if (this.map) {
    this.map.updateSize();
  }
  if (this.viewer) {
    this.sizeFullViewer();
  }
  this.settingsChanged();
}

destroyViewer() {
  if (this.viewer) {
    this.viewer.destroy();
    this.viewer = null;
    $(".leftEyeImage").html("");
    $(".rightEyeImage").html("");
    $(".viewerContainer").css("display", "none");
  }
  if (this.map) {
    this.map = null;
    this.map_source = null;  // since we're done with it
    $("#mapContainer").html("");
    $("#mapContainer").css("display", "none");
  }
}

getMapURL() {
  let host = $("#host").val();
  let port = $("#port").val();
  let uri = $("#uri").val();
  let tile = "/tile/";
  var urlSource = "http://" + host + ":" + port + tile + this.settings.max_depth +
                  "/{z}/{x}/{y}?" + this.settings.mapQueryArgs();
  return urlSource;
}

setMotionMessage() {
  let motion = this.getMotion();
  // Only the viewer supports non-positional motion.
  if (!this.viewer) {
    motion = "position";
  }
  $(".motionInstructions").css("display", "none");
  if (this.viewer) {
    $(`#${motion}MotionInstructions`).css("display", "block")
  }
}

openMap() {
  $("#mapContainer").css("display", "block");
  var urlSource = this.getMapURL();
  this.map_source = new ol.source.XYZ({url: urlSource});
  console.log(`Image URL: ${urlSource}`);
  this.map = new ol.Map({
    target: 'mapContainer',
    layers: [
      new ol.layer.Tile({
        source: this.map_source
      })
    ],
    view: new ol.View({
      center: [0, 0],//defualt parameters
      zoom: 2,  //defualt zooming
      maxZoom: 1000
    })
  });
}

openFullViewer() {
  // Open full image viewer
  $(".viewerContainer").css("display", "block");

  // Empty the target div to remove any prior Map and add content for full-image viewer.
  $(".leftEyeImage" ).html(`<div class="imgContainer"><img></div>`);
  $(".rightEyeImage").html(`<div class="imgContainer"><img></div>`);

  this.viewer = new FullImageMandelbrotViewer($("#host").val(), $("#port").val(), this.newView(), this.getMotion());
}

setDimensions(w, h) {
  let c = $(".imagesContainer");
  c.width(w);
  c.height(h);
  this.sizeFullViewer();
}

constructor() {
  
  // Constants
    
  window.debug = 0;  // 0/1 to disable/enable in-browser debug messages.
  
  
  // Member variables
  
  this.settings = new MandelbrotSettings(); // Modified each time settings are changed in GUI.
  this.map = null;  // The open map, or null.
  this.map_source = null; // The 'source' of the map.
  this.viewer = null;  // The open FullImageMandelbrotViewer, or null.
  
  this.cast_tag = null; // Tag/directory to which to cast (captured when casting is enabled.)
  
  
  // Event handling
  
  $("#renderer input").change((evt) => {
    if (this.map) {
      this.map_source.setUrl(this.getMapURL());
    }
    if (this.viewer) {
      this.viewer.desired_image_properties.settings.renderer = this.getRenderer();
    }
    
    // Hide/show appropriate options based on renderer.
    $(".not-python").css("display", this.getRenderer() === "python" ? "none" : "block")
    
    if (evt.target.id == "tiled") {
      this.destroyViewer();
      this.settingsChanged();
      $(".full-img-only").css("display", this.getTiled() ? "none" : "block")
      if (this.getTiled()) {
        this.openMap();
      } else {
        this.openFullViewer();
      }
      this.setMotionMessage();
    } else {
      this.settingsChanged();
    }
  });
  $("#modes input").change((evt) => {
    this.resized();  // because stereo can affect sizing
    // Update visibility based on modes.
    $(".three-d-only").css("display", this.get3d() ? "block" : "none");
    $(".stereo-only").css("display", this.getStereo() ? "block" : "none");
    $("#imagesContainer").css("min-width", this.getStereo() ? `${this.viewer.eye_separation + 2}px` : "20px");
  });
  $("#texture input").change((evt) => {
    //this.settingsChanged();
    $(".darken-only").css("display", this.getDarken() ? "block" : "none");
  });
  $("#theme input").change((evt) => {
    $(".not-themed").css("display", (this.getTheme() == 0) ? "block" : "none");
    let theme = this.getThemeName();
    $("[forTheme]").css("display", "none");
    $(`[forTheme=${theme}`).css("display", "block");
    // Reset the view if themes are not compatible. (Currently it's just xmas, which is not compatible w/ normal.)
    if (this.viewer) {
      this.viewer.desired_image_properties.resetPosition();
    }
  });
  $(".var").on("input", (evt) => {
    this.settingsChanged();
  });
  $(".selection").change((evt) => {
    this.settingsChanged();
  });
  $(".flag").change((evt) => {
    this.settingsChanged();
  });
  $("#motion input").change((evt) => {
    if (this.viewer) {
      this.viewer.motion = this.getMotion();
    }
    this.setMotionMessage();
  });
  $("body").keypress((evt) => {
    if (evt.which == 32 /*space*/ && this.viewer && this.getStereo()) {
      this.viewer.sendSpot();
    }
  })
  $("#resetImage").click((evt) => {
    this.viewer.desired_image_properties.resetPosition();
  })
  $("#good-place").click((evt) => {
    if (this.viewer) {
      this.viewer.desired_image_properties.goToGoodPlace();
    }
  })
  $("#record-button").click((evt) => {
    if (this.viewer) {
      if (evt.target.getAttribute("state") === "off") {
        evt.target.setAttribute("state", "on");
        this.viewer.setRecording(true);
      } else {
        evt.target.setAttribute("state", "off");
        this.viewer.setRecording(false);
      }
    }
  })
  $("#cast-button").click((evt) => {
    if (this.viewer) {
      if (evt.target.getAttribute("state") === "off") {
        this.cast_tag = $("#observe-dir").val();
        evt.target.setAttribute("state", "on");
      } else {
        this.cast_tag = null;
        evt.target.setAttribute("state", "off");
      }
    }
    this.settingsChanged();
  })
  $("#play-recording, #burn-video, #observe-button").click((evt) => {
    let burn = evt.target.id == "burn-video";
    let observe = evt.target.id == "observe-button";
    if (this.viewer) {
      let orig_state = evt.target.getAttribute("state");
      // Disable playback in case it is enabled.
      this.viewer.disablePlayback();
      
      if (orig_state === "off") {
        // Enable this button and its playback behavior.
        evt.target.setAttribute("state", "on");
        this.viewer.startPlayback(burn, observe);
      }
    }
  })
  $(".resolution").click((evt) => {
    if (this.viewer) {
      this.setDimensions(parseInt(evt.target.getAttribute("x")), parseInt(evt.target.getAttribute("y")));
    }
  })
  $("#SG-S3-cardboard").click((evt) => {
    // TODO: Written to work for the first click only. No undo.
    // Set stereo.
    if (!this.getStereo()) {
      $("#stereo").click();
    }
    if (this.viewer) {
      if (evt.target.getAttribute("state") === "off") {
        this.viewer.VR_Cardboard_SG_S3();
        this.setDimensions(640, 360);
        this.settingsChanged();
        evt.target.setAttribute("state", "on");
      } else {
        this.viewer.VR_off();
        this.resized();
        evt.target.setAttribute("state", "off");
      }
    }
  })
  $("#go-fullscreen").click((evt) => {
    if (this.viewer) {
      let fs = this.getRequestFullscreenFn();
      fs.call($("#playbackImagesContainer")[0]);
    }
  })
  new ResizeObserver(entries => {
    this.resized();
  }).observe($("#imagesContainer")[0]);
  
  
  this.setHolidayTheme();
  
  
  // Initialization
  
  this.settingsChanged();
  this.openFullViewer();
  
}
}
