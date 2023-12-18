from scapy.all import *
	
import sys
srcip = sys.argv[1]
dstip = sys.argv[2]
count = int(sys.argv[3])
#print(sys.argv)
for i in range(0, count):
  print(i)
  packet = Ether(dst="00:0f:66:56:fa:d2", src="00:ae:f3:52:aa:d1")/IP(src=srcip, dst=dstip)/TCP(sport=0x0F0F, dport=0x0A0A)
  packet.show()
  sendp(packet, iface='veth2')
