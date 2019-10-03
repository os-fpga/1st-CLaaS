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
# This is the main python web server which:
#   - serves static content
#   - processes REST requests
#   - accepts WebSocket connections
# Roles may be divided between content server and F1 accelerated server. Both are handled by this
# file to keep things simple in the face of various use models.
#
# The process is single threaded and all the requests are served synchronously and in order.
#
# The web server interfaces with the host application through a UNIX socket communication
# in order to send commands and data to the FPGA.
#
# Author: Alessandro Comodi, Politecnico di Milano
#
"""

import inspect
import getopt
import tornado.httpserver
import tornado.websocket
import os.path
from PIL import Image
import io
import tornado.ioloop
import tornado.web
import socket
from socket import error as socket_error
import sys
import time
import subprocess
import json
import base64
import errno
import signal
#import numpy
from server_api import *
# import boto3   -- Using boto3 would be far simpler than using the AWS CLI, but boto3 does not seem to support asynchronous/non-blocking operation. :(
import re



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
# 'handler' is a method of the form: json_response = handler(self, payload, type(string))
class WSHandler(tornado.websocket.WebSocketHandler):
  def open(self):
    print('Webserver: New connection')

  # This function activates whenever there is a new message incoming from the WebSocket
  def on_message(self, message):
    msg = json.loads(message)
    response = {}
    print("Webserver: ws.on_message:", message)
    type = msg['type']
    payload = msg['payload']

    # The request is passed to a request handler which will process the information contained
    # in the message and produce a result
    #-result = self.application.handle_request(type, payload)
    try:
        result = self.application.message_handlers[type](payload, type)
    except KeyError:
        print("Webserver: Unrecognized message type:", type)
    
    # The result is sent back to the client
    print("Webserver: Responding with:", result)
    self.write_message(result)

  def on_close(self):
    print('Webserver: Connection closed')
    oneshot = self.application.args["oneshot"]
    if oneshot != None:
        print ("Webserver: Killing application:", oneshot)
        os.kill(int(oneshot), signal.SIGTERM)

  def check_origin(self, origin):
    return True


"""
Request Handlers
"""

class ReqHandler(tornado.web.RequestHandler):
    # Set the headers to avoid access-control-allow-origin errors when sending get requests from the client
    def set_default_headers(self):
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.set_header("Connection", "keep-alive")
        self.set_header("Content-Type", "text/plain")

"""
Handler for Real IP address GET requests (no default route for this)
This can be useful if a proxy is used to server the http requests, but a WebSocket must be opened directly.
"""
class IPReqHandler(ReqHandler):
    def get(self):
        ip = FPGAServerApplication.application.external_ip
        if (ip == None):
            ip = ""
        #ip_str = socket.gethostbyname(socket.gethostname())
        self.write(ip)
        
"""
EC2 Action Handlers
"""
class EC2Handler(ReqHandler):
    
    def ping(self):
        status = 0
        args = [FPGAServerApplication.framework_webserver_dir + "/../aws/ec2_time_bomb", "reset", FPGAServerApplication.ec2_time_bomb_filename]
        try:
            out = subprocess.check_output(args, universal_newlines=True)
        except subprocess.CalledProcessError as e:
            out = "Error: status: " + str(e.returncode) + ", cmd: " + e.cmd + ", output: " + e.output
            status = e.returncode
        except BaseException as e:
            out = "Error: " + str(e)
            status = 1
        if status != 0:
            print("Webserver: EC2 time bomb reset returned:", out)
        return status

"""
Handler for resetting the EC2 instance time bomb.
"""
class TimeBombHandler(EC2Handler):
    # Time Bomb reset GET request.
    def get(self):
        status = self.ping()
        self.write(str(status))
"""
Handler for starting the EC2 instance.
Return JSON: {"ip": <ip>, "message": <debug-message>}
    "ip" and "message" are optional. Existence of IP indicates success.
(This also resets the instance time bomb.)
TODO: Currently, there is no StopEC2InstanceHandler. This is because the time bomb is shared, and it is not the responsibility of a single user to stop the instance.
      Only detonation from timeout will stop the instance. Support for explicit stopping would require the time bomb to keep track of all users independently (as a
      separate file per user (IP?).)
