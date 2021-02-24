import sys
import os
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

if len(sys.argv) != 2:
    print 'Usage:', sys.argv[0], 'directory_to_serve'
    sys.exit(1)

authorizer = DummyAuthorizer()
authorizer.add_user("root", "toor", sys.argv[1], perm="elradfmw")
#authorizer.add_anonymous(sys.argv[1])

handler = FTPHandler
handler.authorizer = authorizer

server = FTPServer(("127.0.0.1", 21000), handler)
server.serve_forever()
