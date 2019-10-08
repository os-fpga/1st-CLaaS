"""
BSD 3-Clause License

Copyright (c) 2018, alessandrocomodi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""


import sys
import os
import signal
import re
sys.path.append('../../../framework/webserver')
from server import *
import unicodedata


# TODO: I have no idea how threading works with this server. If requests are processed serially, we have performance issues.
#       If they are processed in parallel we have bugs with simultaneous use of the socket and file system. Testing indicates
#       that processing is serial.

"""
Generic Mandelbrot functionality, independent of the server.
"""
class Mandelbrot():

  @staticmethod
  def getImage(img_width, img_height, x, y, pix_x, pix_y, max_depth):
    # dummy image generation
    #print("Producing image %i, %i, %f, %f, %f, %f, %i" % (img_width, img_height, x, y, pix_x, pix_y, max_depth))
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
        print("Redeploying.")
        os.kill(os.getppid(), signal.SIGUSR1)

"""
Handler for .png image GET requests
Request should contain query arg json={...}.
Can be:
  get(self, "tile", depth, tile_z, tile_x, tile_y), based on openlayers API. json query arg is optional.
Or:
  get(self, "img")
    with GET query json variables:
       - x/y are float top,left mandelbrot coords
       - pix_x/y are float pixel sizes in mandelbrot coords
       - width/height are image width/height in pixels (integers), and
       - max_depth is the max iteration level as an integer
           ...
