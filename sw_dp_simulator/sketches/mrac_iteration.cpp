#include "mrac_iteration.h"

mracIteration::mracIteration()
{
}

void mracIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        cm_level.push_back(sketchTemplate(params, level));
        // level_PQ_top200.push_back(PriorityQueue(1000));
    }
    if (params.threshold == 20140320) {
        // threshold_list = [13324, 7937, 4706, 2756, 1418, 630, 242, 101, 47, 15, 6, 1, 0, 0, 0, 0]
        threshold[0] = 13324; threshold[1] = 7937; threshold[2] = 4706; threshold[3] = 2756; threshold[4] = 1418; threshold[5] = 630; threshold[6] = 242; threshold[7] = 101; threshold[8] = 47; threshold[9] = 15; threshold[10] = 6; threshold[11] = 1; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
    else if(params.threshold == 20140619) {
        // threshold_list = [12775, 7605, 4542, 2390, 1393, 618, 274, 111, 41, 14, 6, 2, 0, 0, 0, 0]
        threshold[0] = 12775; threshold[1] = 7605; threshold[2] = 4542; threshold[3] = 2390; threshold[4] = 1393; threshold[5] = 618; threshold[6] = 274; threshold[7] = 111; threshold[8] = 41; threshold[9] = 14; threshold[10] = 6; threshold[11] = 2; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
    else if(params.threshold == 20160121) {
        // threshold_list = [9303, 6968, 3970, 2047, 1032, 461, 206, 61, 23, 13, 5, 1, 0, 0, 0, 0]
        threshold[0] = 9303; threshold[1] = 6968; threshold[2] = 3970; threshold[3] = 2047; threshold[4] = 1032; threshold[5] = 461; threshold[6] = 206; threshold[7] = 61; threshold[8] = 23; threshold[9] = 13; threshold[10] = 5; threshold[11] = 1; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
    else if(params.threshold == 20180517) {
        // threshold_list = [14688, 8870, 5268, 2872, 1427, 567, 221, 77, 23, 8, 2, 0, 0, 0, 0, 0]
        threshold[0] = 14688; threshold[1] = 8870; threshold[2] = 5268; threshold[3] = 2872; threshold[4] = 1427; threshold[5] = 567; threshold[6] = 221; threshold[7] = 77; threshold[8] = 23; threshold[9] = 8; threshold[10] = 2; threshold[11] = 0; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
    else if(params.threshold == 20180816) {
        // threshold_list = [13839, 9292, 5781, 3214, 1648, 698, 273, 90, 26, 10, 2, 0, 0, 0, 0, 0]
        threshold[0] = 13839; threshold[1] = 9292; threshold[2] = 5781; threshold[3] = 3214; threshold[4] = 1648; threshold[5] = 698; threshold[6] = 273; threshold[7] = 90; threshold[8] = 26; threshold[9] = 10; threshold[10] = 2; threshold[11] = 0; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
    else {
        threshold[0] = 10; threshold[1] = 10; threshold[2] = 10; threshold[3] = 10; threshold[4] = 10; threshold[5] = 10; threshold[6] = 10; threshold[7] = 10; threshold[8] = 10; threshold[9] = 10; threshold[10] = 6; threshold[11] = 1; threshold[12] = 0; threshold[13] = 0; threshold[14] = 0; threshold[15] = 0; threshold[16] = 0; threshold[17] = 0;
    }
}

void mracIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, cm_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            cm_level[i].index_hash = cm_level[0].index_hash;
            cm_level[i].res_hash = cm_level[0].res_hash;
        }
    }
}

void mracIteration::iteration(packet_summary &p, parameters &params)
{
    flowkey_t flowkey;
//        print_packet(*p);
    get_flowkey(flowkey, p, params);
//        print_flowkey(flowkey);
    int elem = params.is_count_packet ? 1 : p.size;
    int last_level = 0;
    if(params.is_compact_hash) {
        uint32_t sh = sampling_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, 33554432); // 33554432 = 2 ^25
        last_level = get_last_level(sh, params.level);
    }
    else {
        for(int i=0; i<=params.level-1; i++) {
            uint32_t sh = sampling_hash->compute_hash(flowkey, params.flowkey_flags, i, params.is_crc_hash, 33554432);
            if((sh & 1) == 1)
                last_level++;
            else
                break;
        }
    }
    int estimate;

    if (params.is_update_last_level == 1) {
        if(last_level < params.level) {
            estimate = cm_level[last_level].count_min_sketch(flowkey, params, elem);
            // level_PQ_top200[last_level].update(flowkey, estimate, false);

            // threshold
            if (estimate >= threshold[last_level]) {
                flowkey_tracking[flowkey] = estimate;
            }
        }
    }
    else {
        for (int level = 0; level <= last_level; level++) {
            if (level >= params.level)
                break;
            estimate = cm_level[level].count_min_sketch(flowkey, params, elem);
            // level_PQ_top200[level].update(flowkey, estimate, false);
        }
    }

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void mracIteration::file_print(parameters &params)
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
    mrac_file_print(cm_level, *sampling_hash, params, entropy, packetMap, flowkey_tracking, 0);
}

void mracIteration::clear(parameters &params)
{
    for(int i = 0; i < 25; i++) {
        cm_level[i].clear();
        // level_PQ_top200[i].clear();
    }
    packetMap.clear();
    flowkey_tracking.clear();
}
