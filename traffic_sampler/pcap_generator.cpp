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

void select_flow(map<int, int> fs_dist, map<int, vector<Flowkey_t>> size_key_mapping, map<Flowkey_t, int> &selected_flow){
    int size, freq, idx, candidate_size;
    int unhandle_flow = 0;
    int unhandle_packets = 0;
    int total_flows = 0;
    cout << "[select flow]\n";
    for(auto item : fs_dist){
        size = item.first;
        freq = item.second;
        total_flows += freq;

        // sample the flow with same flow size
        if(size_key_mapping.find(size) != size_key_mapping.end()){
            // cout << "[finding...] flow size = " << size << "\n";
            candidate_size = size_key_mapping[size].size(); 
            if(freq <= candidate_size){
                // random select
                while(freq > 0){
                    idx = rand() % candidate_size;
                    if(selected_flow.find(size_key_mapping[size][idx]) == selected_flow.end()){
                        selected_flow[size_key_mapping[size][idx]] = size;
                        freq--;
                    }
                }
            }else{
                // target number > the dataset
                // todo
                cout << "target number > the dataset\n";
                cout << "flow size = " << size << " freq = " << freq << " candidate size = " << candidate_size << "\n";
                for(int i=0;i<candidate_size;i++){
                    selected_flow[size_key_mapping[size][i]] = size;
                }
                unhandle_flow += (freq - candidate_size);
                unhandle_packets += (freq - candidate_size) * size;
            }
        }else{
            // can't find the flow that has same flow size
            // todo
            cout << "can't find the flow that has same flow size\n";
            unhandle_flow += freq;
            unhandle_packets += (freq * size);
        }
    }

    cout << "[target total flows] " << total_flows << endl;
    cout << "[unhandle flows] " << unhandle_flow << endl;
    cout << "[unhandle packets] " << unhandle_packets << endl;
    return;
}

void pcap_generate(char* pcap_file_name, char* output_file_name, string flowkey, map<Flowkey_t, int> &selected_flow, int &handle_packets, int time_offset){
    uint64_t initial_timestamp = 0;

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
    // int handle_packets = 0;

    // int debug_count = 0;

    while(true) {

        if(selected_flow.size() == 0){
            cout << "[finish generating]\n" << "total generate packets: " << handle_packets << endl;
            break;
        }

        packet = pcap_next(descr, &header);
        header.ts.tv_sec -= time_offset;
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

                // sample packet
                if(selected_flow.find(key) != selected_flow.end()){
                    // Write the packet to the output file
                    pcap_dump((u_char*)pcap_out, &header, packet);

                    handle_packets++;

                    if(--selected_flow[key] <= 0){
                        selected_flow.erase(key);
                    }
                }

                // print progress bar
                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 1000000 == 0) {
                    printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);

                    cout << "[sampled packets] " << handle_packets << endl;
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

void read_pcap(char* pcap_file_name, vector<Packet_info> &packets){
    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << "[read pcap] " << pcap_file_name << endl;

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
                
                packets.push_back({header, packet});

                global_count++;
                if (global_count % 10000 == 0) {
                    cout << "[read packets] " << global_count << endl;
                }
            }
        }


    }

    pcap_close(descr);
}

void write_pcap(char* output_file_name, vector<Packet_info> &packets){
    /* dump the ordered packets to the new file */
    cout << "[write pcap] " << output_file_name << endl;

    pcap_t * finalPcap = pcap_open_dead(DLT_EN10MB, 262144); // dumper will use it
    pcap_dumper_t* pcap_out = pcap_dump_open(finalPcap, output_file_name);

    int global_count = 0;
    for(const auto& pkt : packets){
        // Write the packet to the output file
        pcap_dump((u_char*)pcap_out, &pkt.header, pkt.packet);

        global_count++;
        if (global_count % 10000 == 0) {
            cout << "[write packets] " << global_count << endl;
        }
    }

    pcap_dump_close(pcap_out);
    pcap_close(finalPcap);
}

