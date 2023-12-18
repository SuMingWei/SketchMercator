#include "fcm_iteration.h"

fcmIteration::fcmIteration()
{
}

void fcmIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        fcm_level.push_back(sketchTemplate(params, level));
    }
    for(int i=0; i<4096; i++) {
        reg_val_all[i] = 0;
        hash_table_key[i] = -1;
        hash_table_value[i] = 0;
    }
}

void fcmIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, fcm_level, params);
    for(int i = 0; i < 25; i++) {
        if (params.is_same_level_hash == 1) {
            fcm_level[i].index_hash = fcm_level[0].index_hash;
            fcm_level[i].res_hash = fcm_level[0].res_hash;
        }
    }
}

void fcmIteration::iteration(packet_summary &p, parameters &params)
{
    int elem = params.is_count_packet ? 1 : p.size;
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
    int est = fcm_level[0].fcm_sketch(flowkey, params, elem);
    
    if (est >= params.threshold) {
        flowkey_tracking[flowkey] = est;
    }

    // gt
    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }


    // topk
    int hash_index = fcm_level[0].get_index_hash(flowkey, params) % 4096;
    reg_val_all[hash_index]++;
    int reg_val = reg_val_all[hash_index] >> 5;
    // cout << flowkey.src_addr << " " << hash_index << " " << reg_val << endl;

    bool cond_hi = (flowkey.src_addr == (uint32_t)hash_table_key[hash_index]);
    bool cond_lo = reg_val > hash_table_value[hash_index];
    int backup_key, backup_value;
    if(cond_hi || cond_lo) {
        backup_key = hash_table_key[hash_index];
        backup_value = hash_table_value[hash_index];

        hash_table_key[hash_index] = flowkey.src_addr;
        hash_table_value[hash_index]++;
    }
    else {
        backup_key = flowkey.src_addr;
        backup_value = 1;
    }

    if(cond_hi == false) {
        flowkey.src_addr = backup_key;
        elem = backup_value;
        fcm_level[1].fcm_sketch(flowkey, params, elem);
    }
}

void fcmIteration::file_print(parameters &params)
{
    for(int i=0; i<4096; i++) {
        if(hash_table_key[i] != -1) {
            flowkey_t flowkey;
            flowkey.src_addr = hash_table_key[i];
            flowkey.src_port = 0;
            flowkey.dst_addr = 0;
            flowkey.dst_port = 0;
            flowkey.proto = 0;

            flowkey_topk[flowkey] = hash_table_value[i];
        }
    }

    fcm_file_print(fcm_level, *sampling_hash, params, packetMap, flowkey_tracking, flowkey_topk, 1000);
}

void fcmIteration::clear(parameters &params)
{
    fcm_level[0].clear();
    fcm_level[1].clear();
    packetMap.clear();
    flowkey_tracking.clear();
    flowkey_topk.clear();
    for(int i=0; i<4096; i++) {
        reg_val_all[i] = 0;
        hash_table_key[i] = -1;
        hash_table_value[i] = 0;
    }
}
