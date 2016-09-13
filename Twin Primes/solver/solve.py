from Crypto.Util.number import *
import Crypto.PublicKey.RSA as RSA

with open("key1", "r") as f:
    n1 = long(f.readline())
    e1 = long(f.readline())
with open("key2", "r") as f:
    n2 = long(f.readline())
    e2 = long(f.readline())
with open("encrypted", "r") as f:
    c = long(f.readline())

# {(p+2)(q+2) - pq - 4}/2 = p+q
s = (n2 - n1 - 4)/2

# phi(pq) = pq - (p+q) + 1
phi1 = n1 - s + 1
d1 = inverse(e1, phi1)

# phi((p+2)(q+2)) = pq + (p+q) + 1
phi2 = n1 + s + 1
d2 = inverse(e2, phi2)

rsa1 = RSA.construct((n1, e1, d1))
rsa2 = RSA.construct((n2, e2, d2))

m = long_to_bytes(rsa1.decrypt(rsa2.decrypt(c)))
print m[:m.find("\0")]
