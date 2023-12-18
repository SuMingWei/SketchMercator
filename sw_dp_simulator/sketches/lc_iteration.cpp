#include "lc_iteration.h"

lcIteration::lcIteration()
{
}

void lcIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        lc_level.push_back(sketchTemplate(params, level));
    }
}

void lcIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, lc_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            lc_level[i].index_hash = lc_level[0].index_hash;
            lc_level[i].res_hash = lc_level[0].res_hash;
        }
    }
}

void lcIteration::iteration(packet_summary &p, parameters &params)
{
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
  
    lc_level[0].lc_sketch(flowkey, params);

    int elem = params.is_count_packet ? 1 : p.size;

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void lcIteration::file_print(parameters &params)
{
    lc_file_print(lc_level, *sampling_hash, params, packetMap.size());
}

void lcIteration::clear(parameters &params)
{
    lc_level[0].clear();
    packetMap.clear();
}
