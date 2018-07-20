function demo() {
  
  // Check for the existance and non-nullness of an object path.
  function exists(obj, names) {
    while (names.length > 0) {
      if (typeof obj[names[0]] === "undefined" || obj[names[0]] === null) {
        return false;
      }
      obj = obj[names.shift()];
    }
    return true;
  }
  
  var host;
  var port;
  var uri;
  var map = null;  // The open map, or null.
  var image = null;  // The open image, or null.
  $("#open_map").click(function (evt) {
    // Empty the target div to remove any prior Map.
    image = map = null;
    $("#myImage").html("");
    let host = $("#host").val();
    let port = $("#port").val();
    let uri = $("#uri").val();
    let depth = $("#python").prop("checked") ? 50 : 1000;  // Not so deep for Python.
    let tile = $("#cpp").prop("checked")    ? "/tile/-" :
               $("#python").prop("checked") ? "/python_tile/" :
                                              "/tile/";
    var urlSource = "http://" + host + ":" + port + tile + depth +
                    "/{z}/{x}/{y}" +
                    "?var1=" + $("#var1").prop("value") + "&var2=" + $("#var2").prop("value");
    console.log(urlSource);
    map = new ol.Map({
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
  $("#open_img").click(function (evt) {
    image = map = null;
    let host = $("#host").val();
    let port = $("#port").val();
    let uri = $("#uri").val();
    let max_depth = $("#python").prop("checked") ? 50 : 1000;  // Not so deep for Python.
    // The image as it *should* currently be displayed.
    desired_image_properties = new MandelbrotView(0.0, 0.0, 1.0, 256, 256, max_depth)
    // The image last requested.
    requested_image_properties = null;
    // The most recent image loaded (requested and returned).
    available_image_properties = null;
    let urlSource = `http://${host}:${port}/img?data=${desired_image_properties.getImageURLParamsArrayJSON()}` +
                    `&var1=${$("#var1").prop("value")}&var2=${$("#var2").prop("value")}`;
    console.log(urlSource);
    // Empty the target div to remove any prior Map.
    $("#myImage").html(`<img id="mandelbrot_img" src="${urlSource}">`);
    
    // Make image interactive.
    this.PINCH_SLUGGISHNESS = 30;
    
    // `true` if the content is being dragged, and click events for highlighting should be ignored.
    this.dragging = false;

    // {int} A bit mask of the zoom button bit for interactjs event.button.
    this.ZOOM_BUTTON_MASK = 4;
    // {int} Controls the sensitivity of mouse-drag zoom.
    this.ZOOM_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of pinch zoom.
    this.PINCH_SLUGGISHNESS = 30;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PIXELS = 200;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_LINES = 10;
    // {int} Controls the sensitivity of wheel zoom.
    this.WHEEL_ZOOM_SLUGGISHNESS_PAGES = 1;

    interact("#mandelbrot_img")
      .draggable({
        inertia: true
      })
      .gesturable({
        onmove: (e) => {
          e.preventDefault();
          // This isn't the right formula for pinch action. Quick and dirty, untested.
          desired_image_properties.zoomBy(1 + e.ds / this.PINCH_SLUGGISHNESS);
        }
      })
      // Prevent "scroll-down to reload the page" on mobile while moving the content around
      .on('touchmove', (e) => {
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
        e.preventDefault();
        if ((e.buttons & this.ZOOM_BUTTON_MASK) != 0) {
          desired_image_properties.zoomBy(-1 * e.dy / this.ZOOM_SLUGGISHNESS);
        } else {
          desired_image_properties.panBy(e.dx, e.dy);
        }
      })
      .on("wheel", (e) => {
        e.preventDefault()
        if (!exists(e, ["originalEvent.deltaY"]) || !exists(e.originalEvent, ["deltaMode"])) {
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
        desired_image_properties.zoomBy(-1 * e.originalEvent.deltaY / sluggishness);
      });
  });
}