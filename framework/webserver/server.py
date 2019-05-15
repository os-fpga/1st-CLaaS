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
    print "Python: ws.on_message:", message
    type = msg['type']
    payload = msg['payload']

    # The request is passed to a request handler which will process the information contained
    # in the message and produce a result
    #-result = self.application.handle_request(type, payload)
    try:
        result = self.application.message_handlers[type](payload, type)
    except KeyError:
        print "Unrecognized message type:", type
    
    # The result is sent back to the client
    print "Python: Responding with:", result
    self.write_message(result)

  def on_close(self):
    print('Connection closed')

  def check_origin(self, origin):
    return True


"""
Handler for Real IP address GET requests (no default route for this)
This can be useful if a proxy is used to server the http requests, but a WebSocket must be opened directly.
"""
class IPReqHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "text/plain")

    # handles image request via get request
    def get(self):
        ip = FPGAServerApplication.external_ip
        if (ip == None):
            ip = ""
        #ip_str = socket.gethostbyname(socket.gethostname())
        self.write(ip)


# This class can be overridden to provide application-specific behavior.
class FPGAServerApplication(tornado.web.Application):
    
    # Return an array containing default routes into ../webserver/{html,css,js}
    @staticmethod
    def defaultContentRoutes():
        dir = os.getcwd() + "/../webserver"
        mydir = os.path.dirname(__file__)
        routes = [
              (r"/framework/js/(.*)", BasicFileHandler, {"path": mydir + "/js"}),
              (r"/framework/css/(.*)", BasicFileHandler, {"path": mydir + "/css"}),
              (r"/framework/(.*\.html)", BasicFileHandler, {"path": mydir + "/html"}),
              (r"/()", BasicFileHandler, {"path": dir + "/html", "default_filename": "index.html"}),
              (r'/ws', WSHandler),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": dir + "/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": dir + "/js"}),
              (r"/(.*\.html)", BasicFileHandler, {"path": dir + "/html"})
            ]
        return routes

    
    # Register a message handler.
    # 
    def registerMessageHandler(self, type, handler):
        self.message_handlers[type] = handler
    
    
    # Handler for GET_IMAGE.
    def handleGetImage(self, payload, type):
        print "handleGetImage:", payload
        response = get_image(self.socket, "GET_IMAGE", payload, True)
        return {'type': 'user', 'png': response}
        
    def handleDataMsg(self, data, type):
        self.socket.send_string("command", type)
        self.socket.send_string("data", data)
        data = read_data_handler(self.socket, None, False)
        return data
    

    def __init__(self, handlers, port):
        self.socket = Socket()
        super(FPGAServerApplication, self).__init__(handlers)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(port)
        self.message_handlers = {}
        self.registerMessageHandler("GET_IMAGE", self.handleGetImage)
        self.registerMessageHandler("DATA_MSG", self.handleDataMsg)
        
        # Report external URL for the webserver.
        # Get Real IP Address using 3rd-party service.
        # Local IP: myIP = socket.gethostbyname(socket.gethostname())
        port_str = "" if port == 80 else  ":" + str(port)
        try:
            FPGAServerApplication.external_ip = subprocess.check_output(["wget", "-qO-", "ifconfig.me"])
            print '*** Websocket Server Started, (http://%s%s) ***' % (self.external_ip, port_str)
        except:
            print "Python: FPGAServerApplication failed to acquire external IP address."
            FPGAServerApplication.external_ip = None
            print '*** Websocket Server Started (http://localhost%s) ***' % port_str

        # Starting webserver
        tornado.ioloop.IOLoop.instance().start()
