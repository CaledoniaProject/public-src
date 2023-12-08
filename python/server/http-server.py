import sys
import os
import BaseHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler

HandlerClass = SimpleHTTPRequestHandler
ServerClass  = BaseHTTPServer.HTTPServer
Protocol     = "HTTP/1.0"

if len(sys.argv) != 3:
    print 'Usage:', sys.argv[0], 'port', 'webroot'
    sys.exit(1)

os.chdir(sys.argv[2])
server_address = ('127.0.0.1', int(sys.argv[1]))

HandlerClass.protocol_version = Protocol
httpd = ServerClass(server_address, HandlerClass)

sa = httpd.socket.getsockname()
print "Serving HTTP on", sa[0], "port", sa[1], "..."
httpd.serve_forever()
