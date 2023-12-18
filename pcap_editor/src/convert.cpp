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
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "pcap/parser.h"
#include "sys/sys.h"

using namespace std;

/* input argument */
char* input_file_path;
char* output_folder_path;
char* output_file_name;

void split_start()
{
    uint64_t initial_timestamp = 0;

    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t *pt = pcap_open_offline(input_file_path, errbuf);

    int global_count = 0;

    char file_name[5000];
    sprintf(file_name, "%s/%s", output_folder_path, output_file_name);
    // cout << file_name << endl;
    FILE * f = fopen(file_name, "w");

    struct pcap_pkthdr header;
    const u_char *packet;
    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;
        global_count++;

        packet_header hdr;
        header_parser(hdr, packet, 0);

        packet_summary p;
        header_mapping(&header, hdr, p);
        if(hdr.ip_hdr->ip_v == 4) {
            fprintf(f, "%c%c%c%c", (p.src_ip>>0)&0xFF, (p.src_ip>>8)&0xFF, (p.src_ip>>16)&0xFF, (p.src_ip>>24)&0xFF);
            fprintf(f, "%c%c%c%c", (p.dst_ip>>0)&0xFF, (p.dst_ip>>8)&0xFF, (p.dst_ip>>16)&0xFF, (p.dst_ip>>24)&0xFF);
            fprintf(f, "%c%c", (p.src_port>>0)&0xFF, (p.src_port>>8)&0xFF);
            fprintf(f, "%c%c", (p.dst_port>>0)&0xFF, (p.dst_port>>8)&0xFF);
            fprintf(f, "%c", (p.ip_proto>>0)&0xFF);
            fprintf(f, "%c%c%c%c%c%c%c%c", (int)(p.timestamp>>0)&0xFF, (int)(p.timestamp>>8)&0xFF, (int)(p.timestamp>>16)&0xFF, (int)(p.timestamp>>24)&0xFF,
                                           (int)(p.timestamp>>32)&0xFF, (int)(p.timestamp>>40)&0xFF, (int)(p.timestamp>>48)&0xFF, (int)(p.timestamp>>56)&0xFF);
            if(initial_timestamp == 0) {
                initial_timestamp = p.timestamp;
            }

            if (global_count % 1000000 == 0) {
                printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, file_name);
            }
        }
    }
    printf("Done - %d %s \n\n", global_count, file_name);

    fclose(f);
    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 4) {
        cout << "usage : ./filter [input_file_path] [output_folder_path] [output_file_name]" << endl;
        return 0;
    }

    input_file_path = argv[1];
    output_folder_path = argv[2];
    output_file_name = argv[3];
    cout << endl;
    cout << "[input_file_path] " << input_file_path << endl;
    cout << "[output_folder_path] " << output_folder_path << endl;
    cout << "[output_file_name] " << output_file_name << endl;
    sys_mkdir(string(output_folder_path));
    split_start();

    return 0;
}
