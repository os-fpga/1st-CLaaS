class demo {

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
  var d = $("#sqrt_depth").prop("value");
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
getHeight() {
  return $("#leftEye").height();
}
getWidth() {
  return $("#rightEye").width();
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

// Settings or view size has changed in GUI and must be reflected.
settingsChanged() {
  this.settings.set(
         this.getMaxDepth(), this.getRenderer(), this.getBrighten(), this.getEyeAdjust(),
         this.getVar1(), this.getVar2(), this.get3d(), this.getStereo(),
         this.EYE_SEPARATION, // distance between eyes in pixels
         this.getWidth() + this.STEREO_IMAGE_GAP, // distance between images in pixel
         //this.getStereo() ? parseInt((IMAGE_SEPARATION - EYE_SEPARATION) / 2.0) : 0,
         //this.getStereo() ? EYE_SEPARATION / 2.0 * pix_x,
         this.getDarken(), this.getSmooth(),
         !this.getTiled()
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
    let c_w = c.width();
    let w = c_w; // Assuming not stereo.
    let h = c.height();
    
    // For some reason 100% h/w isn't working in child?
    //c.children().width(w);
    //c.children().height(h);
    $("#eventRecipient").width(w);
    $("#eventRecipient").height(h);
    
    $("#rightEye").css("display", this.getStereo() ? "inline" : "none");
    if (this.getStereo()) {
      // Do not allow the eye to be outside of the image in x/y as this will not render properly.
      let min_c_w = this.EYE_SEPARATION + 2;
      if (c_w < min_c_w) {
        c_w = min_c_w;
        c.width(c_w);
      }
      w = (c_w - this.STEREO_IMAGE_GAP) / 2;
    }
    w = Math.floor(w / 2) * 2;  // use multiples of two so center is a whole number.
    h = Math.floor(h / 2) * 2;
    let imgs = $(".mandelbrotImage");
    imgs.width(w);
    imgs.height(h);
    imgs.eq(1).css("left", w + this.STEREO_IMAGE_GAP + imgs.eq(0).position().left);
    imgs.eq(1).children().children().css("top", -h);
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
    $("#leftEye").html("");
    $("#rightEye").html("");
    $("#fullImageViewerContainer").css("display", "none");
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
                  "/{z}/{x}/{y}?" + this.settings.mapQueryArgs(false);
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
  $("#fullImageViewerContainer").css("display", "inline");

  // Empty the target div to remove any prior Map and add content for full-image viewer.
  $("#leftEye" ).html(`<div class="imgContainer"><img></div>`);
  $("#rightEye").html(`<div class="imgContainer"><img></div>`);

  this.sizeFullViewer();
  // The image as it *should* currently be displayed.
  this.viewer = new FullImageMandelbrotViewer($("#host").val(), $("#port").val(), this.newView(), this.getMotion());
}

constructor() {
  
  // Constants
  
  this.STEREO_IMAGE_GAP = 4;  // Pixels of gap between stereo images.
  this.EYE_SEPARATION = 386;  // Distance between eyes in pixels.
  
  window.debug = 0;  // 0/1 to disable/enable in-browser debug messages.
  
  // Member variables
  
  this.settings = new MandelbrotSettings(); // Modified each time settings are changed in GUI.
  this.map = null;  // The open map, or null.
  this.map_source = null; // The 'source' of the map.
  this.viewer = null;  // The open FullImageMandelbrotViewer, or null.
  
  
  // Event handling
  
  $("#renderer input").change((evt) => {
    if (this.map) {
      this.map_source.setUrl(this.getMapURL());
    }
    if (this.viewer) {
      this.viewer.desired_image_properties.settings.renderer = this.getRenderer();
    }
    $("#modes").css("display", this.getRenderer() === "python" ? "none" : "block")
    if (evt.target.id == "tiled") {
      this.destroyViewer();
      this.settingsChanged();
      if (this.getTiled()) {
        this.openMap();
      } else {
        this.openFullViewer();
      }
      this.setMotionMessage();
    }
  });
  $("#modes input").change((evt) => {
    this.resized();  // because stereo can affect sizing
  });
  $(".var").on("input", (evt) => {
    this.settingsChanged();
  });
  $("#motion input").change((evt) => {
    if (this.viewer) {
      this.viewer.motion = this.getMotion();
    }
    this.setMotionMessage();
  });
  new ResizeObserver(entries => {
    this.resized();
  }).observe($("#imagesContainer")[0]);
  
  
  
  // Initialization
  
  this.settingsChanged();
  this.openFullViewer();
}

}