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
This mini webserver provides a REST API to feed an ec2_instance_feeder.
(There is similar support built into server.py.)


Usage:

  nohup python ec2_instance_feeder_server.py <feeder-file> <port> &
  
  (Nohup ensures that the service continues running after its shell is closed.)

API:

  GET request to :<port>/feed feeds the feeder.
  
"""

import tornado.httpserver
import tornado.ioloop
import tornado.web
import os.path
import subprocess
import sys
import json


"""
Feed Handler
"""

class FeedHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "text/plain")
        
    # Feed GET request.
    def get(self):
        status = 0
        args = [FeederApplication.mydir + "/ec2_instance_feeder", "feed", FeederApplication.feeder_file]
        try:
            out = subprocess.check_output(args)
        except:
            out = "Error: " + ' '.join(args)
            status = 1
        print "Feeding returned: %s" % (out)
        self.write(str(status))
        

class FeederApplication(tornado.web.Application):
    
    def __init__(self, feeder_file, port):
        
        FeederApplication.feeder_file = feeder_file
        FeederApplication.mydir = os.path.dirname(__file__)
        if FeederApplication.mydir == "":
            FeederApplication.mydir = "."
        print FeederApplication.mydir
        routes = [
            (r"/feed", FeedHandler)
           ]
        super(FeederApplication, self).__init__(routes)
        server = tornado.httpserver.HTTPServer(self)
        server.listen(port)
        
        # Report external URL for the webserver.
        # Get Real IP Address using 3rd-party service.
        # Local IP: myIP = socket.gethostbyname(socket.gethostname())
        port_str = "" if port == 80 else  ":" + str(port)
        try:
            external_ip = subprocess.check_output(["wget", "-qO-", "ifconfig.me"])
            print '*** Feeder Server Started, (http://%s%s) ***' % (external_ip, port_str)
        except:
            print "Python: FeederApplication failed to acquire external IP address."
            external_ip = None
            print '*** Feeder Server Started (http://localhost%s) ***' % port_str

        # Starting webserver
        tornado.ioloop.IOLoop.instance().start()
        

if __name__ == "__main__":

    # Command-line options
    
    if len(sys.argv) < 2:
        print "Usage: python ec2_instance_feeder_server <feeder-file> <port>"
        sys.exit(1)

    port = 65261   # (0xFEED in decimal)
    if len(sys.argv) > 2:
        port = int(sys.argv[2])

    application = FeederApplication(sys.argv[1], port)
