// Get renderer from GUI as "python", "cpp", or "fpga".
function getRenderer() {
  return $("#python").prop("checked") ? "python" : $("#cpp").prop("checked") ? "cpp" : "fpga";
}
function getVar1() {
  return $("#var1").prop("value");
}
function getVar2() {
  return $("#var2").prop("value");
}
function getMaxDepth() {
  var d = $("#sqrt_depth").prop("value");
  return d * d;
}
function get3d() {
  return $("#3d").prop("checked") ? 1 : 0;
}
function getDarken() {
  return $("#darken").prop("checked") ? 1 : 0;
}


function imageQueryArgs() {
  return "var1=" + getVar1() + "&var2=" + getVar2() + "&three_d=" + get3d() + "&darken=" + getDarken() + "&renderer=" + getRenderer();
}

function demo() {
  window.debug = 0;  // 0/1 to disable/enable in-browser debug messages.
  
  var host;
  var port;
  var uri;
  var map = null;  // The open map, or null.
  var viewer = null;  // The open FullImageMandelbrotViewer, or null.
  function destroy_viewer() {
    if (viewer) {
      viewer.destroy();
      viewer = null;
    }
    if (map) {
      map = null;
    }
    $("#myImage").html("");
  }
  $("#renderer input").change(function (evt) {
    if (map) {
      console.log("Unwritten code.");
    }
    if (viewer) {
      viewer.desired_image_properties.renderer = getRenderer();
    }
  })
  $("#modes input").change(function (evt) {
    if (map) {
      console.log("Unwritten code.");
    }
    if (viewer) {
      viewer.desired_image_properties.three_d = get3d();
      viewer.desired_image_properties.darken = getDarken();
    }
  })
  $(".var").on("input", function (evt) {
    if (map) {
      console.log("Unwritten code.");
    }
    if (viewer) {
      viewer.desired_image_properties.var1 = getVar1();
      viewer.desired_image_properties.var2 = getVar2();
      viewer.desired_image_properties.max_depth = getMaxDepth();
    }
  })
  $("#open_map").click(function (evt) {
    destroy_viewer();
    let host = $("#host").val();
    let port = $("#port").val();
    let uri = $("#uri").val();
    let tile = "/tile/";
    var urlSource = "http://" + host + ":" + port + tile + getMaxDepth() +
                    "/{z}/{x}/{y}?" + imageQueryArgs();
    console.log(`Image URL: ${urlSource}`);
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
  $("#open_img").click((evt) => {
    destroy_viewer();
    
    // The image as it *should* currently be displayed.
    viewer = new FullImageMandelbrotViewer(
                    $("#myImage"), $("#host").val(), $("#port").val(),
                    new MandelbrotView(0.0, 0.0, 1.0, 256, 256, getMaxDepth(), getRenderer(),
                                       getVar1(), getVar2(), get3d(), getDarken()
                                      )
                 );
  });
}