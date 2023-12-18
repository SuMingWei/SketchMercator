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

using namespace std;

/* input argument */
char* input_folder_name;
char* output_folder_name;
char* pcap_file_name;
char* dummy_location;

int window_size;

/* global variables */
pcap_t *dummy_pt;
double init_time;

void split_start()
{
    char errbuf[PCAP_ERRBUF_SIZE];
    char file_path[100];
    sprintf(file_path, "%s/%s", input_folder_name, pcap_file_name);
    pcap_t *pt = pcap_open_offline(file_path, errbuf);
    pcap_dumper_t * pdt = NULL;

    double checkpoint = -999999;
    double time;

    char file_name[200];
    char a[100] = {0, };
    char b[100] = {0, };

    int pcap_count = 0;
    int packet_count = 0;

    struct pcap_pkthdr header;
    const u_char *packet;
    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;

        time = (double)header.ts.tv_sec + (double)(header.ts.tv_usec) / 1000000;

        if(time > checkpoint + window_size) {
            if(pdt != NULL) {
                printf("Done - %f %d \n\n", (time - checkpoint), packet_count);
                pcap_dump_close(pdt);
            }
            checkpoint = time;

            string pf = pcap_file_name;

            if(strlen(pcap_file_name) == 46) {
                strncpy(a, pcap_file_name, 30);
                strcpy(b, pcap_file_name + 32);
            }
            else {
                strncpy(a, pcap_file_name, 34);
                strcpy(b, pcap_file_name + 36);
            }

            sprintf(file_name, "%s/%s%02d%s", output_folder_name, a, window_size * pcap_count, b);

            printf("%s\n", file_name);
            pdt = pcap_dump_open(dummy_pt, file_name);
            cout << file_name << " ";
            packet_count = 0;
            pcap_count++;
        }

        pcap_dump((u_char *)pdt, &header, packet);
        packet_count++;
//        cout << packet_count << endl;
    }

    pcap_dump_close(pdt);
    printf("Done - %f %d \n\n", (time - checkpoint), packet_count);

    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 6) {
        cout << "usage : ./split [input folder] [output folder] [pcap file name] [split window (in seconds)] [dummy_location]" << endl;
        return 0;
    }

    input_folder_name = argv[1];
    output_folder_name = argv[2];
    pcap_file_name = argv[3];
    window_size = atoi(argv[4]);
    dummy_location = argv[5];

    cout << input_folder_name << endl;
    cout << output_folder_name << endl;
    cout << pcap_file_name << endl;
    cout << window_size << endl;
    cout << dummy_location << endl;
    cout << endl;

    mkdir(output_folder_name, 0777);

//    dummy_pt = pcap_open_offline("dummy.pcap", errbuf);
//    dummy_pt = pcap_open_offline("../_01_pcap_spliter/dummy.pcap", errbuf);
    dummy_pt = pcap_open_offline(dummy_location, errbuf);

    split_start();

    pcap_close(dummy_pt);

    return 0;
}