"""
class StartEC2InstanceHandler(EC2Handler):
    # Handles starting the EC2 instance.
    def post(self):
        resp = {}
        
        # Get request parameters.
        password = self.get_argument('pwd')
        
        try:
            # Check password.
            if password != FPGAServerApplication.ec2_instance_password and FPGAServerApplication.ec2_instance_password != "":
                # Invalid passord.
                raise RuntimeError("Invalid password")
            
            # As a safety check, make sure the time bomb is running for the instance.
            out = subprocess.check_output(['/bin/bash', '-c', "[[ -e '" + FPGAServerApplication.ec2_time_bomb_filename + "' ]] && ps --no-header -q $(cat '" + FPGAServerApplication.ec2_time_bomb_filename + "') -o comm="], universal_newlines=True)
            if not re.match('^ec2_', out):
                raise RuntimeError("Unable to find time bomb process for " + FPGAServerApplication.ec2_time_bomb_filename + ".")
                
            # Reset the time bomb.
            if self.ping():
                # Time bomb reset failed, so don't bother starting the instance.
                raise RuntimeError("Unable to reset time bomb: " + FPGAServerApplication.ec2_time_bomb_filename + ".")
            
        except BaseException as e:
            msg = "Couldn't set up for EC2 instance because of exception: " + str(e)
            resp = {"message": msg}
            print("Webserver: " + msg)
        
        if not "message" in resp:
            # So far, so good.
                
            try:
                # Start instance.
                
                # First wait a second to be sure the time bombs reset and a bomb doesn't detonate as we start the instance.
                time.sleep(1)
                # Note: The instance must be constructed to launch the web server at reboot (@reboot in crontab, for example).
                #       It must be able to safely cleanup any lingering garbage from when it was last stopped.
                FPGAServerApplication.awsEc2Cli(['start-instances'])
            
                # Wait for instance to start.
                FPGAServerApplication.awsEc2Cli(['wait', 'instance-running', '--no-paginate'])
                
                # Get IP address.
                out = FPGAServerApplication.awsEc2Cli(['describe-instances', '--query', 'Reservations[*].Instances[*].PublicIpAddress'])
                m = re.match(r'^(\d+\.\d+\.\d+\.\d+)$', out)
                if m:
                    ip = m.group(1)
                    resp['ip'] = ip
                else:
                    resp['message'] = "Server failed to start EC2 instance."
                    raise RuntimeError("Failed to find public IP in AWS command output: " + out)

                """
                # Start web server via ssh.
                ssh = '/usr/bin/ssh'
                args = [ssh, '-i', FPGAServerApplication.ec2_instance_private_key_file, '-oStrictHostKeyChecking=no', 'centos@' + ip, FPGAServerApplication.ec2_instance_start_command]
                print("Webserver: Running: " + " ".join(args))
                try:
                    ## Using spawn to run in background.
                    #os.spawnv(os.P_NOWAIT, ssh, args)
                    subprocess.check_call(args)
                except BaseException as e:
                    print("Caught exception: " + str(e))
                    raise RuntimeError("Failed to launch web server on EC2 instance with command: " + ' '.join(args))
                """
                
            except BaseException as e:
                msg = "Couldn't initialize instance because of exception: " + str(e)
                resp = {"message": msg}
                print("Webserver: " + msg)
                
                # Stop server. Note that there might be other users of the instance, but something seems wrong with it, so
                # tear it down, now.
                try:
                    cmd = [FPGAServerApplication.ec2_time_bomb_script, "detonate", FPGAServerApplication.ec2_time_bomb_filename]
                    out = subprocess.check_call(cmd)
                except:
                    print("Webserver: Failed to stop instance that failed to initialize properly using: " + " ".join(cmd))

        self.write(json.dumps(resp))


# This class can be overridden to provide application-specific behavior.
# The derived constructor should:
#   # optionally, app.associateEC2Instance()
#   routes = defaultRoutes()
#   routes.extend(...)
#   super(MyApplication, self).__init__(port, routes)
class FPGAServerApplication(tornado.web.Application):
    cleanup_handler_called = False
    clean_exit_called = False
    
    # These can be set by calling associateEC2Instance() to associate an EC2 instance with this web server.
    ec2_time_bomb_script = None
    ec2_time_bomb_filename = None
    ec2_time_bomb_timeout = 120
    ec2_instance_id = None
    ec2_profile = None
    
    app_dir = os.getcwd() + "/.."
    framework_webserver_dir = os.path.dirname(__file__)
    framework_client_dir = os.path.dirname(__file__) + "/../client"
    if dir == "":
        dir = "."
        
    # A derived class can be call this in its __init__(..) prior to this class's __init__(..) to associate an
    # AWS EC2 Instance with this web server based on command-line arguments by starting a time bomb.
    def associateEC2Instance(self):
        # Extract command-line args.
        ec2_instance = self.args["instance"]
        timeout = self.args["ec2_time_bomb_timeout"]
        password = self.args["password"]
        profile = self.args["profile"]
        
        ret = False
        # Create time bomb.
        time_bomb_dir = FPGAServerApplication.app_dir + "/webserver/ec2_time_bombs"
        time_bomb_file = time_bomb_dir + "/" + ec2_instance
        script = FPGAServerApplication.framework_webserver_dir + "/../aws/ec2_time_bomb"
        args = [script, "control", time_bomb_file, str(timeout)]
        print("Attempting to associate time bomb with ec2 instance with command:", args)
        if profile:
            args.append(profile)
        try:
            try:
                os.mkdir(time_bomb_dir)
            except OSError as e:
                pass
            subprocess.check_call(args)   # Note that subprocess.check_output(args, universal_newlines=True) cannot be used because subprocess remains running and connected to stdout.
            print('*** EC2 Instance Time Bomb %s Started ***' % (time_bomb_file))
            
            FPGAServerApplication.ec2_time_bomb_script = script
            FPGAServerApplication.ec2_instance_id = ec2_instance
            FPGAServerApplication.ec2_time_bomb_filename = time_bomb_file
            FPGAServerApplication.ec2_time_bomb_timeout = timeout
            FPGAServerApplication.ec2_profile = profile
            #FPGAServerApplication.ec2_instance_private_key_file = FPGAServerApplication.framework_webserver_dir + "/../terraform/deployment/private_key.pem"
            # Must be absolute for now:
            FPGAServerApplication.ec2_instance_private_key_file = FPGAServerApplication.app_dir + "/../../framework/terraform/deployment/private_key.pem"
            FPGAServerApplication.ec2_instance_password = password
            ret = True
        except BaseException as e:
            print("Webserver: FPGAServerApplication failed to start time bomb for EC2 instance %s with exception: %s" % (ec2_instance, str(e)))
        return ret
    
    # Issue an aws ec2 command via CLI. (It would be better to use boto3, but it is blocking.)
    # --instance_ids ..., --output text, and --profile ... args are appended to the end of the provided args.
    # Return stdout.
    # Error conditions are raised as RuntimeError containing an error string that is reported to stdout.
    @staticmethod
    def awsEc2Cli(args):
        args = ['aws', 'ec2'] + args + ['--output', 'text', '--instance-ids', FPGAServerApplication.ec2_instance_id]
        print("Webserver: Running: " + " ".join(args))
        if FPGAServerApplication.ec2_profile:
            args.append('--profile')
            args.append(FPGAServerApplication.ec2_profile)
        err_str = None
        try:
            ret = subprocess.check_output(args, universal_newlines=True)
            """
            if property:
                m = re.match(r'[^\n]' + property + r'\s+(.*)\n', out)
                if groups:
                    ret = m.group(1)
                else:
                    err_str = "Property: " + property + " not found from AWS command: " + ' '.join(args)
            """
        except:
            err_str = "AWS EC2 command failed: " + ' '.join(args)
        if err_str:
            print("Webserver: " + err_str)
            raise RuntimeError(err_str)
        return ret
    
    # Return an array containing default routes into ../client/{html,css,js}
    # Args:
    #   ip: Truthy to include /ip route.
    # These settings affect routes:
    #   FPGAServerApplication.ec2_instance_id
    #   FPGAServerApplication.ec2_profile:
    @staticmethod
    def defaultRoutes(ip=None):
        routes = [
              (r"/framework/js/(.*)", BasicFileHandler, {"path": FPGAServerApplication.framework_client_dir + "/js"}),
              (r"/framework/css/(.*)", BasicFileHandler, {"path": FPGAServerApplication.framework_client_dir + "/css"}),
              (r"/framework/(.*\.html)", BasicFileHandler, {"path": FPGAServerApplication.framework_client_dir + "/html"}),
              (r"/()", BasicFileHandler, {"path": FPGAServerApplication.app_dir + "/client/html", "default_filename": "index.html"}),
              (r'/ws', WSHandler),
              (r"/css/(.*\.css)", BasicFileHandler, {"path": FPGAServerApplication.app_dir + "/client/css"}),
              (r"/js/(.*\.js)",   BasicFileHandler, {"path": FPGAServerApplication.app_dir + "/client/js"}),
              (r"/(.*\.html)", BasicFileHandler, {"path": FPGAServerApplication.app_dir + "/client/html"}),
              (r"/(.*\.ico)", BasicFileHandler, {"path": FPGAServerApplication.app_dir + "/client/html"})
            ]
        if ip:
            routes.append( (r'/ip', IPReqHandler) )
        if FPGAServerApplication.ec2_time_bomb_filename:
            routes.append( (r'/start_ec2_instance', StartEC2InstanceHandler) )
            #routes.append( (r'/stop_ec2_instance', StopEC2InstanceHandler) )
            routes.append( (r"/reset_ec2_time_bomb", TimeBombHandler) )
        return routes
    
    
    # Register a message handler.
    # 
    def registerMessageHandler(self, type, handler):
        self.message_handlers[type] = handler
    
    
    # Handler for GET_IMAGE.
    def handleGetImage(self, payload, type):
        print("Webserver: handleGetImage:", payload)
        response = get_image(self.socket, "GET_IMAGE", payload, True)
        return {'type': 'user', 'png': response}
        
    def handleDataMsg(self, data, type):
        self.socket.send_string("command", type)
        self.socket.send_string("data", data)
        data = read_data_handler(self.socket, None, False)
        return data
    
    def handleCommandMsg(self, data, type):
        self.socket.send_string("command", type)
        return {'type': type}
    

    # Cleanup upon SIGTERM, SIGINT, SIGQUIT, SIGHUP.
    @staticmethod
    def cleanupHandler(signum, frame):
        if not FPGAServerApplication.cleanup_handler_called:
            FPGAServerApplication.cleanup_handler_called = True
            print('Webserver: Signal handler called with signal', signum)
            tornado.ioloop.IOLoop.instance().add_callback_from_signal(FPGAServerApplication.cleanExit)
        else:
            print("Webserver: Duplicate call to Signal handler.")
        
    # Clean up upon exiting.
    @staticmethod
    def cleanExit():
        try:
            if not FPGAServerApplication.clean_exit_called:
                FPGAServerApplication.clean_exit_called = True
                try:
                    FPGAServerApplication.application.socket.close()
                except Exception as e:
                    print("Failed to close socket:", e)
                
                MAX_WAIT_SECONDS_BEFORE_SHUTDOWN = 1
                if FPGAServerApplication.ec2_time_bomb_filename:
                    print("Webserver: Stopping EC2 time bomb", FPGAServerApplication.ec2_time_bomb_filename)
                    try:
                        out = subprocess.check_output([FPGAServerApplication.ec2_time_bomb_script, "done", FPGAServerApplication.ec2_time_bomb_filename], universal_newlines=True)
                    except:
                        print("Webserver: Failed to stop EC2 time bomb", FPGAServerApplication.ec2_time_bomb_filename)
            
                print('Webserver: Stopping http server.')
                FPGAServerApplication.server.stop()

                #print('Will shutdown within %s seconds ...' % MAX_WAIT_SECONDS_BEFORE_SHUTDOWN)
                io_loop = tornado.ioloop.IOLoop.instance()

                deadline = time.time() + MAX_WAIT_SECONDS_BEFORE_SHUTDOWN

                # If there is nothing pending in io_loop, stop, otherwise wait and repeat until timeout.
                # TODO: Had to disable "nothing pending" check, so this is just a fixed timeout now.
                #       Monitor this to see if a solution pops up: https://gist.github.com/mywaiting/4643396  
                def stop_loop():
                    now = time.time()
                    if now < deadline: # and (io_loop._callbacks or io_loop._timeouts):
                        io_loop.add_timeout(now + 1, stop_loop)
                    else:
                        io_loop.stop()
                        print('Webserver: Shutdown')
                stop_loop()
                
                # As an added safety measure, let's wait for the EC2 instance to stop.
                if FPGAServerApplication.ec2_time_bomb_filename:
                    print("Webserver: Waiting for associated EC2 instance (" + FPGAServerApplication.ec2_instance_id + ") to stop.")
                    FPGAServerApplication.awsEc2Cli(['wait', 'instance-stopped', '--no-paginate'])
                    print("Webserver: EC2 instance " + FPGAServerApplication.ec2_instance_id + " stopped.")
            else:
                print("Webserver: Duplicate call to cleanExit().")
        except Exception as e:
            print("Failed to exit cleanly. Exception", e)
    
        
    # Return arguments dict that can be .update()d to application constructor arg to provide arguments for
    # associateEC2Instance().
    # Command-line args are:
    #   instance: The ID of an AWS EC2 instance statically associated with this web server which can be
    #             started via GET request. associateEC2Instance() will start a time bomb and defaultRoutes() will create
    #             a route (/reset_ec2_time_bomb) to reset the time bomb.
    #   ec2_time_bomb_timeout: A timeout value in seconds for the time bomb.
    #   password: The password to require for starting the ec2 instance, or explicitly "" for no password. (Required if ec2 instance in use.)
    #   profile:  (opt) An AWS profile to use.
    @staticmethod
    def EC2Args():
        return {"instance": None, "ec2_time_bomb_timeout": 120, "profile": None, "password": None}

    # Argument parsing, the result of which is to be passed to the constructor. (It is separated from
    # constructor to allow for routes (which are a parameter of tornado.web.Application) to depend on args.)
    #   flags: {list} Long-form command-line parameters without values (without '--').
    #          Implicit flags are:
    #             "oneshot": Exit after socket is closed.
    #   params: {dict} Long-form command-line args with default values. Use None if no default. There is no distinction between required
    #           and optional arguments, so required args should be checked for None values. Default argument processing can be avoided
    #           by passing flags=None and params=<value of args after command-line processing>.
    #           Implicit params are:
    #              "port" (8888): Socket on which web server will listen.
    # Return: {dict} The parameters/arguments. When a command-line arg is not given, it will have default value. A flag will not exist if not given, or have "" value if given.
    @staticmethod
    def commandLineArgs(flags=[], params={}):
        # Apply implicit args. ("password" is from EC2Args(), but the Makefile will provide it from configuration parameters, whether used or not.)
        ret = {"port": 8888, "password": None, "oneshot": None}
        ret.update(params)
        arg_list = flags
        # Apply implicit flags (currently none).
        arg_list.extend([])
        for arg in ret:
            arg_list.append(arg + "=")
        try:
            opts, remaining = getopt.getopt(sys.argv[1:], "", arg_list)
        except getopt.GetoptError:
            print('Usage: %s [--port #] [--instance i-#] [--ec2_time_bomb_timeout <sec>] [--password <password>] [--profile <aws-profile>]' % (sys.argv[0]))
            sys.exit(2)
        # Strip leading dashes.
        for opt, arg in opts:
            opt = re.sub(r'^-*', '', opt)
            ret[opt] = arg
        return ret
        
    # Params:
    #   routes: {list of tuples} as for Tornado. Can pass defaultRoutes().
    #   args: from commandLineArgs() (generally).
    def __init__(self, routes, args):
        self.args = args
        
        self.port = int(self.args['port'])
        
        FPGAServerApplication.application = self
        
        super(FPGAServerApplication, self).__init__(routes)
    
        self.socket = Socket()
        
        server = tornado.httpserver.HTTPServer(self)
        FPGAServerApplication.server = server
        server.listen(self.port)
        self.message_handlers = {}
        self.registerMessageHandler("GET_IMAGE", self.handleGetImage)
        self.registerMessageHandler("DATA_MSG", self.handleDataMsg)
        self.registerMessageHandler("START_TRACING", self.handleCommandMsg)
        self.registerMessageHandler("STOP_TRACING", self.handleCommandMsg)
        
        # Report external URL for the web server.
        # Get Real IP Address using 3rd-party service.
        # Local IP: myIP = socket.gethostbyname(socket.gethostname())
        port_str = "" if self.port == 80 else  ":" + str(self.port)
        try:
            self.external_ip = subprocess.check_output(["wget", "-qO-", "ifconfig.me"], universal_newlines=True)
            print('*** Websocket Server Started, (http://%s%s) ***' % (self.external_ip, port_str))
        except:
            print("Webserver: FPGAServerApplication failed to acquire external IP address.")
            self.external_ip = None
            print('*** Websocket Server Started (http://localhost%s) ***' % port_str)
        signal.signal(signal.SIGINT,  FPGAServerApplication.cleanupHandler)
        signal.signal(signal.SIGQUIT, FPGAServerApplication.cleanupHandler)
        signal.signal(signal.SIGTERM, FPGAServerApplication.cleanupHandler)
        signal.signal(signal.SIGHUP,  FPGAServerApplication.cleanupHandler)
            
        try:
            # Starting web server
            tornado.ioloop.IOLoop.instance().start()
        except BaseException as e:
            print("Webserver: Exiting due to exception:", e)
            #FPGAServerApplication.cleanExit(e)
            
