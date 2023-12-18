#ifndef __PCAPH_H

#define __PCAPH_H

#include <iostream>
#include <vector>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>

#include <pcap.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>

#include "pcap/parser.h"
#include "sys/sys.h"


using namespace std;

// commonly used protocol numbers
#define IP_PROTO_ICMP  0x01
#define IP_PROTO_IGMP  0x02
#define IP_PROTO_TCP   0x06
#define IP_PROTO_UDP   0x11

void print_packet(struct packet_summary p);
void get_ip_char_from_int(char* ip_addr, uint32_t ip);
//uint32_t get_ip_int_from_char(char* ip_addr);
void pcap_parse(char* pcap_file_name, vector<packet_summary> &packet_stream);

#endif
