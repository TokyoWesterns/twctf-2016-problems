from packet import *
from protocol import *
from crypto import *
import random

sethostname("B")

with open("flag", "r") as f:
    flag = f.read()
with open("sk-bob.pem", "r") as f:
    skey = unpack_skey(f.read())
with open("pk-carol.pem", "r") as f:
    pkeyc = unpack_pkey(f.read())

def hello():
    sendmsg(sys.stdout, "*", PROTOCOL_BEACON, gethostname())
    
def server():
    # wait SYN
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_SYN:
        senderr(sys.stdout, src, "state error")
        exit(0)
    if data[1] != gethostname():
        senderr(sys.stdout, src, "SYN error")
        exit(0)
    to = data[0]

    # request key
    sendmsg(sys.stdout, "C", PROTOCOL_REQKEY, gethostname() + to)

    # recv key
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_RESKEY:
        senderr(sys.stdout, src, "state error")
        exit(0)
    m = verify(data, pkeyc)
    if m is None or m[0] != to:
        senderr(sys.stdout, src, "verification error")
        exit(0)
    pkeya = RSA.importKey(m[1:])

    # send ACK
    sendmsg(sys.stdout, to, PROTOCOL_ACK)

    # Phase 1
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_PHASE1:
        senderr(sys.stdout, src, "state error")
        exit(0)
    m = decrypt(data, skey)
    if m is None or m[0] != to:
        senderr(sys.stdout, src, "verification error")
        exit(0)
    Na = m[1:]
    
    # Phase 2
    Nb = struct.pack("Q", random.getrandbits(64))
    sendmsg(sys.stdout, to, PROTOCOL_PHASE2,
            encrypt(Na + Nb, pkeya))

    # Phase 3
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_PHASE3:
        senderr(sys.stdout, src, "state error")
        exit(0)
    m = decrypt(data, skey)
    if m is None:
        senderr(sys.stdout, src, "verification error")
        exit(0)
    if Nb != m:
        senderr(sys.stdout, src, "Nb error")
        exit(0)

    # send data
    if to == "A":
        sharedkey = Na + Nb
        cflag = encrypt_symmetric(flag, sharedkey)
        sendmsg(sys.stdout, to, PROTOCOL_DATA, cflag)

try:
    hello()
    server()
except ClosedSocketError:
    exit(0)
