class demo {

// Get renderer from GUI as "python", "cpp", or "fpga".
getRenderer() {
  return $("#python").prop("checked") ? "python" : $("#cpp").prop("checked") ? "cpp" : "fpga";
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
  return $("#3d").prop("checked") ? 1 : 0;
}
getStereo() {
  return $("#stereo").prop("checked") ? 1 : 0;
}
getDarken() {
  return $("#darken").prop("checked") ? 1 : 0;
}


mapQueryArgs(right) {
  return "var1=" + this.getVar1() + "&var2=" + this.getVar2() + "&renderer=" + this.getRenderer();
}

// Create a new view based on DOM inputs. Position of image is preserved from current view if existing, o.w. reset.
newView() {
  var reset = this.viewer == null || this.viewer.desired_image_properties == null;
  return new MandelbrotView(
               reset ? 0.0 : this.viewer.desired_image_properties.center_x,
               reset ? 0.0 : this.viewer.desired_image_properties.center_y,
               reset ? 1.0 : this.viewer.desired_image_properties.scale,
               256, 256, this.getMaxDepth(), this.getRenderer(), this.getVar1(), this.getVar2(), this.get3d(),
               this.getStereo(),
               396, // distance between eyes in pixels
               256, // distance between images in pixel
               //this.getStereo() ? parseInt((IMAGE_SEPARATION - EYE_SEPARATION) / 2.0) : 0,
               //this.getStereo() ? EYE_SEPARATION / 2.0 * pix_x,
               this.getDarken()
             );
}

paramsChanged() {
  if (this.map) {
    console.log("Unwritten code.");
  }
  if (this.viewer) {
    this.viewer.setView(this.newView());
  }
}

destroy_viewer() {
  if (this.viewer) {
    this.viewer.destroy();
    this.viewer = null;
  }
  if (this.map) {
    this.map = null;
  }
  $("#myImage").html("");
}

constructor() {
  window.debug = 0;  // 0/1 to disable/enable in-browser debug messages.
  
  this.map = null;  // The open map, or null.
  this.viewer = null;  // The open FullImageMandelbrotViewer, or null.
  $("#renderer input").change((evt) => {
    if (this.map) {
      console.log("Unwritten code.");
    }
    if (this.viewer) {
      this.viewer.desired_image_properties.renderer = this.getRenderer();
    }
  })
  $("#modes input").change((evt) => {
    this.paramsChanged();
  })
  $(".var").on("input", (evt) => {
    this.paramsChanged();
  })
  $("#open_map").click((evt) => {
    this.destroy_viewer();
    let host = $("#host").val();
    let port = $("#port").val();
    let uri = $("#uri").val();
    let tile = "/tile/";
    var urlSource = "http://" + host + ":" + port + tile + this.getMaxDepth() +
                    "/{z}/{x}/{y}?" + this.mapQueryArgs(false);
    console.log(`Image URL: ${urlSource}`);
    this.map = new ol.Map({
      target: 'myImage',
      layers: [
        new ol.layer.Tile({
          source: new ol.source.XYZ({
            url: urlSource
          })
        })
      ],
      view: new ol.View({
        center: [0, 0],//defualt parameters
        zoom: 2  //defualt zooming
      })
    });
  });
  $("#open_img").click((evt) => {
    this.destroy_viewer();
    
    // The image as it *should* currently be displayed.
    this.viewer = new FullImageMandelbrotViewer($("#host").val(), $("#port").val(), this.newView());
  });
}

}