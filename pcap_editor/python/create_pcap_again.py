from scapy.all import *

import socket, struct

beluga14_mac="98:03:9b:8f:70:35"
beluga15_mac="98:03:9b:8f:75:05"
beluga16_mac="98:03:9b:8f:70:7d"
beluga18_mac="98:03:9b:8f:70:75"
beluga19_mac="98:03:9b:8f:74:c5"

import sys
array_size = int(sys.argv[1])
total_ms = int(sys.argv[2])

# array_size = 20480

from python_lib.pcap_helper import long2ip

ip_list = []

ip_list.append(long2ip(0))
ip_list.append(long2ip(array_size-1))

print(len(ip_list))

ethernet = Ether(src=beluga18_mac, dst=beluga15_mac)
udp=UDP(sport=40508,dport=40508)

start = False

from python_lib.perf_timer import PerfTimer

timer = PerfTimer('create')

pcap_file_name = "test_%d_%dms_10us.pcap" % (array_size, total_ms)
print(pcap_file_name)

for ms in range(0, total_ms):
    if ms % 10 == 0:
        print("%dms %s" % ( ms, timer.lap_10_milli_string()))
    for us in range(0, 1000, 10):
        for srcIP in ip_list:
            ip=IP(src=srcIP, dst="1.1.1.1")
            packet = ethernet/ip/udp
            packet.time = float(1234567890) + float(ms)/1000 + float(us)/1000000
            if start == False:
                start = True
                wrpcap(pcap_file_name, packet)
            else:
                wrpcap(pcap_file_name, packet, append=True)
