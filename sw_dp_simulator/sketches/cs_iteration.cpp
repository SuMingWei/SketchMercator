#include "cs_iteration.h"

csIteration::csIteration()
{
}

void csIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        cs_level.push_back(sketchTemplate(params, level));
    }
}

void csIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, cs_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            cs_level[i].index_hash = cs_level[0].index_hash;
            cs_level[i].res_hash = cs_level[0].res_hash;
        }
    }
}

void csIteration::iteration(packet_summary &p, parameters &params)
{
    int elem = params.is_count_packet ? 1 : p.size;
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
    cs_level[0].count_sketch(flowkey, params, elem);

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void csIteration::file_print(parameters &params)
{
    uint64_t f2 = 0;
    for (auto it = packetMap.begin(); it != packetMap.end(); it++)
    {
        f2 += (uint64_t)(it->second) * (uint64_t)(it->second);
    }

    int total = 0;
    for (auto it = packetMap.begin(); it != packetMap.end(); it++)
    {
        total += it->second;
    }
    double entropy = 0;
    for (auto it = packetMap.begin(); it != packetMap.end(); it++)
    {
        double p = ((double)it->second/(double)total);
        entropy += p * log2(p);
    }
    entropy = entropy * -1;
    printf("entropy: %.20f\n", entropy);

    cs_file_print(cs_level, *sampling_hash, params, entropy, f2, packetMap, 1000);
}

void csIteration::clear(parameters &params)
{
    cs_level[0].clear();
    packetMap.clear();
}
