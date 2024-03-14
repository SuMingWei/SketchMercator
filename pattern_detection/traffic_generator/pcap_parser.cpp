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
#include <fstream>

#define IP_PROTO_ICMP  0x01
#define IP_PROTO_IGMP  0x02
#define IP_PROTO_TCP   0x06
#define IP_PROTO_UDP   0x11

using namespace std;

int total_flows = 0, total_packets = 0;

/* packet summary format
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
*/

/* flowkey list
flowkey_list = ["srcIP",
                "srcIP,srcPort",
                "dstPort",
                "dstIP,dstPort",
                "dstIP",
                "srcIP,dstIP",
                "srcIP,dstIP,srcPort,dstPort",
                "srcIP,dstIP,srcPort,dstPort,proto" ]
*/

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

void pcap_parse(char* pcap_file_name, map<Flowkey_t, vector<packet_summary>> &flow_stream, string flowkey){
    uint64_t initial_timestamp = 0;

    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[pcap_parse]" << pcap_file_name << endl;
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
                total_packets++;

                // summary
                Flowkey_t key;

                if(flowkey == "dstIP"){
                    key.dst_addr = p.dst_ip;
                }else if(flowkey == "srcIP"){
                    key.src_addr = p.src_ip;
                }
                flow_stream[key].push_back(p);
                if(flow_stream[key].size() == 1) total_flows++; // new flow key

                // debug
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 100000 == 0) {
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
                    cout << "flow size: " << flow_stream[key].size() << endl;
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
}

int main(int argc, char* argv[]){
    // test
    // char const *pcap_dir(getenv("pcap_storage"));
    // char *pcap_name = (char *)"equinix-nyc.dirA.20180816-130100.UTC.anon.pcap";
    // char pcap_path[256];
    // sprintf(pcap_path, "%s/caida_specify_time/20180816/60s/%s", pcap_dir, pcap_name);
    // int pcap_num = 1;
    // string flowkey = "srcIP";

    /* parallel run */
    string flowkey = argv[1];
    int pcap_num = argc - 2;

    /* summary flow info */

    map<Flowkey_t, vector<packet_summary>> flow_stream;
    for(int i=0;i<pcap_num;i++){
        char *pcap_path = argv[2+i];
        pcap_parse(pcap_path, flow_stream, flowkey);
    }

    cout << "total_flows   = " << total_flows << endl;
    cout << "total_packets = " << total_packets << endl;



    return 0;


}