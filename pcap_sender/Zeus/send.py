#!/usr/bin/python3
from scapy.all import *
import time
import sys

# payload_size = pkt_size - 4 - 54 # Ether (14) + IP (20) + UDP (8) + TS (12)

p=Ether()/IP()/TCP(sport=1153, dport=9000)
p[Ether].src="98:03:9b:8f:70:75"
p[Ether].dst="98:03:9b:8f:74:c5"
p['IP'].src = "11.0.0.18"
p['IP'].dst = "11.0.0.19"
p['TCP'].flags = "PA"

p.show()

sendp(p, iface="eth5", verbose=0)
