# automatically install missing packages

try:
	import paramiko
except (ImportError, ModuleNotFoundError):
	import pip
	if hasattr(pip, 'main'):
		print('Method 1')
		pip.main(['install', 'paramiko'])
	else:
		pip._internal.main(['install', 'paramiko'])
	
	import paramiko
