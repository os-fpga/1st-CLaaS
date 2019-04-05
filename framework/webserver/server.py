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


# Socket with host defines
SOCKET        = "SOCKET"

# Communication protocol defines
WRITE_DATA    = "WRITE_DATA"
READ_DATA     = "READ_DATA"
GET_IMAGE     = "GET_IMAGE"


# A simple override of
class BasicFileHandler(tornado.web.StaticFileHandler):
    def set_extra_headers(self, path):
        self.set_header("Cache-control", "no-cache")

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
    payload = json.dumps(msg['payload'])

    # The request is passed to a request handler which will process the information contained
    # in the message and produce a result
    result = self.application.handle_request(header, payload)

    # The result is sent back to the client
    self.write_message(result)

  def on_close(self):
    print('Connection closed')

  def check_origin(self, origin):
    return True


# This class can be overridden to provide application-specific behavior.
class FPGAServerApplication(tornado.web.Application):
    def initSocket(self, port):
        # Opening socket with host
        self.sock = self.__class__.getSocket()

        # Setting IP
        myIP = socket.gethostbyname(socket.gethostname())
        print '*** Websocket Server Started at %s***:%i' % (myIP, port)

    # Return an array containing default routes.
    # Args:
    #   dir: Application's webserver directory containing /html, /js, /css directories.
    @staticmethod
    def defaultContentRoutes(dir):
        mydir = os.path.dirname(__file__)
        return [
              (r"/()", BasicFileHandler, {"path": dir + "/html", "default_filename": "index.html"}),
              (r"/(.*\.html)", BasicFileHandler, {"path": dir + "/html"}),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": dir + "/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": dir + "/js"}),
              (r"/(fpgaServer.js)", BasicFileHandler, {"path": mydir + "/js"})
            ]


    # Create socket communication with the Host application
    @staticmethod
    def getSocket():
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server_address = (SOCKET)
        try:
            sock.connect(server_address)
        except socket.error, e:
            sock = None
            print "Couldn't connect to host application via socket."

        return sock

    ### This function dispatches the request based on the header information
    # TODO: Cleanup the API. These commands and handshakes aren't necessary. Just send parameters and return image.
    def handle_request(self, header, payload, b64=True):
        if self.sock == None:
            response = "No socket"
        else:
            #print "get image:", payload, b64
            response = get_image(self.sock, header, payload, b64)

        ret = {'type': 'user', 'png': response}
        if not b64:
            ret = response
        return ret


    def __init__(self, handlers, port):
        self.initSocket(port)
        super(FPGAServerApplication, self).__init__(handlers)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(port)
        # Starting webserver
        tornado.ioloop.IOLoop.instance().start()
