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
char* pcap_full_path;

void counter_start()
{
    char errbuf[PCAP_ERRBUF_SIZE];
    char file_path[100];
    sprintf(file_path, "%s", pcap_full_path);
    pcap_t *pt = pcap_open_offline(file_path, errbuf);

    int packet_count = 0;

    struct pcap_pkthdr header;
    const u_char *packet;
    while(true) {
        packet = pcap_next(pt, &header);
        if(packet == NULL)
            break;
        packet_count++;
    }
    printf("%d\n", packet_count);
    pcap_close(pt);
}

int main(int argc, char* argv[]) {

    int i;
    char errbuf[PCAP_ERRBUF_SIZE];

    if(argc != 2) {
        cout << "usage : ./counter [pcap full path]" << endl;
        return 0;
    }

    pcap_full_path = argv[1];

    counter_start();

    return 0;
}
