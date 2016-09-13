from Crypto.PublicKey import RSA
from packet import *
from protocol import *
from crypto import *
import socket

sethostname("I")

host_alice = ("localhost", 41534)
host_bob   = ("localhost", 41535)
host_carol = ("localhost", 41536)

skey = RSA.generate(1024)
pkey = skey.publickey()
with open("pk-carol.pem", "r") as f:
    pkeyc = unpack_pkey(f.read())


def forward_packet(srchost, socks):
    (src, dst, payload) = recvpkt_core(socks[srchost])
    # print "Forward: ", (src, dst, payload)
    sendpkt_core(socks[dst], src, dst, payload)

def stealmsg(sockr):
    (src, dst, payload) = recvpkt_core(sockr)
    if payload == 0: return None
    cmd = struct.unpack("B", payload[0])[0]
    data = payload[1:]
    return (src, dst, cmd, data)

def forgemsg(sockw, src, dst, cmd, payload = ""):
    sendpkt_core(sockw, src, dst, struct.pack("B", cmd) + payload)

def main():
    socks = {}
    socks["A"] = socket.create_connection(host_alice).makefile()
    socks["B"] = socket.create_connection(host_bob).makefile()
    socks["C"] = socket.create_connection(host_carol).makefile()

    # register public key
    sendmsg(socks["C"], "C", PROTOCOL_REGKEY, "I" + pack_pkey(pkey))
    (src, dst, cmd, data) = recvmsg(socks["C"])
    if cmd != PROTOCOL_OK: raise Exception("state error %x" % cmd)

    # request B's key
    sendmsg(socks["C"], "C", PROTOCOL_REQKEY, gethostname() + "B")

    # recv B's key
    (src, dst, cmd, data) = recvmsg(socks["C"])
    if cmd != PROTOCOL_RESKEY: raise Exception("state error %x" % cmd)
    m = verify(data, pkeyc)
    if m is None or m[0] != "B": raise Exception("verification error")
    pkeyb = RSA.importKey(m[1:])

    # rewrite beacon
    (src, dst, cmd, data) = stealmsg(socks["B"])
    if cmd != PROTOCOL_BEACON: raise Exception("state error %x" % cmd)
    forgemsg(socks["A"], "B", "*", PROTOCOL_BEACON, "I")

    # forward
    forward_packet("A", socks)
    forward_packet("C", socks)

    # wait and send SYN
    (src, dst, cmd, data) = recvmsg(socks["A"])
    if cmd != PROTOCOL_SYN: raise Exception("state error %x" % cmd)
    forgemsg(socks["B"], "A", "B", PROTOCOL_SYN, "AB")

    # forward
    forward_packet("B", socks)
    forward_packet("C", socks)

    # wait and send ACK
    (src, dst, cmd, data) = stealmsg(socks["B"])
    if cmd != PROTOCOL_ACK: raise Exception("state error %x" % cmd)
    sendmsg(socks["A"], "A", PROTOCOL_ACK)

    # Phase 1
    ## A -> I
    (src, dst, cmd, data) = recvmsg(socks["A"])
    if cmd != PROTOCOL_PHASE1: raise Exception("state error %x" % cmd)
    m = decrypt(data, skey)
    if m is None or m[0] != "A": raise Exception("verification error")
    Na = m[1:]
    ## I -> B
    forgemsg(socks["B"], "A", "B", cmd, encrypt("A" + Na, pkeyb))

    # Phase 2
    ## B -> I
    (src, dst, cmd, data) = stealmsg(socks["B"])
    if cmd != PROTOCOL_PHASE2: raise Exception("state error %x" % cmd)
    ## I -> A
    sendmsg(socks["A"], "A", cmd, data)
    
    # Phase 3
    (src, dst, cmd, data) = recvmsg(socks["A"])
    if cmd != PROTOCOL_PHASE3: raise Exception("state error %x" % cmd)
    m = decrypt(data, skey)
    if m is None: raise Exception("decryption error")
    Nb = m
    ## I -> B
    forgemsg(socks["B"], "A", "B", cmd, encrypt(Nb, pkeyb))

    # recv flag
    (src, dst, cmd, data) = stealmsg(socks["B"])
    sharedkey = Na + Nb
    flag = decrypt_symmetric(data, sharedkey)
    print flag

try:
    main()
except ClosedSocketError:
    exit(0)
