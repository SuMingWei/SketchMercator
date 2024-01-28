#include <iostream>
#include <execinfo.h>
#include <signal.h>

#include "unistd.h"
#include "getopt.h"

#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>

#include "pcap/parser.h"
#include "sys/sys.h"

#include <map>
#include <vector>
#include <set>
#include <stdio.h>
#include <fstream>
#include <sstream>

#define IP_PROTO_ICMP  0x01
#define IP_PROTO_IGMP  0x02
#define IP_PROTO_TCP   0x06
#define IP_PROTO_UDP   0x11

using namespace std;

struct Flowkey_t {
    uint32_t src_addr;
    uint16_t src_port;
    uint32_t dst_addr;
    uint16_t dst_port;
    uint8_t proto;

    Flowkey_t() : src_addr(0), src_port(0), dst_addr(0), dst_port(0), proto(0) {}

    bool operator==(const Flowkey_t &key) const {
        return (src_addr == key.src_addr && src_port == key.src_port && dst_addr == key.dst_addr && dst_port == key.dst_port && proto == key.proto);
    }

    bool operator<(const Flowkey_t &key) const {
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

void pcap_parse(char* pcap_file_name, map<Flowkey_t, int> &flow_stream, string flowkey){
    uint64_t initial_timestamp = 0;

    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[pcap_parse] " << pcap_file_name << endl;
    struct pcap_pkthdr header;
    const u_char *packet;

    int global_count = 0;
    int non_ipv4 = 0;
    int non_tcpudp = 0;

    // int debug_count = 0;

    while(true) {
        packet = pcap_next(descr, &header);
        if(packet == NULL)
            break;

        packet_header hdr;
        header_parser(hdr, packet, 0); // for no ehter type
        // header_parser(hdr, packet, 1); // for ether existing type

        if(hdr.ip_hdr->ip_v == 4) {
            packet_summary p;
            header_mapping(&header, hdr, p);
            if ((p.ip_proto == IP_PROTO_UDP || p.ip_proto == IP_PROTO_TCP) && header.caplen > 20) {
                global_count++;

                // summary
                Flowkey_t key;

                if(flowkey == "dstIP"){
                    key.dst_addr = p.dst_ip;
                }else if(flowkey == "srcIP"){
                    key.src_addr = p.src_ip;
                }
                flow_stream[key]++;

                // print progress bar
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }
                // cout <<key.dst_addr << endl;
                if (global_count % 10000 == 0) {
                    printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);

                    if(flowkey == "dstIP"){
                        // Convert to human-readable string
                        char dst_addr_str[INET_ADDRSTRLEN];
                        if (inet_ntop(AF_INET, &key.dst_addr, dst_addr_str, INET_ADDRSTRLEN) == nullptr) {
                            perror("Error converting address to string");
                        }
                        cout << "dst_addr: " << dst_addr_str << endl;
                    }else if(flowkey == "srcIP"){
                        // Convert to human-readable string
                        char src_addr_str[INET_ADDRSTRLEN];
                        if (inet_ntop(AF_INET, &key.src_addr, src_addr_str, INET_ADDRSTRLEN) == nullptr) {
                            perror("Error converting address to string");
                        }
                        cout << "src_addr: " << src_addr_str << endl;
                    }
                    cout << "flow size: " << flow_stream[key] << endl;
                }
            }
            else {
                non_tcpudp++;
            }
        }
        else {
            non_ipv4++;
        }
    }
    pcap_close(descr);
}


int main(int argc, char* argv[]){
    char* pcap_path_origin = (char*)"/home/ming/SketchMercator/pcap_storage/online_traffic/20180816/10s/5_5.pcap";
    string flowkey = "srcIP";

    /* summary flow info */
    map<Flowkey_t, int> flow_stream_origin;
    pcap_parse(pcap_path_origin, flow_stream_origin, flowkey);

    /* get flow size distribution */
    map<int, int> flow_size_dist_origin;
    for(auto flow : flow_stream_origin){
        flow_size_dist_origin[flow.second]++;
    }

    /* write flow size distribution to txt file */
    ofstream outFile_origin("./verified.txt");
    for(auto item: flow_size_dist_origin){
        outFile_origin << item.first << " " << item.second << endl;
    }
    outFile_origin.close();
    return 0;


}