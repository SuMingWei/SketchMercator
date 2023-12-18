#ifndef _CPP_LIB_PARSER_H

#define _CPP_LIB_PARSER_H

#include <inttypes.h>
#include <iostream>
#include <string>

#include <time.h>
#include <unistd.h>
#include <pcap.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include <net/ethernet.h>

#include <netinet/ip.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>

#include <arpa/inet.h>

#include <sys/socket.h>

#include <sys/stat.h>
#include <sys/types.h>

#include <pcap.h>


#include <arpa/inet.h>

using namespace std;

struct vlan_ethhdr {
  u_int8_t  ether_dhost[6];  /* destination eth addr */
  u_int8_t  ether_shost[6];  /* source ether addr    */
  u_int16_t          h_vlan_proto;
  u_int16_t          h_vlan_TCI;
  u_int16_t ether_type;
 };

struct packet_header {
    struct ether_header* ether_hdr;
    struct ip* ip_hdr;
    struct vlan_ethhdr* vlan_ether_hdr;
    struct udphdr *udp_hdr;
    struct tcphdr *tcp_hdr;
};

struct packet_summary {
	uint32_t src_ip;
	char src_ip_addr[INET_ADDRSTRLEN];
    uint32_t dst_ip;
	char dst_ip_addr[INET_ADDRSTRLEN];
	uint16_t src_port;
	uint16_t dst_port;
    uint8_t ip_proto;
	uint16_t size;
    uint64_t timestamp; //in millisecond

};


#define IP_PROTO_TCP   0x06
#define IP_PROTO_UDP   0x11

void print_packet_summary(packet_summary &p);
void header_parser(packet_header &hdr, const u_char *packet, int type);
void header_mapping(const struct pcap_pkthdr* pkthdr, packet_header &hdr, packet_summary &p);

bool isSynPacket(packet_header &hdr);
bool isDNSPacket(packet_header &hdr, packet_summary &p);
bool isHTTPGetPacket(packet_header &hdr, packet_summary &p);

struct flowkey_t
{
    uint32_t src_addr;
    uint16_t src_port;
    uint32_t dst_addr;
    uint16_t dst_port;
    uint8_t proto;

    bool operator==(const flowkey_t &key) const
    {
        return (src_addr == key.src_addr && src_port == key.src_port && dst_addr == key.dst_addr && dst_port == key.dst_port && proto == key.proto);
    }

    bool operator<(const flowkey_t &key) const {
        if (src_addr < key.src_addr) {
            return 1;
        } else if (src_addr > key.src_addr) {
            return 0;
        } else {
            if (src_port < key.src_port) {
                return 1;
            } else if (src_port > key.src_port) {
                return 0;
            } else {
                if (dst_addr < key.dst_addr) {
                    return 1;
                } else if (dst_addr > key.dst_addr) {
                    return 0;
                } else {
                    if (dst_port < key.dst_port) {
                        return 1;
                    } else if (dst_port > key.dst_port) {
                        return 0;
                    } else {
                        if (proto < key.proto) {
                            return 1;
                        } else if (proto > key.proto) {
                            return 0;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
};

#endif
