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
#include <algorithm>
#include <cmath>
#include <ctime>
#include <cstdlib>
#include <filesystem>

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

struct Packet_info {
    struct pcap_pkthdr header;
    const u_char *packet;
    long time;
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
                total_packets++; // new packet

                // summary
                Flowkey_t key;

                if(flowkey == "dstIP"){
                    key.dst_addr = p.dst_ip;
                }else if(flowkey == "srcIP"){
                    key.src_addr = p.src_ip;
                }
                flow_stream[key]++;
                if(flow_stream[key] == 1) total_flows++; // new flow key

                // print progress bar
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 1000000 == 0) {
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

/* generate pcap file */
void pcap_generate(char* pcap_file_name, char* output_file_name, string flowkey, map<Flowkey_t, int> &selected_flow, int &handle_packets, int scale){
    uint64_t initial_timestamp = 0;

    int cur_idx = 1;
    map<Flowkey_t, int> non_selected_flow;

    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[pcap_generate] " << pcap_file_name << endl;

    pcap_dumper_t* pcap_out;
    if(access(output_file_name, F_OK) != -1){ // output pcap file exist
        pcap_out = pcap_dump_open_append(descr, output_file_name);
    }else{
        pcap_out = pcap_dump_open(descr, output_file_name);
    }

    struct pcap_pkthdr header;
    const u_char *packet;

    int global_count = 0;

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

                // sample packet (reserve 1/scale flows)
                if(selected_flow.find(key) != selected_flow.end()){
                    // Write the selected packet to the output file
                    pcap_dump((u_char*)pcap_out, &header, packet);

                    handle_packets++;
                }else { // new flow 
                    if(non_selected_flow.find(key) == non_selected_flow.end()){
                        if(cur_idx == scale){
                            selected_flow[key] = 1;
                            cur_idx = 1;
                            // Write the packet to the output file
                            pcap_dump((u_char*)pcap_out, &header, packet);  
                            handle_packets++;
                        }else{
                            non_selected_flow[key] = 1;
                            cur_idx++;
                        }
                    }

                }

                // print progress bar
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 1000000 == 0) {
                    printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);

                    cout << "[sampled packets] " << handle_packets << endl;
                    cout << "[non selected flows] " << non_selected_flow.size() << endl;
                }
            }
        }
    }

    pcap_dump_close(pcap_out);
    pcap_close(descr);
}

/* for pcap sorting */
bool cmp(Packet_info a, Packet_info b){
    return a.time < b.time;
}

void sort_pcap(char* pcap_file_name, char* output_file_name){
    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[read pcap] " << pcap_file_name << endl;

    struct pcap_pkthdr *header;
    const u_char *data;
    const u_char *data_copy;

    vector<Packet_info> pktVector;
    Packet_info tmpPkt;

    int global_count = 0;
    while(int returnVal = pcap_next_ex(descr, &header, &data) >= 0){
        tmpPkt.header = *header;
        data_copy = (u_char*)malloc(tmpPkt.header.caplen); // malloc space for data_copy
        memcpy((void *)data_copy, (const void *)data, tmpPkt.header.caplen);
        tmpPkt.packet = data_copy;
        tmpPkt.time = header->ts.tv_sec * 1000000 + header->ts.tv_usec;

        pktVector.push_back(tmpPkt);

        global_count++;
        if (global_count % 100000 == 0) {
            cout << "[read packets] " << global_count << endl;
        }
    }

    pcap_close(descr);
    cout << "[done store pcap info]\n";

    sort(pktVector.begin(), pktVector.end(), cmp);
    cout << "[done sorting]\n";

    /* dump the ordered packets to the new file */
    cout << "[write pcap] " << output_file_name << endl;

    pcap_t * finalPcap = pcap_open_dead(DLT_EN10MB, 262144); // dumper will use it
    pcap_dumper_t* pcap_out = pcap_dump_open(finalPcap, output_file_name);

    global_count = 0;
    for(const auto& pkt : pktVector){
        // Write the packet to the output file
        pcap_dump((u_char*)pcap_out, &pkt.header, pkt.packet);

        global_count++;
        if (global_count % 100000 == 0) {
            cout << "[write packets] " << global_count << endl;
        }
    }

    pcap_dump_close(pcap_out);
    pcap_close(finalPcap);
    cout << "[done write sorted pcap file]\n";
}

int main(int argc, char* argv[]){
    srand(time(NULL));
    string flowkey = argv[1];

    /* generate a scaled pcap file */
    char* synthetic_data_file_name = (char*)"/home/ming/SketchMercator/pattern_detection/traffic_generator/tmp.pcap";
    vector<int> time_offset = {0, 4*60, 9*60, 29*60, 59*60}; // 20180816 need to remove the offset of different pcap file
    map<Flowkey_t, int> selected_flow;
    int gen_num = 0;
    int scale = 14;
    char *pcap_path = argv[2];
    pcap_generate(pcap_path, synthetic_data_file_name, flowkey, selected_flow, gen_num, scale);
    cout << "[packet sampling is completed] total sample packets: " << gen_num << "\n";

    /* sort the pcap file by the timestamp*/
    string str_pcap_file = pcap_path;
    string tmp_file_name = str_pcap_file.substr(0,str_pcap_file.length()-5) + "_" + to_string(scale) + "x.pcap";
    char* new_synthetic_data_file_name = new char[tmp_file_name.length() + 1];
    strcpy(new_synthetic_data_file_name, tmp_file_name.c_str());

    sort_pcap(synthetic_data_file_name, new_synthetic_data_file_name);

    /* remove tmp pcap file*/
    ifstream tmpFile;
    tmpFile.open(synthetic_data_file_name);
    if(tmpFile){
        cout << "remove tmp pcap file\n";
        remove(synthetic_data_file_name);
    }
    tmpFile.close();

    cout << "total_flows   = " << selected_flow.size() << endl;
    cout << "total_packets = " << gen_num << endl;

    return 0;


}