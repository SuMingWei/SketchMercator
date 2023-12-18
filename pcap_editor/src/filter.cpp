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

using namespace std;

/* input argument */
char* input_folder_name;
char* output_folder_name;
char* pcap_file_name;
char* dummy_location;
char* filter_string;
int filter_rate;

int window_size;

/* global variables */
pcap_t *dummy_pt;
double init_time;

void split_start()
{
    char errbuf[PCAP_ERRBUF_SIZE];
    char file_path[500];
    sprintf(file_path, "%s/%s", input_folder_name, pcap_file_name);

    pcap_t *pt = pcap_open_offline(file_path, errbuf);
    pcap_dumper_t * pdt = NULL;

    char file_name[200];
    sprintf(file_name, "%s/%s", output_folder_name, pcap_file_name);
    pdt = pcap_dump_open(dummy_pt, file_name);

    int total_packet_count = 0;
    int packet_count = 0;

    struct pcap_pkthdr header;
    const u_char *packet;
    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;
        total_packet_count++;
        packet_header hdr;
        header_parser(hdr, packet, 0);

        packet_summary p;
        header_mapping(&header, hdr, p);

        // cout << total_packet_count << endl;

        // if (total_packet_count == 425) {
        //     print_packet_summary(p);
        // }

        if (strcmp(filter_string, "syn") == 0) {
            if (isSynPacket(hdr)) {
                if (filter_rate == 1) {
                    if (rand()%2 == 0) {
                        pcap_dump((u_char *)pdt, &header, packet);
                        packet_count++;
                    }
                }

                else if (filter_rate == 2) {
                    if (rand()%2 == 0) {
                        pcap_dump((u_char *)pdt, &header, packet);
                        packet_count++;
                    }
                    uint32_t ip = rand();
                    hdr.ip_hdr->ip_src = *(struct in_addr *)&ip;

                    pcap_dump((u_char *)pdt, &header, packet);
                    packet_count++;
                }

                else if (filter_rate == 3) {
                    pcap_dump((u_char *)pdt, &header, packet);
                    packet_count++;

                    uint32_t ip = rand();
                    hdr.ip_hdr->ip_src = *(struct in_addr *)&ip;

                    pcap_dump((u_char *)pdt, &header, packet);
                    packet_count++;
                }
            }
        }

        else if(strcmp(filter_string, "dns") == 0) {
            if(isDNSPacket(hdr, p)) {
                pcap_dump((u_char *)pdt, &header, packet);
                packet_count++;
            }

            if (filter_rate == 2) {
                if (rand()%300 == 0) {
                    uint32_t ip = 100;
                    hdr.ip_hdr->ip_dst = *(struct in_addr *)&ip;

                    pcap_dump((u_char *)pdt, &header, packet);
                    packet_count++;
                }
            }
        }

        else if(strcmp(filter_string, "http") == 0) {
            if (isHTTPGetPacket(hdr, p)) {
                // cout << "HTTP " << total_packet_count << endl;
                pcap_dump((u_char *)pdt, &header, packet);
                packet_count++;
            }
            if (filter_rate == 2) {
                uint32_t ip = rand();
                hdr.ip_hdr->ip_src = *(struct in_addr *)&ip;

                pcap_dump((u_char *)pdt, &header, packet);
                packet_count++;
            }
        }

        if (total_packet_count % 1000 == 0) {
            printf("%d/%d\n", packet_count, total_packet_count);
            // break;
        }
    }

    pcap_dump_close(pdt);
    printf("Done - %d \n\n", packet_count);

    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 7) {
        cout << "usage : ./filter [input folder] [output folder] [pcap file name] [dummy_location] [filter_string] [filter_rate]" << endl;
        return 0;
    }

    input_folder_name = argv[1];
    output_folder_name = argv[2];
    pcap_file_name = argv[3];
    dummy_location = argv[4];
    filter_string = argv[5];
    filter_rate = atoi(argv[6]);

    cout << "[input_folder_name] " << input_folder_name << endl;
    cout << "[output_folder_name] " << output_folder_name << endl;
    cout << "[pcap_file_name] " << pcap_file_name << endl;
    cout << "[dummy_location] " << dummy_location << endl;
    cout << "[filter_string] " << filter_string << endl;
    cout << "[filter_rate] " << filter_rate << endl;
    cout << endl;

    mkdir(output_folder_name, 0777);

    dummy_pt = pcap_open_offline(dummy_location, errbuf);

    split_start();

    pcap_close(dummy_pt);

    return 0;
}
