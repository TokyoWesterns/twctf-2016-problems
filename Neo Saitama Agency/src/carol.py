from packet import *
from protocol import *
from crypto import *

sethostname("C")

pkeys = {}
skey = None
with open("pk-alice.pem", "r") as f:
    pkeys["A"] = unpack_pkey(f.read())
with open("pk-bob.pem", "r") as f:
    pkeys["B"] = unpack_pkey(f.read())
with open("pk-carol.pem", "r") as f:
    pkeys["C"] = unpack_pkey(f.read())
with open("sk-carol.pem", "r") as f:
    skey = unpack_skey(f.read())

def regkey(host, data):
    if host in pkeys:
        return False
    pkeys[host] = unpack_pkey(data)
    return True

def reqkey(a, b):
    if b not in pkeys:
        return None
    return sign(b + pack_pkey(pkeys[b]), skey)

def handle(cmd, data, src):
    if cmd == PROTOCOL_REGKEY:
        if len(data) <= 1:
            senderr(sys.stdout, src)
        if regkey(data[0], data[1:]):
            sendok(sys.stdout, src)
        else:
            senderr(sys.stdout, src)
    elif cmd == PROTOCOL_REQKEY:
        if len(data) != 2:
            senderr(sys.stdout, src)
        data2 = reqkey(data[0], data[1])
        if data2 is not None:
            sendmsg(sys.stdout, src, PROTOCOL_RESKEY, data2)
        else:
            senderr(sys.stdout, src)

try:
    while True:
        (src, dst, cmd, data) = recvmsg(sys.stdin)
        handle(cmd, data, src)
except ClosedSocketError:
    exit(0)
