# 生成 NTHASH

import sys
import hashlib
import binascii

for arg in sys.argv[1:]:
	print arg
	print binascii.hexlify(hashlib.new("md4", arg.encode("utf-16le")).digest())
	print ''
