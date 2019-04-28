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

"""
#
# This is the main python webserver which accepts WebSocket connections as well as
# Get requests from a client on port 8888.
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
import time
import subprocess
import json
import base64
import errno
from socket import error as socket_error
#import numpy
from server_api import *



## Communication protocol defines
#WRITE_DATA    = "WRITE_DATA"
#READ_DATA     = "READ_DATA"
GET_IMAGE     = "GET_IMAGE"


# A simple override of
class BasicFileHandler(tornado.web.StaticFileHandler):
    def set_extra_headers(self, path):
        self.set_header("Cache-control", "no-cache")

### Handler for WebSocket connections
# Messages on the WebSocket are expected to be JSON of the form:
# {'type': 'MY_TYPE', 'payload': MY_PAYLOAD}
# TODO: Change this to send type separately, so the JSON need not be parsed if passed through.
# The application has a handler method for each type, registered via FPGAServerApplication.registerMessageHandler(type, handler), where
# 'handler' is a method of the form: json_response = handler(self, payload)
class WSHandler(tornado.websocket.WebSocketHandler):
  def open(self):
    print('New connection')

  # This function activates whenever there is a new message incoming from the WebSocket
  def on_message(self, message):
    msg = json.loads(message)
    response = {}
    print(message)
    type = msg['type']
    payload = msg['payload']

    # The request is passed to a request handler which will process the information contained
    # in the message and produce a result
    #-result = self.application.handle_request(type, payload)
    try:
        result = self.application.message_handlers[type](payload)
    except KeyError:
        print "Unrecognized message type:", header
    
    # The result is sent back to the client
    self.write_message(result)

  def on_close(self):
    print('Connection closed')

  def check_origin(self, origin):
    return True


# This class can be overridden to provide application-specific behavior.
class FPGAServerApplication(tornado.web.Application):
    
    # Return an array containing default routes into ../webserver/{html,css,js}
    @staticmethod
    def defaultContentRoutes():
        dir = os.getcwd() + "/../webserver"
        mydir = os.path.dirname(__file__)
        routes = [
              (r"/()", BasicFileHandler, {"path": dir + "/html", "default_filename": "index.html"}),
              (r'/ws', WSHandler),
              (r"/(.*\.html)", BasicFileHandler, {"path": dir + "/html"}),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": dir + "/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": dir + "/js"}),
              (r"/(fpgaServer.js)", BasicFileHandler, {"path": mydir + "/js"})
            ]
        return routes

    
    # Register a message handler.
    # 
    def registerMessageHandler(self, type, handler):
        self.message_handlers = {type: handler}
    
    
    # Handler for GET_IMAGE.
    def handleGetImage(self, payload):
        print "handleGetImage:", payload
        response = get_image(self.socket, "GET_IMAGE", payload, True)
        return {'type': 'user', 'png': response}

    def __init__(self, handlers, port):
        self.socket = Socket(port)
        super(FPGAServerApplication, self).__init__(handlers)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(port)
        
        self.message_handlers = {"GET_IMAGE": self.handleGetImage}
        
        # Starting webserver
        tornado.ioloop.IOLoop.instance().start()
