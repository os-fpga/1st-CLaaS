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
import tornado.ioloop
import tornado.web
import socket
import sys
import json
import base64
from server_api import *

# Socket with host defines
SOCKET        = "SOCKET"

# Server defines
PORT          = 8080

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
    (r'/ws', WSHandler),
    (r'/hw', GetRequestHandler),
    (r'/(client\.html)', tornado.web.StaticFileHandler, {'path': r'./'}),
  ])

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
    sock.connect(server_address)

    return sock

### This function dispatches the request based on the header information
def handle_request(header, payload):
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
