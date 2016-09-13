from packet import *
import struct

PROTOCOL_OK = 0x0
PROTOCOL_ERR = 0x1
PROTOCOL_SYN = 0x2
PROTOCOL_ACK = 0x3

PROTOCOL_REGKEY = 0x11
PROTOCOL_REQKEY = 0x12
PROTOCOL_RESKEY = 0x13

PROTOCOL_BEACON = 0x20
PROTOCOL_PHASE1 = 0x21
PROTOCOL_PHASE2 = 0x22
PROTOCOL_PHASE3 = 0x23
PROTOCOL_DATA = 0x24

def sendmsg(sockw, dst, cmd, payload = ""):
    sendpkt(sockw, dst, struct.pack("B", cmd) + payload)

def sendok(sockw, dst):
    sendmsg(sockw, dst, PROTOCOL_OK)

def senderr(sockw, dst, msg = ""):
    sendmsg(sockw, dst, PROTOCOL_ERR, msg)

def recvmsg(sockr):
    (src, dst, payload) = recvpkt(sockr)
    if payload == 0: return None
    cmd = struct.unpack("B", payload[0])[0]
    data = payload[1:]
    return (src, dst, cmd, data)
