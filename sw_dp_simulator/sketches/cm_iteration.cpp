#include "cm_iteration.h"

cmIteration::cmIteration()
{
}

void cmIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        cm_level.push_back(sketchTemplate(params, level));
    }
}

void cmIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, cm_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            cm_level[i].index_hash = cm_level[0].index_hash;
            cm_level[i].res_hash = cm_level[0].res_hash;
        }
    }
}

void cmIteration::iteration(packet_summary &p, parameters &params)
{
    int elem = params.is_count_packet ? 1 : p.size;
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
    int est = cm_level[0].count_min_sketch(flowkey, params, elem);
    
    // cout << est << " " << params.threshold << endl;

    if (est >= params.threshold) {
        flowkey_tracking[flowkey] = est;
    }

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void cmIteration::file_print(parameters &params)
{
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
    cm_file_print(cm_level, *sampling_hash, params, entropy, packetMap, flowkey_tracking, 1000);
}

void cmIteration::clear(parameters &params)
{
    cm_level[0].clear();
    packetMap.clear();
    flowkey_tracking.clear();
}
