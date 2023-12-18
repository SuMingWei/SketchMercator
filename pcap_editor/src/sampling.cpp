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

int sampling_rate;

/* global variables */
pcap_t *dummy_pt;
double init_time;

void sampling_start()
{
    char errbuf[PCAP_ERRBUF_SIZE];
    char file_path[100];
    char file_name[200];
    int packet_count = 0;
    struct pcap_pkthdr header;
    const u_char *packet;

    sprintf(file_path, "%s/%s", input_folder_name, pcap_file_name);
    pcap_t *pt = pcap_open_offline(file_path, errbuf);

    sprintf(file_name, "%s/%s", output_folder_name, "sampling.pcap");

    pcap_dumper_t * pdt = NULL;
    pdt = pcap_dump_open(dummy_pt, file_name);

    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;

        packet_count++;
//        if(packet_count % sampling_rate == 0)
        pcap_dump((u_char *)pdt, &header, packet);
    }
    pcap_dump_close(pdt);
    printf("Done - %d \n\n", packet_count);

    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 6) {
        cout << "usage : ./sampling [input folder] [output folder] [pcap file name] [samplint rate] [dummy_location]" << endl;
        return 0;
    }

    input_folder_name = argv[1];
    output_folder_name = argv[2];
    pcap_file_name = argv[3];
    sampling_rate = atoi(argv[4]);
    dummy_location = argv[5];

    cout << input_folder_name << endl;
    cout << output_folder_name << endl;
    cout << pcap_file_name << endl;
    cout << sampling_rate << endl;
    cout << dummy_location << endl;
    cout << endl;


    mkdir(output_folder_name, 0777);

    dummy_pt = pcap_open_offline(dummy_location, errbuf);

    sampling_start();

    pcap_close(dummy_pt);

    return 0;
}
