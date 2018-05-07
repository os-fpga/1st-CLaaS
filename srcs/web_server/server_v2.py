"""
#
# This is the main python webserver which accepts WebSocket connections as well as 
# Get requests from a client on port 8080.
# 
# The process is single threaded and all the requests are served synchronously and in order.
#
# The web server interfaces with the host application through a UNIX socket communication
# in order to send commands and data to the FPGA
#
# Author: Alessandro Comodi, Politecnico di Milano
#
"""

import tornado.httpserver
import tornado.websocket
import os.path
from PIL import Image
import io
import tornado.ioloop
import tornado.web
import socket
import sys
import json
import base64
#import numpy
from server_api import *

# Socket with host defines
SOCKET        = "SOCKET"

# Server defines
PORT          = 8888

# Communication protocol defines
WRITE_DATA    = "WRITE_DATA"
READ_DATA     = "READ_DATA"
GET_IMAGE     = "GET_IMAGE"

# Error Messages
INVALID_DATA  = "The client sent invalid data"

sock = None

### Handler for WebSocket connections
class WSHandler(tornado.websocket.WebSocketHandler):
  def open(self):
    print('New connection')

  # This function activates whenever there is a new message incoming from the WebSocket
  def on_message(self, message):
    msg = json.loads(message)
    response = {}
    print(message)
    header = msg['type']
    payload = msg['payload']

    # The request is passed to a request handler which will process the information contained
    # in the message and produces a result
    result = handle_request(header, payload)

    # The result is sent back to the client
    self.write_message(result)

  def on_close(self):
    print('Connection closed')

  def check_origin(self, origin):
    return True

class MainHandler(tornado.web.RequestHandler):
    # renders main home page
    def get(self):
       self.render("index.html")
       
class HTMLHandler(tornado.web.RequestHandler):
    # render HTML page
    def get(self, file):
       self.render(file)

### Handler for .png image GET requests
class ImagesHandler(tornado.web.RequestHandler):
  # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
  def set_default_headers(self):
    self.set_header("Access-Control-Allow-Origin", "*")
    self.set_header("Access-Control-Allow-Headers", "x-requested-with")
    self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
    self.set_header("Connection", "keep-alive")
    self.set_header("Content-Type", "image/png")

  # handles image request via get request 
  def get(self, tile_z, tile_x, tile_y):
    print "Get image %s, %s, %s" % (tile_z, tile_x, tile_y)
    
    # map parameters to those expected by FPGA.
    tile_size = 4.0 / 2.0 ** float(tile_z)  # size of tile x/y in Mandelbrot coords
    x = -2.0 + float(tile_x) * tile_size
    y = -2.0 + float(tile_y) * tile_size
    pix_x = tile_size / 256.0
    pix_y = pix_x
    
    outputImg = io.BytesIO()
    self.img = self.getMandelbrotImage(256, 256, x, y, pix_x, pix_y)
    self.img.save(outputImg, "PNG")  # self.write expects an byte type output therefore we convert image into byteIO stream
    self.write(outputImg.getvalue())  #we get actual data write it to front end

  def getMandelbrotImage(self, img_width, img_height, x, y, pix_x, pix_y):
    # dummy image generation
    print "Producing image %i, %i, %f, %f, %f, %f" % (img_width, img_height, x, y, pix_x, pix_y)
    #self.img = Image.new('RGB', (256, 256), (int(x)*18%256, int(y)*126%256, int(pix_x)*150%256))
    image = Image.new('RGB', (img_width, img_height))  # numpy.empty([img_width, img_height])
    pixels = image.load()
    for v in range(img_height):
      y_pos = y + float(v) * pix_y
      for h in range(img_width):
        x_pos = x + float(h) * pix_x
        pixels[h, v] = self.depthToPixel(self.getPixelDepth(x_pos, y_pos))
    #self.img = Image.fromarray(img_array, 'RGB')
    return image
    
  def getPixelDepth(self, x, y):
    x0 = x
    y0 = y
    x = 0.0
    y = 0.0
    iteration = 0
    max_iteration = 50  # TODO: PARAMETERIZE THIS
    while (x*x + y*y < 2*2  and iteration < max_iteration):
      xtemp = x*x - y*y + x0
      y = 2*x*y + y0
      x = xtemp
      iteration += 1
    return iteration
  
  def depthToPixel(self, depth):
    return ((depth * 16) % 256, 0, 0)

  # Get request handler
  def get_old(self):
    # Acquiring all the parameters contained in the get request
    header = self.get_query_argument("type", None)
    payload = json.loads(self.get_query_argument("data", None))
    url = self.get_query_argument("url", None)
    print(header)
    print(payload)

    # The request is passed to a request handler which will process the information contained
    # in the message and produces a result
    result = handle_request(header, payload)
    
    # Depending on how the Get request has been performed the response will be different.
    #   - URL request: the response will be an html page containing the Mandelbrot image
    #   - Javascript: the response is in JSON format
    if url == "true":
      response = "<html><img id='mandelbrot' src='data:image/png;base64,%s'></html>" % result['data']
    else:
      response = result
    self.write(response)


