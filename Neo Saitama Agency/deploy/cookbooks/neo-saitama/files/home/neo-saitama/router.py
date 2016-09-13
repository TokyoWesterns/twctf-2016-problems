import socket
import random
import select
from packet import *

host_alice = ("neo-saitama.chal.mmactf.link", 41534)
host_bob   = ("neo-saitama.chal.mmactf.link", 41535)
host_carol = ("neo-saitama.chal.mmactf.link", 41536)

socks = {}
socks["A"] = socket.create_connection(host_alice).makefile()
socks["B"] = socket.create_connection(host_bob).makefile()
socks["C"] = socket.create_connection(host_carol).makefile()

while True:
    ready = select.select(socks.values(), [], [])
    sock = random.choice(ready[0])
    try:
        (src, dst, payload) = recvpkt_core(sock)
        print (src, dst, payload)
        if dst != "*":
            sendpkt_core(socks[dst], src, dst, payload)
        else:
            for h in socks:
                if h != src:
                    sendpkt_core(socks[h], src, dst, payload)
    except ClosedSocketError:
        exit(0)
