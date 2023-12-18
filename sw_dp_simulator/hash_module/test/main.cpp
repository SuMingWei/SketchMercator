#include <iostream>
#include <vector>

#include "unistd.h"
#include "getopt.h"

#include "../cpp/hash.h"
#include "../../library/flowkey.h"

using namespace std;

int main(int argc, char* argv[])
{
    parameters params;
    static struct option long_options[] =
        {
            {"key",                 required_argument, 0, 'k'},
            {"crc_hash_on",         no_argument,       0, 'c'},
            {0, 0, 0, 0}
        };

    int c;
    int option_index = 0;
    while(true) {

        c = getopt_long(argc, argv, "k:c", long_options, &option_index);

        if (c == -1)
            break;
        switch(c) {
            // common parameters
            case 'k':
                memcpy(params.key, optarg, 500);
                break;
            case 'c':
                params.is_crc_hash = 1;
                break;

            case '?':
                printf("Unknown flag : %c, exit\n", optopt);
                exit(0);
                break;
        }
    }

    parse_key_flags(params);
//    cout << params.flowkey_flags.srcIP << endl;
//    cout << params.flowkey_flags.srcPort << endl;
//    cout << params.flowkey_flags.dstIP << endl;
//    cout << params.flowkey_flags.dstPort << endl;
//    cout << params.flowkey_flags.proto << endl;
//    cout << endl;

    packet_summary p;
//    p.src_ip = 2289198401; // 136.114.101.65
    p.src_ip = 964048477;

    p.src_port = 100;
    p.dst_ip = 146116538; // 8.181.143.186
    p.dst_port = 53;
    p.ip_proto = 6;

    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);

    HashSeedSet hash_example(1);
    hash_example.aParams[0] = 13456091;
    hash_example.bParams[0] = 14884994;
    hash_example.polyParams[0] = 807681803;
//    hash_example.printParams();
//    [aParams]       [bParams] |   [polynomials]          [init]          [xout]
//    16807         3057642 |      1622650073               0      4294967295
//    26940434        26438502 |       470211272               0      4294967295

    cout << params.key << endl;
//    cout << flowkey.src_addr << endl;
//    cout << flowkey.src_port << endl;
//    cout << flowkey.dst_addr << endl;
//    cout << flowkey.dst_port << endl;
//    printf("%d\n", flowkey.proto);
//    cout << hash_example.compute_hash(flowkey, params.flowkey_flags, 0, 0, 1024) << endl;

    uint32_t result1, result2;
    result1 = hash_example.compute_hash(flowkey, params.flowkey_flags, 0, 0, 2048);
    result2 = hash_example.compute_hash(flowkey, params.flowkey_flags, 0, 1, 2048);
    printf("%d 0x%X\n\n", result1, result2);

    return 0;
}
