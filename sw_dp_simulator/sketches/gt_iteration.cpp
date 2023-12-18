#include "gt_iteration.h"

gtIteration::gtIteration()
{
}
void gtIteration::init(parameters &params)
{
}

void gtIteration::load_hash(parameters &params) {
}

void gtIteration::iteration(packet_summary &p, parameters &params)
{
    flowkey_t flowkey;
    int elem = params.is_count_packet ? 1 : p.size;
//        print_packet(*p);
    get_flowkey(flowkey, p, params);
//    print_flowkey(flowkey);

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void gtIteration::file_print(parameters &params)
{
    gt_file_print(packetMap, params, 0);
}

void gtIteration::clear(parameters &params)
{
    packetMap.clear();
}
