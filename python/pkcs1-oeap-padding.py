from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from base64 import b64decode, b64encode

key = RSA.importKey(open('priv.txt').read())
encryptor = PKCS1_OAEP.new(key)
data = encryptor.encrypt(open('input', 'rb').read())
print(b64encode(data).decode('ascii'))

data2 = encryptor.decrypt(data)
print(data2)
