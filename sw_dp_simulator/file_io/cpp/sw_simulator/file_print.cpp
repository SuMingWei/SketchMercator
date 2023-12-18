#include "file_print.h"

void gt_file_print(map <flowkey_t, int> &packetMap, parameters &params, int line_count)
{
    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    cout << new_params.output_dir << endl;
    kv_vec.file_print(new_params, "ground_truth.txt", line_count);
}

void univmon_file_print(vector<sketchTemplate> countSketch_level, vector<PriorityQueue> level_PQ_top200, HashSeedSet &sampling_hash, parameters &params, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count)
{
    for (int level = 0; level < params.level; level++) {
        // cout << "level " << level << endl;
        parameters level_params = params;
        sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
        // cout << level_params.output_dir << endl;
        countSketch_level[level].sketch_info_file_print(level_params, sampling_hash);

        KeyValueVector kv_vec(level_PQ_top200[level], params);
        kv_vec.sort_vector();
        kv_vec.file_print(level_params, "top_200.txt", 0);
    }

    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    // cout << new_params.output_dir << endl;
    kv_vec.file_print(new_params, "ground_truth.txt", line_count);

    KeyValueVector kv_vec_2(flowkey_tracking, params);
    kv_vec_2.sort_vector();
    parameters new_params_2 = params;
    sprintf(new_params_2.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec_2.file_print(new_params_2, "/flowkey.txt", 0);

}

void mrac_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count)
{
    for (int level = 0; level < params.level; level++) {
        // cout << "level " << level << endl;
        parameters level_params = params;
        sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
        // cout << level_params.output_dir << endl;
        countSketch_level[level].sketch_info_file_print(level_params, sampling_hash);

        // KeyValueVector kv_vec(level_PQ_top200[level], params);
        // kv_vec.sort_vector();
        // kv_vec.file_print(level_params, "top_200.txt", 0);
    }

    parameters tmp_params = params;
    sprintf(tmp_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    string file_name;
    FILE* fp;
    file_name = tmp_params.output_dir + string("entropy.txt");
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%.20f\n", entropy);
    fclose(fp);

    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    // cout << new_params.output_dir << endl;
    kv_vec.file_print(new_params, "ground_truth.txt", line_count);

    KeyValueVector kv_vec_2(flowkey_tracking, params);
    kv_vec_2.sort_vector();
    parameters new_params_2 = params;
    sprintf(new_params_2.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec_2.file_print(new_params_2, "/flowkey.txt", 0);

}

void hll_file_print(vector<sketchTemplate> hll_level, HashSeedSet &sampling_hash, parameters &params, int cardinality)
{
    int level = 0;
    parameters level_params = params;
    sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
    cout << level_params.output_dir << endl;
    // /data1/hun/sketch_home/result_sw_dp/hll/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/01/level_00/
    hll_level[level].sketch_info_file_print(level_params, sampling_hash);

    level_params = params;
    sprintf(level_params.output_dir, "%s%02d/", params.output_dir, params.current_epoch_count);
    string dir_name = string(level_params.output_dir);
    string file_name;
    FILE* fp;
    file_name = dir_name + "cardinality.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%d\n", cardinality);
    fclose(fp);
}

void lc_file_print(vector<sketchTemplate> lc_level, HashSeedSet &sampling_hash, parameters &params, int cardinality)
{
    int level = 0;
    parameters level_params = params;
    sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
    cout << level_params.output_dir << endl;
    // /data1/hun/sketch_home/result_sw_dp/lc/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/01/level_00/
    lc_level[level].sketch_info_file_print(level_params, sampling_hash);

    level_params = params;
    sprintf(level_params.output_dir, "%s%02d/", params.output_dir, params.current_epoch_count);
    string dir_name = string(level_params.output_dir);
    string file_name;
    FILE* fp;
    file_name = dir_name + "cardinality.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%d\n", cardinality);
    fclose(fp);
}

void mrb_file_print(vector<sketchTemplate>  mrb_level, HashSeedSet &sampling_hash, parameters &params, int cardinality)
{
    // int level = 0;
    for (int level = 0; level < params.level; level++) {
        parameters level_params = params;
        sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
        // cout << level_params.output_dir << endl;
        // /data1/hun/sketch_home/result_sw_dp/mrb/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/01/level_00/
        mrb_level[level].sketch_info_file_print(level_params, sampling_hash);
    }

    parameters level_params = params;
    sprintf(level_params.output_dir, "%s%02d/", params.output_dir, params.current_epoch_count);
    string dir_name = string(level_params.output_dir);
    string file_name;
    FILE* fp;
    file_name = dir_name + "cardinality.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%d\n", cardinality);
    fclose(fp);
}

void cs_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, uint64_t f2, map <flowkey_t, int> &packetMap, int line_count)
{
    int level=0;
    parameters level_params = params;
    sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
    cout << level_params.output_dir << endl;
    countSketch_level[level].sketch_info_file_print(level_params, sampling_hash);

    string dir_name = string(level_params.output_dir);
    string file_name;
    FILE* fp;
    file_name = dir_name + "entropy.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%.20f\n", entropy);
    fclose(fp);

    file_name = dir_name + "f2.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%" PRIu64 "\n", f2);
    fclose(fp);

    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec.file_print(new_params, "/ground_truth.txt", line_count);
}

void cm_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count)
{
    int level=0;
    parameters level_params = params;
    cout << params.current_epoch_count << endl;
    sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
    cout << level_params.output_dir << endl;
    countSketch_level[level].sketch_info_file_print(level_params, sampling_hash);

    string dir_name = string(level_params.output_dir);
    string file_name;
    FILE* fp;
    file_name = dir_name + "entropy.txt";
    fp = fopen(file_name.c_str(), "w");
    fprintf(fp, "%.20f\n", entropy);
    fclose(fp);

    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec.file_print(new_params, "/ground_truth.txt", line_count);

    KeyValueVector kv_vec_2(flowkey_tracking, params);
    kv_vec_2.sort_vector();
    parameters new_params_2 = params;
    sprintf(new_params_2.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec_2.file_print(new_params_2, "/flowkey.txt", 0);
}

void fcm_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, map <flowkey_t, int> &flowkey_topk, int line_count)
{
    
    for(int level=0; level<=1; level++) {
        parameters level_params = params;
        sprintf(level_params.output_dir, "%s%02d/level_%02d/", params.output_dir, params.current_epoch_count, level);
        cout << level_params.output_dir << endl;
        countSketch_level[level].sketch_info_file_print(level_params, sampling_hash);
    }

    KeyValueVector kv_vec(packetMap, params);
    kv_vec.sort_vector();
    parameters new_params = params;
    sprintf(new_params.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec.file_print(new_params, "/ground_truth.txt", line_count);

    KeyValueVector kv_vec_2(flowkey_tracking, params);
    kv_vec_2.sort_vector();
    parameters new_params_2 = params;
    sprintf(new_params_2.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec_2.file_print(new_params_2, "/flowkey.txt", 0);

    KeyValueVector kv_vec_3(flowkey_topk, params);
    kv_vec_3.sort_vector();
    parameters new_params_3 = params;
    sprintf(new_params_3.output_dir, "%s%02d/", params.output_dir,  params.current_epoch_count);
    kv_vec_3.file_print(new_params_3, "/flowkey_topk.txt", 0);
}
