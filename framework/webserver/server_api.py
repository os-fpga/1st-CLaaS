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
sys.path.append('/home/centos/.local/lib/python3.6/site-packages')
import time
import traceback

import pyarrow.plasma as plasma

import json

# Socket with host messages defines
CHUNK_SIZE    = 4096


### This function requests an image from the host
### Parameters:
###   - sock    - socket channel with host
###   - header  - command to be sent to the host
###   - payload - data for the image calculation
###   - b64  - to be eliminated

### This function reads data from the FPGA memory
### Parameters:
###   - sock        - socket channel with host
###   - isGetImage  - boolean value to understand if the request is
###                 - performed within the GetImage context
###   - header      - command to be sent to host (needed if isGetImage is False)
###   - b64         - encode a string in base64 and return base64(utf-8) string
###                   (else return binary string) (default=True)
def read_data_handler(header=None, b64=True):
  # Receive integer data size from host

########################################################################################################
########################################### PLASMA - GET OBJ ###########################################
########################################################################################################


  # Create a different client. Note that this second client could be
  # created in the same or in a separate, concurrent Python session.
  client2 = plasma.connect("/tmp/plasma")

  # Get the object in the second client. This blocks until the object has been sealed.
  object_id2 = plasma.ObjectID(20 * b"w")
  print("Object ID (Web Server) ", object_id2)
  [buffer2] = client2.get_buffers([object_id2])

  view2 = memoryview(buffer2)
  print("Plasma Data from Host App to Web Server: ")#, chr(view2[0]), chr(view2[1]), chr(view2[2]),  chr(view2[3]),  chr(view2[4]),  
  # chr(view2[5]),  chr(view2[6]), chr(view2[7]), chr(view2[8]), chr(view2[9]), chr(view2[10]), chr(view2[11]), chr(view2[12]), 
  # chr(view2[13]), chr(view2[14]), chr(view2[15]),  chr(view2[16]),  chr(view2[17]),  chr(view2[18]),  chr(view2[19]), chr(view2[20]),
  # chr(view2[21]), chr(view2[22]), chr(view2[23]), chr(view2[24]), chr(view2[25]), chr(view2[26]), chr(view2[27]), chr(view2[28]),
  # chr(view2[29]), chr(view2[30]), chr(view2[31]), chr(view2[32]))

  data1 = []
  for i in range(16):
            if (chr(view2[i]) == 0):
                data1[i] = 'A'
            elif (chr(view2[i]) == 1):
                data1[i] = 'C'
            elif (chr(view2[i]) == 2):
                data1[i] = 'G'
            elif (chr(view2[i]) == 3):
                data1[i] = 'T'
            else:
                data1[i] = '-'
            print("data1[i]", data1[i])

  data2 = []
  for i in range(16):
            if (chr(view2[17+i]) == 0):
                data2[i] = 'A'
            elif (chr(view2[17+i]) == 1):
                data2[i] = 'C'
            elif (chr(view2[17+i]) == 2):
                data2[i] = 'G'
            elif (chr(view2[17+i]) == 3):
                data2[i] = 'T'
            else:
                data1[i] = '-'
            print("data1[i]", data1[i])

  string_data1 = ""
  string_data2 = ""

  for i in range(16):
    string_data1 = string_data1 + chr(view2[i])

  for i in range(16):
    string_data2 = string_data2 + chr(view2[17+i])

  dictionary = [{'data1': string_data1, 'data2': string_data2}]
  print("Dictionary'd Data: ", dictionary)

  f = open("../../../framework/client/js/declare.js", "w")

  jsonobj = json.dumps(dictionary)

  f.write("var jsonstr = {} ".format(jsonobj))

  f.close() 

  return 1
