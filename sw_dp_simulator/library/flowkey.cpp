#include "flowkey.h"

void parse_key_flags(parameters &params)
{
    char* key = params.key;

    params.flowkey_flags.srcIP = (strstr(key, "srcIP") == NULL) ? 0 : 1;
    params.flowkey_flags.srcPort = (strstr(key, "srcPort") == NULL) ? 0 : 1;
    params.flowkey_flags.dstIP = (strstr(key, "dstIP") == NULL) ? 0 : 1;
    params.flowkey_flags.dstPort = (strstr(key, "dstPort") == NULL) ? 0 : 1;
    params.flowkey_flags.proto = (strstr(key, "proto") == NULL) ? 0 : 1;
}

void print_flowkey_flags(flowkey_flags_t &flowkey_flags)
{
    cout << "srcIP " << flowkey_flags.srcIP << endl;
    cout << "srcPort " << flowkey_flags.srcPort << endl;
    cout << "dstIP " << flowkey_flags.dstIP << endl;
    cout << "dstPort " << flowkey_flags.dstPort << endl;
    cout << "proto " << flowkey_flags.proto << endl << endl;
}

void get_flowkey(flowkey_t &flowkey, packet_summary &packet, parameters &params)
{
    flowkey.src_addr = (params.flowkey_flags.srcIP) ? packet.src_ip : 0;
    flowkey.src_port = (params.flowkey_flags.srcPort) ? packet.src_port : 0;
    flowkey.dst_addr = (params.flowkey_flags.dstIP) ? packet.dst_ip : 0;
    flowkey.dst_port = (params.flowkey_flags.dstPort) ? packet.dst_port : 0;
    flowkey.proto = (params.flowkey_flags.proto) ? packet.ip_proto : 0;
}

void print_flowkey(flowkey_t &flowkey)
{
    char buf[32];

    get_ip_char_from_int(buf, flowkey.src_addr);
    cout << "srcIP " << flowkey.src_addr << " " << buf << endl;
    cout << "srcPort "  << flowkey.src_port << endl;
    get_ip_char_from_int(buf, flowkey.dst_addr);
    cout << "dstIP "  << flowkey.dst_addr << " " << buf << endl;
    cout << "dstPort "  << flowkey.dst_port << endl;
    printf("proto %d\n", flowkey.proto);
    cout << endl;
}