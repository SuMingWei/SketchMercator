#include "parser.h"

void print_packet_summary(packet_summary &p)
{
    printf("[print_packet]\n");
    printf("src_ip = %" PRIu32 "\n", p.src_ip);
    printf("src_ip_addr = %s\n", p.src_ip_addr);
    printf("dst_ip = %" PRIu32 "\n", p.dst_ip);
    printf("dst_ip_addr = %s\n", p.dst_ip_addr);

    printf("src_port = %d\n", p.src_port);
    printf("dst_port = %d\n", p.dst_port);

    printf("ip_proto = %d\n", p.ip_proto);
    // printf("size = %d\n", p.size);
    printf("timestamp = %" PRIu64 "\n", p.timestamp);
    printf("\n");
}

void get_ip_char_from_int(char ip_addr[16], uint32_t ip)
{
    char buf[INET_ADDRSTRLEN];
    uint32_t net_ip = ntohl(ip);
    inet_ntop(AF_INET, &net_ip, buf, INET_ADDRSTRLEN);
    strcpy(ip_addr, buf);
}

void header_parser(packet_header &hdr, const u_char *packet, int type)
{

    int ethernet_header_size = 0;

    if (type == 0) { // raw ip, no ethernet header
        ethernet_header_size = 0;

        hdr.ip_hdr = (struct ip*)packet;
        if (hdr.ip_hdr->ip_v != 4) {
            if (hdr.ip_hdr->ip_v == 6) {
                return;
            } else {
                printf("It seems like ethernet frame is found.\n");
                printf("This pcap might not be raw ip (no ethernet frame) pcap file such as CAIDA. Check out the pcap file.\n");
                printf("exit the code\n");
                exit(0);
            }
        }
    }
    if (type == 1) { // normal
        ethernet_header_size = 14;

        hdr.ether_hdr = (struct ether_header*)packet;
        hdr.ip_hdr = (struct ip*)(packet+ethernet_header_size);
        if (hdr.ip_hdr->ip_v != 4) {
            if (hdr.ip_hdr->ip_v == 6) {
                return;
            } else {
                printf("packet is not IPv4 and not IPv6.\n");
                exit(0);
            }
        }
    }
    // hdr.ip_hdr->ip_hl == 5
    // int Size = 0;
    // while (packet[Size] != '\0') {
    //     printf("[%x] ", packet[Size]);
    //     Size++;
    // }
    // cout << Size << endl;
    // cout << strlen((unsigned char*)packet) << endl;

    if (hdr.ip_hdr->ip_p == IP_PROTO_UDP) {
        hdr.udp_hdr = (struct udphdr *)(packet+ethernet_header_size+(hdr.ip_hdr->ip_hl * 4));
    }
    else if (hdr.ip_hdr->ip_p == IP_PROTO_TCP) {
        hdr.tcp_hdr = (struct tcphdr *)(packet+ethernet_header_size+(hdr.ip_hdr->ip_hl * 4));
    }
}

void header_mapping(const struct pcap_pkthdr* pkthdr, packet_header &hdr, packet_summary &p)
{
    char sourceIp[INET_ADDRSTRLEN];
    char destIp[INET_ADDRSTRLEN];

    inet_ntop(AF_INET, &(hdr.ip_hdr->ip_src), sourceIp, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &(hdr.ip_hdr->ip_dst), destIp, INET_ADDRSTRLEN);

    p.src_ip = ntohl(hdr.ip_hdr->ip_src.s_addr);
    p.dst_ip = ntohl(hdr.ip_hdr->ip_dst.s_addr);

    get_ip_char_from_int(p.src_ip_addr, p.src_ip);
    get_ip_char_from_int(p.dst_ip_addr, p.dst_ip);

    p.size = ntohs(hdr.ip_hdr->ip_len);

    // Get timestamp in milliseconds
    p.timestamp = pkthdr->ts.tv_sec * 1000000 + pkthdr->ts.tv_usec;

    p.ip_proto = hdr.ip_hdr->ip_p;

    p.src_port = p.dst_port = 0;

    // // Get UDP or TCP specific parameters.
    if(p.ip_proto == IP_PROTO_UDP) {
        p.src_port = ntohs(hdr.udp_hdr->uh_sport);
        p.dst_port = ntohs(hdr.udp_hdr->uh_dport);
    }
    else if(p.ip_proto == IP_PROTO_TCP) {
        p.src_port = ntohs(hdr.tcp_hdr->th_sport);
        p.dst_port = ntohs(hdr.tcp_hdr->th_dport);
    }
}

bool isSynPacket(packet_header &hdr)
{
    if (hdr.ip_hdr->ip_v == 4) {
        if (hdr.ip_hdr->ip_p == IP_PROTO_TCP) {
            if((hdr.tcp_hdr->th_flags & TH_SYN) == TH_SYN) {
                return true;
            }
        }
    }

    return false;
}

bool isDNSPacket(packet_header &hdr, packet_summary &p)
{
    if (hdr.ip_hdr->ip_v == 4) {
        if (hdr.ip_hdr->ip_p == IP_PROTO_UDP) {
            if(p.src_port == 53 || p.dst_port == 53) {
                return true;
            }
        }
    }
    return false;
}

bool isHTTPGetPacket(packet_header &hdr, packet_summary &p)
{
    if (hdr.ip_hdr->ip_v == 4) {
        if (hdr.ip_hdr->ip_p == IP_PROTO_TCP) {
            if(p.src_port == 80 || p.dst_port == 80) {
                return true;
            }
        }
    }
    return false;
}



// struct vlan_ethhdr {
//   u_int8_t  ether_dhost[ETH_ALEN];  /* destination eth addr */
//   u_int8_t  ether_shost[ETH_ALEN];  /* source ether addr    */
//   u_int16_t          h_vlan_proto;
//   u_int16_t          h_vlan_TCI;
//   u_int16_t ether_type;
//  };

    // const struct vlan_ethhdr* vlan_ether_header;
    // int vlan_ether_header_size = 14 + 4;

    // /* --- this is for vlan --- */
    // vlan_ether_header = (struct vlan_ethhdr*)packet;
    // // printf("dst mac %02x %02x %02x %02x %02x %02x\n", vlan_ether_header->ether_dhost[0]
    // //                                     , vlan_ether_header->ether_dhost[1]
    // //                                     , vlan_ether_header->ether_dhost[2]
    // //                                     , vlan_ether_header->ether_dhost[3]
    // //                                     , vlan_ether_header->ether_dhost[4]
    // //                                     , vlan_ether_header->ether_dhost[5]
    // //                                     );
    // // printf("src mac %02x %02x %02x %02x %02x %02x\n", vlan_ether_header->ether_shost[0]
    // //                                     , vlan_ether_header->ether_shost[1]
    // //                                     , vlan_ether_header->ether_shost[2]
    // //                                     , vlan_ether_header->ether_shost[3]
    // //                                     , vlan_ether_header->ether_shost[4]
    // //                                     , vlan_ether_header->ether_shost[5]
    // //                                     );
    // // printf("src mac %x\n", vlan_ether_header->ether_shost);
    // // printf("whats going on?\n");
    // if (ntohs(vlan_ether_header->h_vlan_proto) != 0x8100) { // must be vlan header
    //     // printf("not vlan tag\n");
    //     return;
    // }

    // // printf("ether_type %x\n", ntohs(vlan_ether_header->ether_type));
    // if (ntohs(vlan_ether_header->ether_type) != 0x0800) { // must ip
    //     // printf("not ip\n");
    //     return;
    // }
