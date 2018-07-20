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
import time
import subprocess
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
    payload = msg['payload']

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
    def initSocket(self):
        # Opening socket with host
        self.sock = self.__class__.getSocket()

        # Setting IP
        myIP = socket.gethostbyname(socket.gethostname())
        print('*** Websocket Server Started at %s***' % myIP)


    ### Function that creates a socket communication with the Host application
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
        elif header == WRITE_DATA:
            print "handle_request(WRITE_DATA)"
            response = write_data_handler(self.sock, False, header, payload)
        elif header == READ_DATA:
            print "handle_request(WRITE_DATA)"
            response = read_data_handler(self.sock, False, header)
        elif header == GET_IMAGE:
            print(payload, b64)
            response = get_image(self.sock, header, payload, b64)
        elif header:
            print "handle_request(%s)" % header
            response = socket_send_command(self.sock, header)
        else:
            response = "The client sent invalid command (%s)" % header

        ret = {'type' : header, 'data': response}
        if not b64:
            ret = response
        return ret
    
    
    def __init__(self, handlers):
        self.initSocket()
        super(FPGAServerApplication, self).__init__(handlers)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(PORT)
        # Starting webserver
        tornado.ioloop.IOLoop.instance().start()


