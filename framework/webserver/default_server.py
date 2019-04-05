
import getopt
import sys
import os
from server import *

# The default Python webserver application.
# This creates routes for html, js, and css files to serve web content.
if __name__ == "__main__":

    # Command-line options

    port = 8888
    try:
        opts, remaining = getopt.getopt(sys.argv[1:], "", ["port="])
    except getopt.GetoptError:
        print 'Usage: %s --port <port>' % (sys.argv[0])
        sys.exit(2)
    for opt, arg in opts:
        if opt == '--port':
            port = int(arg)

    # Webserver
    dir = os.getcwd() + "/../webserver"
    application = FPGAServerApplication(
            FPGAServerApplication.defaultContentRoutes(dir),
            port
        )
