#include "hll_iteration.h"

hllIteration::hllIteration()
{
}

void hllIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        hll_level.push_back(sketchTemplate(params, level));
    }
}

void hllIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, hll_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            hll_level[i].index_hash = hll_level[0].index_hash;
            hll_level[i].res_hash = hll_level[0].res_hash;
        }
    }
}

void hllIteration::iteration(packet_summary &p, parameters &params)
{
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
    uint32_t sh = sampling_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, 1073741824); // 1073741824 = 2 ^ 30
    int last_level = get_last_level(sh, 30);
    
    hll_level[0].hll_sketch(flowkey, params, last_level);

    int elem = params.is_count_packet ? 1 : p.size;

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void hllIteration::file_print(parameters &params)
{
    hll_file_print(hll_level, *sampling_hash, params, packetMap.size());
}

void hllIteration::clear(parameters &params)
{
    hll_level[0].clear();
    packetMap.clear();
}
