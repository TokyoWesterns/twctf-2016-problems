from Crypto.Util.number import *
from Crypto.Cipher import PKCS1_OAEP
import Crypto.PublicKey.RSA as RSA
from Crypto.Cipher import AES
from hashlib import sha256

IV = "\x3e"*16

def encrypt(m, pk):
    cipher = PKCS1_OAEP.new(pk)
    return cipher.encrypt(m)

def decrypt(c, sk):
    cipher = PKCS1_OAEP.new(sk)
    try:
        return cipher.decrypt(c)
    except:
        return None

def sign(m, sk):
    h = sha256(m).digest()
    s = long_to_bytes(sk.sign(h, None)[0])
    return struct.pack("H", len(m)) + m + s

def verify(sig, pk):
    try:
        l = struct.unpack("H", sig[:2])[0]
        m = sig[2:l+2]
        s = sig[l+2:]
        h = sha256(m).digest()
        if pk.verify(h, (bytes_to_long(s), None)):
            return m
        else:
            return None
    except:
        return None

def pack_pkey(pk):
    return pk.exportKey("DER")

def pack_skey(sk):
    return sk.exportKey("DER")

def unpack_pkey(pkstr):
    return RSA.importKey(pkstr)

def unpack_skey(skstr):
    return RSA.importKey(skstr)


def pad(m):
    l = AES.block_size - len(m) % AES.block_size
    return m + chr(l) * l

def unpad(m):
    return m[:-ord(m[-1])]

def encrypt_symmetric(m, key):
    aes = AES.new(sha256(key).digest(), mode=AES.MODE_CBC, IV=IV)
    return aes.encrypt(pad(m))

def decrypt_symmetric(c, key):
    aes = AES.new(sha256(key).digest(), mode=AES.MODE_CBC, IV=IV)
    return unpad(aes.decrypt(c))
