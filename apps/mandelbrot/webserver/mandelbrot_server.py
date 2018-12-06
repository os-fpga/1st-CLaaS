import sys
import os
import signal
sys.path.append('../../../framework/webserver')
from server import *


"""
Generic Mandelbrot functionality, independent of the server.
"""
class Mandelbrot():

  @staticmethod
  def getImage(img_width, img_height, x, y, pix_x, pix_y, max_depth):
    # dummy image generation
    #print "Producing image %i, %i, %f, %f, %f, %f, %i" % (img_width, img_height, x, y, pix_x, pix_y, max_depth)
    #self.img = Image.new('RGB', (256, 256), (int(x)*18%256, int(y)*126%256, int(pix_x)*150%256))
    image = Image.new('RGB', (img_width, img_height))  # numpy.empty([img_width, img_height])
    pixels = image.load()
    bail_cnt = 10000000
    # Move x, y from center to upper-left.
    x -= float(img_width) * pix_x / 2.0;
    y -= float(img_width) * pix_y / 2.0;
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
Handler for /redeploy GET requests. These signal SIGUSR1 in the parent (launch script) process, which triggers
a pull of the latest git repo and teardown and re-launch of this web server and the host application.
"""
class RedeployHandler(tornado.web.RequestHandler):
    def get(self):
        print "Redeploying."
        os.kill(os.getppid(), signal.SIGUSR1)

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
In either case, integer query arguments var1, var2, three_d, modes, color_scheme, spot_depth, center_offset_w, center_offset_h, eye_sep, darken, brighten, and eye_adjust, test1/2 can also be provided (used in C rendering only).
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

        # Determine who should produce the image from the GET query arg "renderer".
        renderer = self.get_query_argument("renderer", "fpga")
        
        # Extract URL parameters.
        # TODO: This should all be JSON.
        if (len(self.get_query_arguments("var1")) > 0):
            var1 = self.get_query_arguments("var1")[0]
        else:
            var1 = "0"
        if (len(self.get_query_arguments("var2")) > 0):
            var2 = self.get_query_arguments("var2")[0]
        else:
            var2 = "0"
        if (len(self.get_query_arguments("three_d")) > 0):
            three_d = self.get_query_arguments("three_d")[0]
        else:
            three_d = "0"
        if (len(self.get_query_arguments("modes")) > 0):
            modes = self.get_query_arguments("modes")[0]
        else:
            modes = "0";
        if (len(self.get_query_arguments("colors")) > 0):
            color_scheme = self.get_query_arguments("colors")[0]
        else:
            color_scheme = "0";
        if (len(self.get_query_arguments("offset_w")) > 0):
            center_offset_w = self.get_query_arguments("offset_w")[0]
        else:
            center_offset_w = "0"
        if (len(self.get_query_arguments("offset_h")) > 0):
            center_offset_h = self.get_query_arguments("offset_h")[0]
        else:
            center_offset_h = "0"
        if (len(self.get_query_arguments("eye_sep")) > 0):
            eye_sep = self.get_query_arguments("eye_sep")[0]
        else:
            eye_sep = "0"
        if (len(self.get_query_arguments("darken")) > 0):
            darken = self.get_query_arguments("darken")[0]
        else:
            darken = "0"
        if (len(self.get_query_arguments("brighten")) > 0):
            brighten = self.get_query_arguments("brighten")[0]
        else:
            brighten = "0"
        if (len(self.get_query_arguments("eye_adjust")) > 0):
            eye_adjust = self.get_query_arguments("eye_adjust")[0]
        else:
            eye_adjust = "0"
        if (len(self.get_query_arguments("spot_depth")) > 0):
            spot_depth = self.get_query_arguments("spot_depth")[0]
        else:
            spot_depth = "-1";
        if (len(self.get_query_arguments("texture")) > 0):
            texture = self.get_query_arguments("texture")[0]
        else:
            texture = "0";
        if (len(self.get_query_arguments("edge")) > 0):
            edge_style = self.get_query_arguments("edge")[0]
        else:
            edge_style = "0";
        if (len(self.get_query_arguments("test_flags")) > 0):
            test_flags = self.get_query_arguments("test_flags")[0]
        else:
            test_flags = "0"
        test_vars = []
        for i in range(8):
            if (len(self.get_query_arguments("test%i" % i)) > 0):
                test_vars.append(self.get_query_arguments("test%i" % i)[0])
            else:
                test_vars.append("0")
        #print "Query Args: var1: " + var1 + ", var2: " + var2 + ", 3d: " + three_d + ", modes: " + modes + ", color_scheme" + colors_scheme + ", spot_depth" + spot_depth +
        #         ", offset_w: " + center_offset_w + ", offset_h: " + center_offset_h + ", eye_sep: " + eye_sep + ", darken: " + darken + ", brighten: " + brighten + ", eye_adjust: " + eye_adjust +
        #         ", test1: " + test1 + ", test2: " + test2 
        #print "Type: ", type, ", Renderer: ", renderer
        
        # Determine image parameters from GET parameters
        if type == "tile":
            #print "Get tile image z:%s, x:%s, y:%s, depth:%s, var1:%s, var2:%s" % (tile_z, tile_x, tile_y, depth, var1, var2)
        
            # map parameters to those expected by FPGA, producing 'payload'.
            tile_size = 4.0 / 2.0 ** float(tile_z)    # size of tile x/y in Mandelbrot coords
            x = -2.0 + (float(tile_x) + 0.5) * tile_size
            y = -2.0 + (float(tile_y) + 0.5) * tile_size
            pix_x = tile_size / 256.0
            pix_y = pix_x
            payload = [x, y, pix_x, pix_y, 256, 256, int(depth)]
            #print "Payload from web server: %s" % payload
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

        # Renderer is communicated to C++ as the sign of the depth. Negative for C++.
        if self.application.sock != None and renderer == "cpp":
            payload[6] = -payload[6]
        # Append parameters.
        payload.append(int(var1))
        payload.append(int(var2))
        payload.append(0 if three_d == "0" or type == "tile" else 1)
        payload.append(int(center_offset_w))
        payload.append(int(center_offset_h))
        payload.append(0 if darken == "0" else 1)
        payload.append(int(brighten))
        payload.append(int(eye_adjust))
        payload.append(int(eye_sep))
        payload.append(int(modes))
        payload.append(int(color_scheme))
        payload.append(int(spot_depth))
        payload.append(int(texture))
        payload.append(int(edge_style))
        payload.append(int(test_flags))
        for i in range(8):
          payload.append(int(test_vars[i]))
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
            #print "Python sending to C++: ", payload
            img_data = self.handle_request(GET_IMAGE, payload, False)
        return img_data


if __name__ == "__main__":
    dir = os.path.dirname(__file__)
    application = MandelbrotApplication(
            [ (r"/()", BasicFileHandler, {"path": dir + "/html", "default_filename": "index.html"}),
              (r"/(.*\.html)", BasicFileHandler, {"path": dir + "/html"}),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": dir + "/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": dir + "/js"}),
              (r"/redeploy", RedeployHandler),
              (r'/ws', WSHandler),
              #(r'/hw', GetRequestHandler),
              (r'/(img)', ImageHandler),
              (r"/(?P<type>\w*tile)/(?P<depth>[^\/]+)/(?P<tile_z>[^\/]+)/?(?P<tile_x>[^\/]+)?/?(?P<tile_y>[^\/]+)?", ImageHandler),
            ]
        )
