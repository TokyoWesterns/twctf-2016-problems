import struct
import sys
import time

WAIT=1

class ClosedSocketError(Exception):
    pass
class PacketError(Exception):
    pass

_me = "@"
def sethostname(hostname):
    global _me
    _me = hostname
def gethostname():
    return _me

def recvpkt_core(sockr):
    time.sleep(WAIT)
    hdr = sockr.read(4)
    if len(hdr) == 0:
        raise ClosedSocketError()
    if len(hdr) < 4:
        raise PacketError()
    src = hdr[0]
    dst = hdr[1]
    length = struct.unpack("H", hdr[2:4])[0]
    payload = ""
    while len(payload) < length:
        t = sockr.read(length - len(payload))
        if len(t) == 0:
            raise ClosedSocketError()
        payload += t
    return (src, dst, payload)

def recvpkt(sockr):
    while True:
        (src, dst, payload) = recvpkt_core(sockr)
        if dst == _me or dst == "*":
            break
    return (src, dst, payload)

def sendpkt_core(sockw, src, dst, payload):
    time.sleep(WAIT)
    sockw.write(src)
    sockw.write(dst)
    sockw.write(struct.pack("H", len(payload)))
    sockw.write(payload)
    sockw.flush()

def sendpkt(sockw, dst, payload):
    sendpkt_core(sockw, _me, dst, payload)



def debug(s):
    sys.stderr.write(sys.argv[0] + " " + repr(s) + "\n")
