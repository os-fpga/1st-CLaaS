function demo() {
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
    image = new MandelbrotImage(0.0, 0.0, 1.0, 256, 256, max_depth)
    let urlSource = `http://${host}:${port}/img?data=${image.getImageURLParamsArrayJSON()}` +
                    `&var1=${$("#var1").prop("value")}&var2=${$("#var2").prop("value")}`;
    console.log(urlSource);
    // Empty the target div to remove any prior Map.
    $("#myImage").html(`<img src="${urlSource}">`);
  })
}