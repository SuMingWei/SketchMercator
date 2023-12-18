#include "params.h"

void print_params(parameters &params)
{
    printf("\t[print_params]\n");
    printf("\t1-1. input_pcap_file_name = %s\n", params.pcap_file_path);
    printf("\t1-2. key = %s\n", params.key);
    printf("\t1-3. is_count_packet = %d\n", params.is_count_packet);
//    m_printf("1-4. bin_time(second) = %d\n", params.bin_time);
    printf("\n");
    printf("\t3-1. topk_heavy_hitter = %d\n", params.topk_heavy_hitter);
    printf("\t3-2. depth = %d\n", params.depth);
    printf("\t3-3. width = %d\n", params.width);
    printf("\t3-4. level = %d\n", params.level);
    printf("\t\n");

//    printf("3-1. output_dir = %s\n", params.output_dir);
//    printf("\n");
}

void generate_string_key(string &key, flowkey_t flowkey, parameters &params)
{
    char buffer[10];

    int flag = 0;

    string temp;

    key = "(";

    if(params.flowkey_flags.srcIP == 1) {
        flag = 1;
        key += "srcIP = ";
//        add_padding(temp, to_string(flowkey.src_addr), 16);
        char buf[32];
        get_ip_char_from_int(buf, flowkey.src_addr);
        add_padding(temp, string(buf), 16);
        key += temp;
    }

    if(params.flowkey_flags.srcPort == 1) {
        if(flag == 1) key += " | ";
        flag = 1;
        key += "srcPort = ";

        sprintf(buffer, "%d", flowkey.src_port);

        add_padding(temp, string(buffer), 5);
        key += temp;
    }

    if(params.flowkey_flags.dstIP == 1) {
        if(flag == 1) key += " | ";
        flag = 1;
        key += "dstIP = ";
//        add_padding(temp, to_string(flowkey.dst_addr), 16);
        char buf[32];
        get_ip_char_from_int(buf, flowkey.dst_addr);
        add_padding(temp, string(buf), 16);
        key += temp;
    }

    if(params.flowkey_flags.dstPort == 1) {
        if(flag == 1) key += " | ";
        flag = 1;
        key += "dstPort = ";

        sprintf(buffer, "%d", flowkey.dst_port);

        add_padding(temp, string(buffer), 5);
        key += temp;
    }

    if(params.flowkey_flags.proto == 1) {
        if(flag == 1) key += " | ";
        flag = 1;
        key += "proto = ";

        sprintf(buffer, "%d", flowkey.proto);

        add_padding(temp, string(buffer), 3);
        key += temp;
    }

    key += ")";
//    cout << key << endl;
}

// file related

void generate_common_param_string(string &str, parameters &params)
{
    str = "";

    // int i=0;
    for(uint32_t i=0; i<strlen(params.pcap_file_name); i++) {
        if(params.pcap_file_name[i] == '/')
            str += "_";
        else
            str += params.pcap_file_name[i];
    }
//    str += "/";
//    str += "__k__";
//    str += params.key;
}

void generate_univmon_param_string(string &str, parameters &params)
{
    char buffer[10];

    str = "";

    str += "__t__";
    sprintf(buffer, "%d", params.topk_heavy_hitter);
    str += string(buffer);

    str += "__w__";
    sprintf(buffer, "%d", params.width);
    str += string(buffer);

    str += "__d__";
    sprintf(buffer, "%d", params.depth);
    str += string(buffer);

    str += "__l__";
    sprintf(buffer, "%d", params.level);
    str += string(buffer);
//
//    str += "__k__";
//    str += params.key;

}
//
//void set_ground_truth_dir(parameters &params)
//{
//    string dir_name = "";
//
//    for(int i=0; i<strlen(params.output_folder_arg); i++) {
//        dir_name += params.output_folder_arg[i]; // -o argument
//    }
//    dir_name += "/";
//
//    dir_name += string(params.key) + "/"; // -k argument
//
//    string common_name;
//    generate_common_param_string(common_name, params);  // pcap_name
//    dir_name += common_name + "/";
//
//    sprintf(params.output_dir, "%s", dir_name.c_str());
//    // ../_05_result/gt_result/srcIP,dstIP/equinix-sanjose.dirA.20140320-130000.UTC.anon.pcap/
//}
//
//void set_univmon_dir(parameters &params)
//{
//    string dir_name = "";
//
//    for(int i=0; i<strlen(params.output_folder_arg); i++) {
//        dir_name += params.output_folder_arg[i]; // -o argument
//    }
//    dir_name += "/";
//
//    dir_name += string(params.key) + "/"; // -k argument
//
//    dir_name += string(params.hash_seed_name) + "/"; // seed
//
//    string univmon_name;
//    generate_univmon_param_string(univmon_name, params);  // sketch parameter name, __t__200__w__2048__d__5__l__16
//    dir_name += univmon_name + "/";
//
//    if(params.is_crc_hash == 0) {
//        dir_name += "basic_hash/";
//    }
//    else {
//        dir_name += "crc_hash/";
//    }
//
//    if(params.is_compact_hash == 0) {
//        dir_name += "no_compact_hash/";
//    }
//    else {
//        dir_name += "compact_hash/";
//    }
//
//    if(params.is_same_level_hash == 0) {
//        dir_name += "no_reuse_hash/";
//    }
//    else {
//        dir_name += "reuse_hash/";
//    }
//
//    if(params.is_update_last_level == 0) {
//        dir_name += "update_all_level/";
//    }
//    else {
//        dir_name += "update_last_level/";
//    }
//
//    string common_name;
//    generate_common_param_string(common_name, params);
//    dir_name += common_name + "/";
//
//    sprintf(params.output_dir, "%s", dir_name.c_str());
//    // ../_05_result/dataplane_result/srcIP,dstIP/01.txt/__t__200__w__2048__d__5__l__16/crc_hash/no_compact_hash/no_reuse_hash/update_all_level/equinix-sanjose.dirA.20140320-130000.UTC.anon.pcap/
//}
