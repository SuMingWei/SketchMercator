#include <iostream>
#include <string>
#include <vector>
#include <map>

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
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <algorithm>

#include "pcap/parser.h"
#include "sys/sys.h"

using namespace std;

/* input argument */
char* input_folder_name;
char* output_folder_name;
char* input_pcap_file_name;
char* dummy_location;
int starting_index;
int max_flow_count;

/* global variables */
pcap_t *dummy_pt;
pcap_dumper_t * pdt = NULL;

char pcap_file_name[1000];

// map <uint32_t, int> packetMap;
map <flowkey_t, int> packetMap;

int pcap_count = 0;
int flowkey_increase = 0;
void maxflow_start()
{
    char errbuf[PCAP_ERRBUF_SIZE];
    char file_path[1000];
    sprintf(file_path, "%s/%s", input_folder_name, pcap_file_name);

    pcap_t *pt = pcap_open_offline(file_path, errbuf);

    int packet_count = 0;

    struct pcap_pkthdr header;
    const u_char *packet;
    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;
        packet_count++;
        packet_header hdr;
        header_parser(hdr, packet, 0);

        packet_summary p;
        header_mapping(&header, hdr, p);

        if(hdr.ip_hdr->ip_v == 4) {
            flowkey_t flowkey;

            flowkey.src_addr = p.src_ip;
            flowkey.src_port = p.src_port;
            flowkey.dst_addr = p.dst_ip;
            flowkey.dst_port = p.dst_port;
            flowkey.proto = p.ip_proto;
            if (packetMap.find(flowkey) == packetMap.end()) {
                flowkey_increase++;
                packetMap[flowkey]=flowkey_increase;
            }

            uint32_t ip = packetMap[flowkey];
            hdr.ip_hdr->ip_src = *(struct in_addr *)&ip;
            pcap_dump((u_char *)pdt, &header, packet);
        }

        if (packet_count % 100000 == 0) {
            printf("[%d] %d %zu/%d=%.1f%%\n", pcap_count, packet_count, packetMap.size(), max_flow_count, (double)packetMap.size()/(double)max_flow_count*100);
        }

        if (packetMap.size() >= max_flow_count) {
            break;
        }
    }

    printf("Done - %d \n\n", packet_count);

    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 7) {
        cout << "usage : ./filter [input folder] [output folder] [pcap file name] [dummy_location] [starting_index] [max_flow_count]" << endl;
        return 0;
    }

    input_folder_name = argv[1];
    output_folder_name = argv[2];
    input_pcap_file_name = argv[3];
    dummy_location = argv[4];
    starting_index = atoi(argv[5]);
    max_flow_count = atoi(argv[6]);

    cout << endl;
    cout << "[input_folder_name] " << input_folder_name << endl;
    cout << "[output_folder_name] " << output_folder_name << endl;
    cout << "[input_pcap_file_name] " << input_pcap_file_name << endl;
    cout << "[dummy_location] " << dummy_location << endl;
    cout << "[starting_index] " << starting_index << endl;
    cout << "[max_flow_count] " << max_flow_count << endl;
    cout << endl;

    sys_mkdir(string(output_folder_name));

    dummy_pt = pcap_open_offline(dummy_location, errbuf); //

    char file_name[1000];
    sprintf(file_name, "%s/%s", output_folder_name, input_pcap_file_name);
    // cout << file_name << endl;

    pdt = pcap_dump_open(dummy_pt, file_name); //


    vector<string> strVec;
    folder_iterate(input_folder_name, strVec);

    sort(strVec.begin(), strVec.end());

    for (auto& it : strVec) {
        pcap_count++;
        if (pcap_count >= starting_index) {
            cout << it << endl;
            sprintf(pcap_file_name, "%s", it.c_str());
            maxflow_start();
        }
        if (packetMap.size() >= max_flow_count) {
            break;
        }
    }

    pcap_dump_close(pdt); //

    pcap_close(dummy_pt); //

    return 0;
}
