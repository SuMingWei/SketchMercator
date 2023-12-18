#include "file_path.h"

void set_dir(parameters &params)
{
    string dir_name = "";

    for(int i=0; i<strlen(params.output_folder_arg); i++) {
        dir_name += params.output_folder_arg[i]; // -o argument
    }
    dir_name += "/";
    sprintf(params.output_dir, "%s", dir_name.c_str());
    cout << "[set_dir] " << params.output_dir << endl;
}


void set_hash_seed_name_dir(parameters &params)
{
    string dir_name = "";

    for(int i=0; i<strlen(params.output_folder_arg); i++) {
        dir_name += params.output_folder_arg[i]; // -o argument
    }

    dir_name += "/" + string(params.hash_seed_name) + "/";

    sprintf(params.output_dir, "%s", dir_name.c_str());
    cout << "[set_hash_seed_name_dir] " << params.output_dir << endl;
}


// #include "file_path.h"

// void set_ground_truth_dir(parameters &params)
// {
//     string dir_name = "";

//     for(int i=0; i<strlen(params.output_folder_arg); i++) {
//         dir_name += params.output_folder_arg[i]; // -o argument
//     }
//     dir_name += "/";

//     dir_name += string(params.key) + "/"; // -k argument

//     string common_name;
//     generate_common_param_string(common_name, params);  // pcap_name
//     dir_name += common_name + "/";

//     // dir_name += to_string(params.epoch) + "s/"; // -k argument
//     sprintf(params.output_dir, "%s%02ds/", dir_name.c_str(), params.epoch);
//     // /data1/hun/sketch_home/result_gt/srcIP/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/
// }

// void set_univmon_dir(parameters &params)
// {
//     string dir_name = "";

//     for(int i=0; i<strlen(params.output_folder_arg); i++) {
//         dir_name += params.output_folder_arg[i]; // -o argument
//     }
//     dir_name += "/";

//     dir_name += string(params.key) + "/"; // -k argument

//     dir_name += string(params.hash_seed_name) + "/"; // seed

//     string univmon_name;
//     generate_univmon_param_string(univmon_name, params);  // sketch parameter name, __t__200__w__2048__d__5__l__16
//     dir_name += univmon_name + "/";

//     if(params.is_crc_hash == 0) {
//         dir_name += "universal_hash/";
//     }
//     else {
//         dir_name += "crc_hash/";
//     }

//     if(params.is_compact_hash == 0) {
//         dir_name += "no_compact_hash/";
//     }
//     else {
//         dir_name += "compact_hash/";
//     }

//     if(params.is_same_level_hash == 0) {
//         dir_name += "no_reuse_hash/";
//     }
//     else {
//         dir_name += "reuse_hash/";
//     }

//     if(params.is_update_last_level == 0) {
//         dir_name += "update_all_level/";
//     }
//     else {
//         dir_name += "update_last_level/";
//     }

//     string common_name;
//     generate_common_param_string(common_name, params);
//     dir_name += common_name + "/";

//     // dir_name += to_string(params.epoch) + "s/"; // -k argument

//     sprintf(params.output_dir, "%s%02ds/", dir_name.c_str(), params.epoch);
//     cout << params.output_dir << endl;
//     // ../_05_result/dataplane_result/srcIP,dstIP/01.txt/__t__200__w__2048__d__5__l__16/crc_hash/no_compact_hash/no_reuse_hash/update_all_level/equinix-sanjose.dirA.20140320-130000.UTC.anon.pcap/
// }


// void set_hll_dir(parameters &params)
// {
//     string dir_name = "";

//     for(int i=0; i<strlen(params.output_folder_arg); i++) {
//         dir_name += params.output_folder_arg[i]; // -o argument
//     }

//     dir_name += "/hll/";

//     dir_name += string(params.key) + "/"; // -k argument

//     dir_name += string(params.hash_seed_name) + "/"; // seed