void sort_pcap_file(char* pcap_file_name, char* output_file_name, vector<Packet_info> &packets){
    read_pcap(pcap_file_name, packets);
    sort(packets.begin(), packets.end(), cmp);
    write_pcap(output_file_name, packets);
    cout << "[sorting done]\n";
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
        if (global_count % 10000 == 0) {
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
        if (global_count % 10000 == 0) {
            cout << "[write packets] " << global_count << endl;
        }
    }

    pcap_dump_close(pcap_out);
    pcap_close(finalPcap);
    cout << "[done write sorted pcap file]\n";
}

int main(int argc, char* argv[]){
    srand(time(NULL));
    string fs_dist_file = argv[1];
    string flowkey = argv[2];
    int pcap_num = argc - 3;

    /* summary flow info */
    /* get the flow size of each flow key */
    map<Flowkey_t, int> flow_stream;
    for(int i=0;i<pcap_num;i++){
        char *pcap_path = argv[3+i];
        pcap_parse(pcap_path, flow_stream, flowkey);
    }

    /* get flow size and flowkey mapping */
    cout << "[create flow size and key mapping]\n";
    map<int, vector<Flowkey_t>> size_key_mapping;
    for(auto flow : flow_stream){
        size_key_mapping[flow.second].push_back(flow.first);
    }

    /* get quantized flow size and flowkey mapping */
    /* prepare quantization bins */ 
    int total_flow_num = 0;
    int ceil_flow_size = pow(10, ceil(log10(size_key_mapping.rbegin()->first)));
    int rec = ceil(log10(ceil_flow_size));
    vector<int> bins;
    for(int i=1;i<1001;i++) bins.push_back(i);
    for(int i=11;i<101;i++) bins.push_back(i*100);
    while(rec > 4){
        for(int i=2;i<11;i++) bins.push_back(i*(pow(10, rec-1)));
        rec--;
    }
    sort(bins.begin(), bins.end());
    // cout << "ceil_flow_size = " << ceil_flow_size << endl;
    /* get mapping */
    map<int, vector<Flowkey_t>> quantized_mapping;
    int idx = 0;
    for(auto flow : size_key_mapping){
        total_flow_num += flow.second.size();
        while(flow.first > bins[idx]){
            if(idx < bins.size()-1) idx++;
            else break;
        }
        quantized_mapping[bins[idx]].insert(quantized_mapping[bins[idx]].end(), flow.second.begin(), flow.second.end());
    }

    // /* verify the quantized mapping result equal to the plot.ipynb */
    // for(auto item : quantized_mapping){
    //     cout << item.first << " " << item.second.size() << endl;
    // }

    /* read file to get inputFile's flow size distribution */
    cout << "[get input flow size distribution]\n";
    ifstream inputFile(fs_dist_file);
    string line;
    int flow_size, frequency;
    map<int, int> target_fs_dist;

    idx = 0;
    while(getline(inputFile, line)){
        istringstream iss(line);
        iss >> flow_size >> frequency;
        while(flow_size > bins[idx]){
            if(idx < bins.size()-1) idx++;
            else break;
        }
        target_fs_dist[bins[idx]] += frequency;
    }
    inputFile.close();

    // for(auto item : target_fs_dist){
    //     if(item.second > 0 )
    //         cout << item.first << " " << item.second << endl;
    // }

    /* sample flow and generate another pcap file*/
    map<Flowkey_t, int> selected_flow;
    select_flow(target_fs_dist, quantized_mapping, selected_flow);
    char* synthetic_data_file_name = (char*)"/home/ming/SketchMercator/traffic_sampler/syn.pcap";
    vector<int> time_offset = {0, 4*60, 9*60, 29*60, 59*60}; // need to remove the offset of different pcap file
    int gen_num = 0;
    for(int i=0;i<pcap_num;i++){
        char *pcap_path = argv[3+i];
        pcap_generate(pcap_path, synthetic_data_file_name, flowkey, selected_flow, gen_num, time_offset[i]);
        if(selected_flow.size() == 0) break;
    }
    cout << "[packet sampling is completed] total sample packets: " << gen_num << "\n";

    

    /* sort the pcap file by the timestamp*/
    char* new_synthetic_data_file_name = (char*)"/home/ming/SketchMercator/traffic_sampler/sorted_syn.pcap";
    // vector<Packet_info> packets;
    // sort_pcap_file(synthetic_data_file_name, new_synthetic_data_file_name, packets);
    sort_pcap(synthetic_data_file_name, new_synthetic_data_file_name);

    return 0;


}