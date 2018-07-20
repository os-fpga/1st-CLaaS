import sys
sys.path.append('../../../framework/webserver')
from server import *


"""
Generic Mandelbrot functionality, independent of the server.
"""
class Mandelbrot():

  @staticmethod
  def getImage(img_width, img_height, x, y, pix_x, pix_y, max_depth):
    # dummy image generation
    print "Producing image %i, %i, %f, %f, %f, %f, %i" % (img_width, img_height, x, y, pix_x, pix_y, max_depth)
    #self.img = Image.new('RGB', (256, 256), (int(x)*18%256, int(y)*126%256, int(pix_x)*150%256))
    image = Image.new('RGB', (img_width, img_height))  # numpy.empty([img_width, img_height])
    pixels = image.load()
    bail_cnt = 10000000
    for v in range(img_height):
      y_pos = y + float(v) * pix_y
      for h in range(img_width):
        x_pos = x + float(h) * pix_x
        pixels[h, v] = Mandelbrot.depthToPixel(Mandelbrot.getPixelDepth(x_pos, y_pos, max_depth))
        bail_cnt -= 1
        if bail_cnt <= 0:
          raise ValueError
      bail_cnt -= 1
      if bail_cnt <= 0:
        raise ValueError
    #self.img = Image.fromarray(img_array, 'RGB')
    return image
 
  @staticmethod
  def getPixelDepth(x, y, max_iteration):
    x0 = x
    y0 = y
    iteration = 0
    while (x*x + y*y < 2*2 and iteration < max_iteration):
      xtemp = x*x - y*y + x0
      y = 2*x*y + y0
      x = xtemp
      iteration += 1
    return iteration
  
  @staticmethod
  def depthToPixel(depth):
    return ((depth * 16) % 256, 0, 0)

"""
Handler for .png image GET requests
Can be:
  get(self, "tile", tile_z, tile_x, tile_y), based on openlayers API,
    and (TODO) depth (max iterations) is currently hardcoded
Or:
  get(self, "img")
    with GET query argument ?data=[x,y,pix_x,pix_y,img_width,img_height,depth] as a JSON string
    where: x/y are float top,left mandelbrot coords
           pix_x/y are float pixel sizes in mandelbrot coords
           img_width/height are integers (pixels), and
           depth is the max iteration level as an integer; negative depths will force generation in host app, not FPGA
In either case, integer query arguments var1 and var2 can also be provided for use in C rendering only.
"""
class ImageHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "image/png")

    # handles image request via get request 
    def get(self, type, depth=u'1000', tile_z=None, tile_x=None, tile_y=None):

        # Determine who should produce the image.
        # For tiles, we use type = "python_type" to force Python, or a negative depth to force C++
        # (because this is what the C++ code looks for); otherwise the GET query arg "renderer"
        # can be specified to force the renderer.
        renderer = "python" if (type == "python_tile") else "c" if (int(depth) < 0) else self.get_query_argument("renderer", None)
        print "Renderer: %s" % renderer
        
        # Extract URL parameters.
        if (len(self.get_query_arguments("var1")) > 0):
            var1 = self.get_query_arguments("var1")[0]
        else:
            var1 = "0"
        if (len(self.get_query_arguments("var2")) > 1):
            var2 = self.get_query_arguments("var2")[0]
        else:
            var2 = "0"
        print "Query Args: var1: " + var1 + ", var2: " + var2
        
        # Determine image parameters from GET parameters
        if type == "tile" or type == "python_tile":
            print "Get tile image z:%s, x:%s, y:%s, depth:%s, var1:%s, var2:%s" % (tile_z, tile_x, tile_y, depth, var1, var2)
        
            # map parameters to those expected by FPGA, producing 'payload'.
            tile_size = 4.0 / 2.0 ** float(tile_z)    # size of tile x/y in Mandelbrot coords
            x = -2.0 + float(tile_x) * tile_size
            y = -2.0 + float(tile_y) * tile_size
            pix_x = tile_size / 256.0
            pix_y = pix_x
            payload = [x, y, pix_x, pix_y, 256, 256, int(depth)]
            print "Payload from web server: %s" % payload
        elif type == "img":
            payload_str = self.get_query_argument("data", None)
            try:
                payload = json.loads(payload_str)
            except ValueError, e:
                print "Invalid JSON in '?data=%s' URL parameter." % payload_str
                # TODO: Return a bad image
                return
            #print(payload)
        else:
            print "Unrecognized type arg in ImageHandler.get(..)"

        # Append var1 and var2 for C++ rendering only.
        if renderer == "c":
            payload.append(int(var1))
            payload.append(int(var2))
        img_data = self.application.renderImage(payload, renderer)

        self.write(img_data)


"""
MAIN APPLICATION
"""
class MandelbrotApplication(FPGAServerApplication):
    """
    Get an image from the appropriate renderer (as requested/available).
    """
    def renderImage(self, payload, renderer):
        # Create image
        if self.sock == None or renderer == "python":
            # No socket. Generate image here, in Python.
            outputImg = io.BytesIO()
            img = Mandelbrot.getImage(payload[4], payload[5], payload[0], payload[1], payload[2], payload[3], payload[6])
            img.save(outputImg, "PNG")  # self.write expects an byte type output therefore we convert image into byteIO stream
            img_data = outputImg.getvalue()
        else:
            # Send image parameters over socket.
            img_data = self.handle_request(GET_IMAGE, payload, False)
        return img_data


if __name__ == "__main__":
    dir = os.path.dirname(__file__)
    application = MandelbrotApplication(
            [ (r"/()", BasicFileHandler, {"path": dir + "/html", "default_filename": "index.html"}),
              (r"/(.*\.html)", BasicFileHandler, {"path": dir + "/html"}),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": dir + "/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": dir + "/js"}),
              (r'/ws', WSHandler),
              #(r'/hw', GetRequestHandler),
              (r'/(img)', ImageHandler),
              (r"/(?P<type>\w*tile)/(?P<depth>[^\/]+)/(?P<tile_z>[^\/]+)/?(?P<tile_x>[^\/]+)?/?(?P<tile_y>[^\/]+)?", ImageHandler),
            ]
        )
