"""
BSD 3-Clause License

Copyright (c) 2019, Steven F. Hoover
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
This mini web server provides a REST API to reset an ec2_time_bomb.
(NOTE: There is similar support built into server.py, which is used by examples.
       THIS SCRIPT IS NOT IN USE AND IS PROBABLY BROKEN.)


Usage:

  nohup python3 ec2_time_bomb_server.py <time_bomb-file> <port> &
  
  (Nohup ensures that the service continues running after its shell is closed.)

API:

  GET request to :<port>/reset_ec2_time_bomb resets the time bomb.
  
"""

import tornado.httpserver
import tornado.ioloop
import tornado.web
import os.path
import subprocess
import sys
import json


"""
Time Bomb Reset Handler
"""

class TimeBombHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "text/plain")
        
    # Reset GET request.
    def get(self):
        status = 0
        args = [TimeBombApplication.mydir + "/ec2_time_bomb", "reset", TimeBombApplication.time_bomb_file]
        try:
            out = subprocess.check_output(args, universal_newlines=True)
        except:
            out = "Error: " + ' '.join(args)
            status = 1
        print("Time bomb reset returned: %s" % (out))
        self.write(str(status))
        

class TimeBombApplication(tornado.web.Application):
    
    def __init__(self, time_bomb_file, port):
        
        TimeBombApplication.time_bomb_file = time_bomb_file
        TimeBombApplication.mydir = os.path.dirname(__file__)
        if TimeBombApplication.mydir == "":
            TimeBombApplication.mydir = "."
        print(TimeBombApplication.mydir)
        routes = [
            (r"/reset_ec2_time_bomb", TimeBombHandler)
           ]
        super(TimeBombApplication, self).__init__(routes)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(port)
        
        # Report external URL for the web server.
        # Get Real IP Address using 3rd-party service.
        # Local IP: myIP = socket.gethostbyname(socket.gethostname())
        port_str = "" if port == 80 else  ":" + str(port)
        try:
            external_ip = subprocess.check_output(["wget", "-qO-", "ifconfig.me"], universal_newlines=True)
            print('*** Time Bomb Server Started, (http://%s%s) ***' % (external_ip, port_str))
        except:
            print("Python: TimeBombApplication failed to acquire external IP address.")
            external_ip = None
            print('*** Time Bomb Server Started (http://localhost%s) ***' % port_str)

        # Starting web server
        tornado.ioloop.IOLoop.instance().start()
        

if __name__ == "__main__":

    # Command-line options
    
    if len(sys.argv) < 2:
        print("Usage: python3 ec2_time_bomb_server <time-bomb-file> <port>")
        sys.exit(1)

    port = 65261   # (0xFEED in decimal)
    if len(sys.argv) > 2:
        port = int(sys.argv[2])

    application = TimeBombApplication(sys.argv[1], port)
