# Python 3
from Crypto.PublicKey import RSA
from Crypto.Util.number import *
from hashlib import sha1

k = 1024

message = getRandomInteger(k - 1)
with open("message", "w") as f:
    f.write(str(message))
with open("flag", "w") as f:
    f.write("TWCTF{" + sha1(str(message).encode("ascii")).hexdigest() + "}\n")

key = RSA.generate(k)
with open("secretkey.pem", "w") as f:
    f.write(key.exportKey("PEM").decode("ascii"))

with open("publickey.pem", "w") as f:
    f.write(key.publickey().exportKey("PEM").decode("ascii"))

ciphertext = key.encrypt(message, 0)[0]
with open("ciphertext", "w") as f:
    f.write(str(ciphertext))
