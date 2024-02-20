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
#include <string>

#define IP_PROTO_ICMP  0x01
#define IP_PROTO_IGMP  0x02
#define IP_PROTO_TCP   0x06
#define IP_PROTO_UDP   0x11

using namespace std;


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

/* combine pcap file */
void pcap_combine(char* pcap_file_name, char* output_file_name, map<Flowkey_t, int> &flow_stream, string flowkey, map<Flowkey_t, int> &sum_stream, int length, int &flow_num, int & pkt_num, int time_offset, int date_offset){
    uint64_t initial_timestamp = 0;

    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[pcap_combine] " << pcap_file_name << endl;

    pcap_t * finalPcap = pcap_open_dead(DLT_EN10MB, 262144); // dumper will use it
    pcap_dumper_t* pcap_out;
    if(access(output_file_name, F_OK) != -1){ // output pcap file exist
        pcap_out = pcap_dump_open_append(finalPcap, output_file_name);
        cout << "exist\n";
    }else{
        pcap_out = pcap_dump_open(finalPcap, output_file_name);
        cout << "not exist\n";
    }

    struct pcap_pkthdr header;
    const u_char *packet;

    int global_count = 0;
    while(true) {
        packet = pcap_next(descr, &header);
        header.ts.tv_sec += time_offset;
        header.ts.tv_sec += date_offset;

        // packet end
        if(packet == NULL)
            break;

        packet_header hdr;
        header_parser(hdr, packet, 0); // for no ehter type
        // header_parser(hdr, packet, 1); // for ether existing type

        if(hdr.ip_hdr->ip_v == 4) {
            packet_summary p;
            header_mapping(&header, hdr, p);
            if ((p.ip_proto == IP_PROTO_UDP || p.ip_proto == IP_PROTO_TCP) && header.caplen > 20) {
                
                // end
                if(length == 0) break;
                if(initial_timestamp != 0){
                    if((p.timestamp-initial_timestamp) >= uint64_t(length * 1000000)){
                        break;
                    } 
                }
                
                global_count++;
                pkt_num++;

                // summary
                Flowkey_t key;

                if(flowkey == "dstIP"){
                    key.dst_addr = p.dst_ip;
                }else if(flowkey == "srcIP"){
                    key.src_addr = p.src_ip;
                }
                flow_stream[key]++;
                sum_stream[key]++;
                if(flow_stream[key] == 1) flow_num++; // new flow key

                // Write the packet to the output file
                pcap_dump((u_char*)pcap_out, &header, packet);

                // print progress bar
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 100000 == 0) {
                    printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);
                }
            }
        }
    }

    pcap_dump_close(pcap_out);
    pcap_close(finalPcap);
    pcap_close(descr);
    return;
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

    char *file1 = argv[1];
    char *file2 = argv[2];

    int len1 = stoi(argv[3]);
    int len2 = stoi(argv[4]);

    string flowkey = argv[5];

    string d1 = argv[6];
    string d2 = argv[7];

    int date_offset = stoi(argv[8]);

    int fn1 = 0, fn2 = 0, pn1 = 0, pn2 = 0; 

    /* combine two file with specific length */
    map<Flowkey_t, int> flow_stream1;
    map<Flowkey_t, int> flow_stream2;
    map<Flowkey_t, int> sum_stream;
    char* tmp_file = (char*)"/home/ming/SketchMercator/pattern_detection/traffic_generator/training_pcap_file/tmp.pcap";
    int time_offset = len1;
    // cout << flow_stream1.size() <<endl;
    pcap_combine(file1, tmp_file, flow_stream1, flowkey, sum_stream, len1, fn1, pn1, 0, 0);
    pcap_combine(file2, tmp_file, flow_stream2, flowkey, sum_stream, len2, fn2, pn2, time_offset, date_offset);

    /* sort the file with stimestamp */
    string tmp_name = "/home/ming/SketchMercator/pattern_detection/traffic_generator/training_pcap_file/" 
                        + d1 + "_" + to_string(len1) + "_" + d2 + "_" + to_string(len2)+ ".pcap";
    char* result_file = new char[tmp_name.length() + 1];
    strcpy(result_file, tmp_name.c_str());
    sort_pcap(tmp_file, result_file);

    /* remove tmp pcap file*/
    ifstream tmpFile;
    tmpFile.open(tmp_file);
    if(tmpFile){
        cout << "remove tmp pcap file\n";
        remove(tmp_file);
    }
    tmpFile.close();

    cout << "file1: \n";
    cout << "\tflows   = " << fn1 << endl;
    cout << "\tpackets = " << pn1 << endl;
    cout << "file2: \n";
    cout << "\tflows   = " << fn2 << endl;
    cout << "\tpackets = " << pn2 << endl;
    cout << "summary: \n";
    cout << "\tflows   = " << sum_stream.size() << endl;
    cout << "\tpackets = " << (pn1+pn2) << endl;

    return 0;


}