### Handler for Get requests
class GetRequestHandler(tornado.web.RequestHandler):
  # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
  def set_default_headers(self):
    self.set_header("Access-Control-Allow-Origin", "*")
    self.set_header("Access-Control-Allow-Headers", "x-requested-with")
    self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')

  # Get request handler
  def get(self):

    # Acquiring all the parameters contained in the get request
    header = self.get_query_argument("type", None)
    payload = json.loads(self.get_query_argument("data", None))
    url = self.get_query_argument("url", None)
    print(header)
    print(payload)

    # The request is passed to a request handler which will process the information contained
    # in the message and produces a result
    result = handle_request(header, payload)
    
    # Depending on how the Get request has been performed the response will be different.
    #   - URL request: the response will be an html page containing the Mandelbrot image
    #   - Javascript: the response is in JSON format
    if url == "true":
      response = "<html><img id='mandelbrot' src='data:image/png;base64,%s'></html>" % result['data']
    else:
      response = result
    self.write(response)

"""
MAIN APPLICATION
"""
def main():
  # Opening socket with host
  global sock

  sock = get_socket()

  application = tornado.web.Application([
    (r"/", MainHandler),
    (r"/(.*\.html)", HTMLHandler),
    (r'/ws', WSHandler),
    (r'/hw', GetRequestHandler),
    (r"/images/(?P<tile_z>[^\/]+)/?(?P<tile_x>[^\/]+)?/?(?P<tile_y>[^\/]+)?", ImagesHandler),
  ],
  template_path = os.path.join(os.path.dirname(__file__), "templates"),
  static_path = os.path.join(os.path.dirname(__file__), "static")
  )

  # Configuring the http server
  http_server = tornado.httpserver.HTTPServer(application)
  http_server.listen(PORT)

  # Setting IP
  myIP = socket.gethostbyname(socket.gethostname())
  print('*** Websocket Server Started at %s***' % myIP)
  
  # Starting webserver
  tornado.ioloop.IOLoop.instance().start()

### Function that creates a socket communication with the Host application
def get_socket():
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server_address = (SOCKET)
    try:
        sock.connect(server_address)
    except socket.error, e:
        sock = None
        print "Couldn't connect to host application via socket."

    return sock

### This function dispatches the request based on the header information
def handle_request(header, payload):
  if sock == None:
    response = INVALID_DATA
  if header == WRITE_DATA:
    response = write_data_handler(sock, False, header, payload)
  elif header == READ_DATA:
    response = read_data_handler(sock, False, header)
  elif header == GET_IMAGE:
    response = get_image(sock, header, payload)
  elif header:
    response = socket_send_command(sock, header)
  else:
    response = INVALID_DATA

  return {'type' : header, 'data': response}

if __name__ == "__main__":
  main()
