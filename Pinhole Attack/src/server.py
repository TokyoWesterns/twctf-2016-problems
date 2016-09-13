# Python 3
from signal import alarm
from Crypto.PublicKey import RSA
from Crypto.Util.number import *
import Crypto.Random as Random

with open("secretkey.pem", "r") as f:
    key = RSA.importKey(f.read())
b = size(key.n) // 2

def run(fin, fout):
    alarm(1200)
    try:
        while True:
            line = fin.readline()[:4+size(key.n)//4]
            ciphertext = int(line, 16) # Note: input is HEX
            m = key.decrypt(ciphertext)
            fout.write(str((m >> b) & 3) + "\n")
            fout.flush()
    except:
        pass

if __name__ == "__main__":
    run(sys.stdin, sys.stdout)
