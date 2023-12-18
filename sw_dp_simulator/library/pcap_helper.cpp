#include "pcap_helper.h"

using namespace std;

int global_count;


void pcap_file_parse(char* pcap_file_name, vector<packet_summary> &packet_stream)
{
    uint64_t initial_timestamp = 0;

    pcap_t *descr;
    char errbuf[PCAP_ERRBUF_SIZE];
    descr = pcap_open_offline(pcap_file_name, errbuf);
    cout << pcap_file_name << endl;
    struct pcap_pkthdr header;
    const u_char *packet;

    global_count = 0;

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
                packet_stream.push_back(p);

                if(initial_timestamp == 0) {
                    initial_timestamp = p.timestamp;
                }

                if (global_count % 1000000 == 0) {
                    printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);
                }
            }
            else {
                non_tcpudp++;
            }

            // struct pcap_pkthdr  *pkt_hdr =(struct pcap_pkthdr *)packet;
            // unsigned int packet_length = pkt_hdr->len;


            // if (p.src_ip == 2464186718 && p.dst_ip == 1875764454 && p.src_port == 55137 && p.dst_port == 8080 && p.ip_proto == 17) {
            //     debug_count += 1;
            //     // cout << global_count+non_tcpudp+non_ipv4 << " " << debug_count << " " << p.size << endl;
            //     printf("tag [%4d] [%5d] [%4d] [%4d] [%4d]\n", global_count+non_tcpudp+non_ipv4, debug_count, p.size, header.len, header.caplen);
            //     if (debug_count > 30) {
            //         exit(1);
            //     }
            // }
            // else {
            //     printf("    [%4d] [     ] [%4d] [%4d] [%4d]\n", global_count+non_tcpudp+non_ipv4, p.size, header.len, header.caplen);
            // }
        }
        else {
            non_ipv4++;
        }


    }
    // cout << global_count << " " << non_tcpudp << " " << non_ipv4 << endl;
    // exit(1);
}

void dat_file_parse(char* pcap_file_name, vector<packet_summary> &packet_stream)
{
    uint64_t initial_timestamp = 0;
    FILE *fin = fopen(pcap_file_name, "rb");

    fseek(fin, 0L, SEEK_END);
    uint32_t sz = ftell(fin);
    fseek(fin, 0L, SEEK_SET);
    if (sz < 1024 * 1024)
        std::cout << "Size of File : " << sz/1024 << "KB" << std::endl;
    else
        std::cout << "Size of File : " << sz/1024/1024 << "MB" << std::endl;

    while (feof(fin) == 0) {
        packet_summary p;
        fread(&p.src_ip, 1, 4, fin);
        fread(&p.dst_ip, 1, 4, fin);
        fread(&p.src_port, 1, 2, fin);
        fread(&p.dst_port, 1, 2, fin);
        fread(&p.ip_proto, 1, 1, fin);

        fread(&p.timestamp, 1, 8, fin);

        get_ip_char_from_int(p.src_ip_addr, p.src_ip);
        get_ip_char_from_int(p.dst_ip_addr, p.dst_ip);

        if (p.ip_proto == IP_PROTO_UDP || p.ip_proto == IP_PROTO_TCP) {
            global_count++;
            packet_stream.push_back(p);

            // print_packet_summary(p);
            if(initial_timestamp == 0) {
                initial_timestamp = p.timestamp;
            }

            // if (global_count % 1000000 == 0) {
            if (global_count % 1000000 == 0) {
                printf("[%10d] %.2fs (%.2f) %s\n", global_count, (double)(p.timestamp-initial_timestamp)/1000000, (double)p.timestamp/1000000, pcap_file_name);
            }
        }
    }
}

void pcap_parse(char* pcap_file_name, vector<packet_summary> &packet_stream)
{
    if(strstr(pcap_file_name, ".dat") != NULL) {
        dat_file_parse(pcap_file_name, packet_stream);
    }
    if (strstr(pcap_file_name, ".pcap") != NULL) {
        pcap_file_parse(pcap_file_name, packet_stream);
    }
}
