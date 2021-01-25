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
# The following file contains a set of functions that
# allow the communication with the host application
# through a UNIX socket.
#
# They are intended to be as general as possible. For the
# sake of this example though we have specialized the python
# server in order to request specific images of the Mandelbrot
# set.
#
# Author: Alessandro Comodi, Politecnico di Milano
#
"""

import struct
import base64
import socket
import sys
import time
import traceback

# Socket with host messages defines
CHUNK_SIZE    = 4096

class Socket():

    VERBOSITY = 0   # 0-10 (quiet-loud)

    # Connect on construction.
    def __init__(self, filename):
        # Opening socket with host
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server_address = (filename)

        connected = False
        cnt = 0
        while not connected:
            try:
                self.sock.connect(server_address)
                connected = True
            except socket.error as e:
                if cnt > 10:
                  print("Giving up.")
                  sys.exit(1)
                print("Couldn't connect to host application via socket. Waiting...")
                time.sleep(3)
                cnt = cnt + 1


    def send_string(self, tag, str):
        #print("Python: sending", len(str), "-byte", tag)
        self.send(tag + " size", struct.pack("I", socket.htonl(len(str))))  # pack bytes of len properly
        self.send(tag, str.encode())


    ### Send/receive over socket and report.
    def send(self, tag, data):
        if self.VERBOSITY > 5:
            print("Python: Sending", len(data), "-byte", tag, "over socket:", data)
        try:
            # To do. Be more graceful about large packets by using sock.send (once multithreading is gracefully supported).
            self.sock.sendall(data)
        except socket.error:
            print("sock.send failed with socket.error.")
            traceback.print_stack()
    def recv(self, tag, size):
        if self.VERBOSITY > 5:
            print("Python: Receiving", size, "bytes of", tag, "from socket")
        ret = None
        try:
            ret = self.sock.recv(size)
        except socket.error:
            print("sock.recv failed.")
            traceback.print_stack()
        #print("Python: recv'ed:", ret)
        return ret

    def close(self):
        self.sock.close()

### This function requests an image from the host
### Parameters:
###   - sock    - socket channel with host
###   - header  - command to be sent to the host
###   - payload - data for the image calculation
###   - b64  - to be eliminated
def get_image(sock, header, payload, b64=True):

  # Handshake with host application
  #print("Header: ", header)
  sock.send_string("command", header)
  sock.send_string("image params", payload)

  image = read_data_handler(sock, None, b64)
  return image

### This function reads data from the FPGA memory
### Parameters:
###   - sock        - socket channel with host
###   - isGetImage  - boolean value to understand if the request is
###                 - performed within the GetImage context
###   - header      - command to be sent to host (needed if isGetImage is False)
###   - b64         - encode a string in base64 and return base64(utf-8) string
###                   (else return binary string) (default=True)
def read_data_handler(sock, header=None, b64=True):
  # Receive integer data size from host
  response = sock.recv("size", 4)

  # Decode data size
  (size,) = struct.unpack("I", response)
  size = socket.ntohl(size)
  print("Python: Size: ", size)

  ### Receive chunks of data from host ###
  data = b''
  while len(data) < size:
    to_read = size - len(data)
    data += sock.recv("chunk", CHUNK_SIZE if to_read > CHUNK_SIZE else to_read)

  #byte_array = struct.unpack("<%uB" % size, data)
  if b64:
    data = base64.b64encode(data)

    # Does the decode("utf-8") below do anything? Let's check.
    tmp = data
    if (data != tmp.decode("utf-8")):
      print("FYI: UTF-8 check mismatched.")

    data = data.decode("utf-8")

  return data
