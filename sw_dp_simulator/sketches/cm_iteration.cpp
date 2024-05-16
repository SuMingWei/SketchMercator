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

void cmIteration::counter_file_print(parameters &params, int idx, int window_size)
{
    // print each window counter value
    int level=0;
    parameters level_params = params;
    sprintf(level_params.output_dir, "%s%02d/level_%02d/window_%d/", params.output_dir, params.current_epoch_count, level, window_size);
    string file_name = to_string(idx);
    if(idx < 10) file_name = "0" + file_name;
    cout << "[counter file print] " << file_name << endl;
    cm_level[level].counter_info_file_print(level_params, file_name);

    // print each window topk flowkey
    int k = 0; // print k lines 
    KeyValueVector kv_vec_2(flowkey_tracking, params);
    // kv_vec_2.sort_vector();
    kv_vec_2.shuffle_vector();
    parameters new_params_2 = params;
    sprintf(new_params_2.output_dir, "%s%02d/level_%02d/key_window_%d/", params.output_dir, params.current_epoch_count, level, window_size);
    string key_file_name = file_name + ".txt";
    cout << "[topK key file print] " << key_file_name << endl;
    kv_vec_2.file_print(new_params_2, key_file_name, k);

    // print each window ground truth
    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/level_%02d/gt_window_%d/", params.output_dir, params.current_epoch_count, level, window_size);
    cout << "[topK gt file print] " << key_file_name << endl;
    kv_vec.file_print(new_params, key_file_name, k);
}