In either case, integer json query arguments var1, var2, three_d, modes, color_scheme, spot_depth, center_offset_w, center_offset_h, eye_sep, darken, brighten, and eye_adjust, ... can also be provided (used in C rendering only).
"""
class ImageHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "image/png")

    @staticmethod
    def valid_dirname(dir):
        return re.match("^\w+$", dir)

    # handles image request via get request
    def get(self, type, depth=u'1000', tile_z=None, tile_x=None, tile_y=None):

        json_str = self.get_query_argument("json", False)

        if (json_str == False):
            print("Python: No json query argument for ImageHandler")
            return

        json_obj = json.loads(json_str)

        try:
            burn_subdir = json_obj["burn_dir"]
        except:
            burn_subdir = ""
        try:
            burn_frame = json_obj["burn_frame"]
        except:
            burn_frame = ""
        try:
            burn_first = json_obj["burn_first"]
        except:
            burn_first = False
        try:
            burn_last = json_obj["burn_last"]
        except:
            burn_last = False
        try:
            cast_subdir = json_obj["cast"]
        except:
            cast_subdir = ""

        # Determine image parameters from GET parameters
        if type == "tile":
            #print("Get tile image z:%s, x:%s, y:%s, depth:%s, var1:%s, var2:%s" % (tile_z, tile_x, tile_y, depth, var1, var2))

            # map parameters to those expected by FPGA, producing 'payload'.
            tile_size = 4.0 / 2.0 ** float(tile_z)    # size of tile x/y in Mandelbrot coords
            x = -2.0 + (float(tile_x) + 0.5) * tile_size
            y = -2.0 + (float(tile_y) + 0.5) * tile_size
            pix_x = tile_size / 256.0
            pix_y = pix_x
            #payload = [x, y, pix_x, pix_y, 256, 256, int(depth)]
            json_obj["x"] = x
            json_obj["y"] = y
            json_obj["pix_x"] = pix_x
            json_obj["pix_y"] = pix_y
            json_obj["width"] = 256
            json_obj["height"] = 256
            json_obj["max_depth"] = int(depth)
            #print("Payload from web server: %s" % payload)
            json_str = json.dumps(json_obj)
        elif type == "img":
            dummy = 0
        else:
            print("Unrecognized type arg in ImageHandler.get(..)")

        img_data = self.application.renderImage(json_str, json_obj)
        self.write(img_data)


        # Burn?
        # Validate dir name.
        ok = self.valid_dirname(burn_subdir)
        if ok:
            burn_dir = "video/" + burn_subdir
            if burn_first:
                # Create directory for images.
                try:
                    # Remove any existing directory (which should only be leftover from a failure).
                    if not subprocess.call("rm -rf " + burn_dir, shell=True):
                        print("Remove pre-existing directory " + burn_dir + " for video creation.")
                    os.makedirs(burn_dir)
                    print("Successfully created the directory %s " % burn_dir)
                except OSError:
                    print("Creation of the directory %s failed" % burn_dir)
            # Write file.
            filepath = burn_dir + "/" + str(burn_frame) + ".png"
            try:
                file = open(filepath, "w")
                file.write(img_data)
                file.close()
                if burn_last:
                    # Got all the images, now convert to video and clean up.
                    try:
                        mp4_name = burn_dir + ".mp4"
                        print("Burning video " + mp4_name)
                        # Delete existing video.
                        if not subprocess.call("rm " + mp4_name, shell=True):
                            print("Removed pre-existing video " + mp4_name)
                        # Create video from images.
                        if subprocess.call("ffmpeg -framerate 24 -i " + burn_dir + "/%d.png " + mp4_name, shell=True):
                            sys.stderr.write("ffmpeg command failed.")
                        else:
                            print("Burned video as %s" % mp4_name)
                            if subprocess.call("rm -rf " + burn_dir, shell=True):
                                sys.stderr. write("failed to remove images in " + burn_dir)
                    except Error:
                        sys.stderr.write("Failed to convert images to video.")
            except IOError:
                print("Failed to write file %s" % filepath)

        # Cast?
        # Validate dir name.
        ok = self.valid_dirname(cast_subdir)
        if ok:
            #print("Casting: %s" % cast_subdir)
            # Cast. Steps are:
            #   o Remove old directory if it exists.
            #   o Create new directory.
            #   o Write the image file.
            cast_dir = "cast/" + cast_subdir
            #   o Remove old directory if it exists.
            subprocess.call("rm -rf " + cast_dir, shell=True)
            #   o Create new directory.
            os.makedirs(cast_dir)
            #   o Write the image file.
            filepath = cast_dir + "/" + "img.png"
            try:
                file = open(filepath, "w")
                file.write(img_data)
                file.close()
            except IOError:
                print("Failed to write file %s" % filepath)

"""
Handler for requesting an image generated by another client.
Other client is presumably "casting" its images, so the most recent image is saved, and this request will retrieve it.
If this client last requested the same image, the next image generated will be returned when available -- no...
For now, requests are processed serially, so we return whatever we have. This is simplest and will tend to result in
reasonable behavior where observers queue up a single request for each image.
"""
class ObserveImageHandler(ImageHandler):

    """
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "image/png")
        self.set_header("Cache-Control", "no-cache")  # (Doesn't do the trick.)
    """

    """
    Get the current or next image produced by a different client. Next if this client has already requested the current one.
    tag: A string shared by producing and consuming clients to identify the image series (also the directory name, as with burning video).
    """
    def get(self, tag):
        ok = self.valid_dirname(tag)
        if ok:
            # Steps:
            #   o If the image doesn't exist, or the image is already tagged with this client, return error (indicating no-update).
            #   o Tag image with this client (as a file in the tag directory).
            #   o Return image.
            x_real_ip = self.request.headers.get("X-Real-IP")
            remote_ip = x_real_ip or self.request.remote_ip
            client_flag_filename = "cast/" + tag + "/ip-" + remote_ip
            if os.path.isfile(client_flag_filename):
                return

            # Create flag file.
            open(client_flag_filename, 'w').close()

            filepath = "cast/" + tag + "/img.png"
            with open(filepath, 'rb') as f:
                while 1:
                    img_data = f.read(16384) # or some other nice-sized chunk
                    if not img_data: break
                    self.write(img_data)

"""
MAIN APPLICATION
"""
class MandelbrotApplication(FPGAServerApplication):
    
    def __init__(self, args):
        if args["instance"]:
            # TODO: THIS IS NOT CORRECT FOR MULTIPLE USERS. NEED ONLY THE FIRST USER TO START THE WEBSERVER.
            self.associateEC2Instance()
        routes = self.defaultRoutes(ip=True)  # ip route is used by framework as a ping for F1.
        routes.extend(
            [ (r"/redeploy", RedeployHandler),
              #(r'/hw', GetRequestHandler),
              (r'/(img)', ImageHandler),
              (r'/observe_img/(?P<tag>[^\/]+)', ObserveImageHandler),
              (r"/(?P<type>\w*tile)/(?P<depth>[^\/]+)/(?P<tile_z>[^\/]+)/?(?P<tile_x>[^\/]+)?/?(?P<tile_y>[^\/]+)?", ImageHandler),
            ])
        super(MandelbrotApplication, self).__init__(routes, args)
        
    
    """
    Get an image from the appropriate renderer (as requested/available).
    """
    def renderImage(self, settings_str, settings):
        # Create image
        #print(settings)
        if self.socket == None or settings["renderer"] == "python":
            # No socket. Generate image here, in Python.
            outputImg = io.BytesIO()
            img = Mandelbrot.getImage(settings["width"], settings["height"], settings["x"], settings["y"], settings["pix_x"], settings["pix_y"], settings["max_depth"])
            img.save(outputImg, "PNG")  # self.write expects an byte type output therefore we convert image into byteIO stream
            img_data = outputImg.getvalue()
        else:
            # Send image parameters over socket.
            #print("Python sending to C++: ", payload)
            img_data = get_image(self.socket, GET_IMAGE, settings_str, False)
        return img_data

if __name__ == "__main__":

    # Command-line options
    args = FPGAServerApplication.commandLineArgs([], FPGAServerApplication.EC2Args())
    
    print("Mandelbrot webserver application starting.")

    application = MandelbrotApplication(args)
    application.run()
