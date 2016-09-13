from packet import *
from protocol import *
from crypto import *
import random

sethostname("A")

with open("sk-alice.pem", "r") as f:
    skey = unpack_skey(f.read())
with open("pk-carol.pem", "r") as f:
    pkeyc = unpack_pkey(f.read())

def server():
    # recv Beacon
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_BEACON:
        senderr(sys.stdout, src, "state error")
        exit(0)
    if len(data) != 1:
        senderr(sys.stdout, src, "syntax error")
        exit(0)
    to = data
    
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
    pkeyb = RSA.importKey(m[1:])

    # send SYN
    sendmsg(sys.stdout, to, PROTOCOL_SYN, gethostname() + to)
    
    # recv ACK
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_ACK:
        senderr(sys.stdout, src, "state error")
        exit(0)

    # Phase 1
    Na = struct.pack("Q", random.getrandbits(64))
    sendmsg(sys.stdout, to, PROTOCOL_PHASE1,
            encrypt(gethostname() + Na, pkeyb))

    # Phase 2
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    if cmd != PROTOCOL_PHASE2:
        senderr(sys.stdout, src, "state error")
        exit(0)
    m = decrypt(data, skey)
    if Na != m[:8]:
        senderr(sys.stdout, src, "Na error")
        exit(0)
    Nb = m[8:]

    # Phase 3
    sendmsg(sys.stdout, to, PROTOCOL_PHASE3, encrypt(Nb, pkeyb))

    # recv data
    (src, dst, cmd, data) = recvmsg(sys.stdin)
    #sharedkey = Na + Nb
    #flag = decrypt_symmetric(data, sharedkey)
    #sys.stderr.write(flag + "\n")

try:
    server()
except ClosedSocketError:
    exit(0)
