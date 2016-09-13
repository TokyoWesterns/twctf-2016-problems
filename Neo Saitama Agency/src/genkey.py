from Crypto.PublicKey import RSA

def genkey(name):
    key = RSA.generate(1024)
    with open("sk-" + name + ".pem", "w") as f:
        f.write(key.exportKey())
    with open("pk-" + name + ".pem", "w") as f:
        f.write(key.publickey().exportKey())

genkey("alice")
genkey("bob")
genkey("carol")