//     string univmon_name;
//     generate_univmon_param_string(univmon_name, params);  // sketch parameter name, __t__200__w__2048__d__5__l__16
//     dir_name += univmon_name + "/";

//     if(params.is_sketch_aug) {
//         dir_name += "sketch_aug/";
//     }
//     else {
//         dir_name += "normal/";
//     }

//     if(params.is_crc_hash == 0) {
//         dir_name += "universal_hash/";
//     }
//     else {
//         dir_name += "crc_hash/";
//     }

//     string common_name;
//     generate_common_param_string(common_name, params);
//     dir_name += common_name + "/";

//     // dir_name += to_string(params.epoch) + "s/"; // -k argument
//     sprintf(params.output_dir, "%s%02ds/", dir_name.c_str(), params.epoch);
//     cout << params.output_dir << endl;
//     // /data1/hun/sketch_home/result_sw_dp/hll/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/
// }

// void set_cs_dir(parameters &params)
// {
//     string dir_name = "";

//     for(int i=0; i<strlen(params.output_folder_arg); i++) {
//         dir_name += params.output_folder_arg[i]; // -o argument
//     }

//     dir_name += "/countsketch/";

//     dir_name += string(params.key) + "/"; // -k argument

//     dir_name += string(params.hash_seed_name) + "/"; // seed

//     string univmon_name;
//     generate_univmon_param_string(univmon_name, params);  // sketch parameter name, __t__200__w__2048__d__5__l__16
//     dir_name += univmon_name + "/";

//     dir_name += to_string(params.problem) + "/";

//     // if(params.is_sketch_aug) {
//     //     dir_name += "sketch_aug/";
//     // }
//     // else {
//     //     dir_name += "normal/";
//     // }

//     if(params.is_crc_hash == 0) {
//         dir_name += "universal_hash/";
//     }
//     else {
//         dir_name += "crc_hash/";
//     }

//     string common_name;
//     generate_common_param_string(common_name, params);
//     dir_name += common_name + "/";

//     // dir_name += to_string(params.epoch) + "s/"; // -k argument
//     sprintf(params.output_dir, "%s%02ds/", dir_name.c_str(), params.epoch);
//     cout << params.output_dir << endl;
//     // /data1/hun/sketch_home/result_sw_dp/countsketch/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/
// }

// void set_mrb_dir(parameters &params)
// {
//     string dir_name = "";

//     for(int i=0; i<strlen(params.output_folder_arg); i++) {
//         dir_name += params.output_folder_arg[i]; // -o argument
//     }

//     dir_name += "/mrb/";

//     if (params.is_hardware == 1) {
//         dir_name += "hardware/";        
//     }

//     dir_name += string(params.key) + "/"; // -k argument

//     dir_name += string(params.hash_seed_name) + "/"; // seed

//     string univmon_name;
//     generate_univmon_param_string(univmon_name, params);  // sketch parameter name, __t__200__w__2048__d__5__l__16
//     dir_name += univmon_name + "/";

//     dir_name += to_string(params.problem) + "/";

//     // if(params.is_sketch_aug) {
//     //     dir_name += "sketch_aug/";
//     // }
//     // else {
//     //     dir_name += "normal/";
//     // }

//     if(params.is_crc_hash == 0) {
//         dir_name += "universal_hash/";
//     }
//     else {
//         dir_name += "crc_hash/";
//     }

//     string common_name;
//     generate_common_param_string(common_name, params);
//     dir_name += common_name + "/";

//     // dir_name += to_string(params.epoch) + "s/"; // -k argument
//     sprintf(params.output_dir, "%s%02ds/", dir_name.c_str(), params.epoch);
//     cout << params.output_dir << endl;
//     // /data1/hun/sketch_home/result_sw_dp/countsketch/srcIP/01.txt/__t__200__w__2048__d__1__l__1/normal/crc_hash/equinix-chicago.dirA.20160121-130000.UTC.anon.pcap/01s/
// }