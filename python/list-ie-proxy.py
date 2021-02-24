import _winreg

def get_ie_proxy():
	reg_key = _winreg.OpenKey(_winreg.HKEY_CURRENT_USER,r"Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings")
	enabled = _winreg.QueryValueEx(reg_key, "ProxyEnable")
	proxy   = _winreg.QueryValueEx(reg_key, "ProxyServer")

	if enabled[0] and proxy[0]:
		return proxy[0]

	return None

print (get_ie_proxy())
