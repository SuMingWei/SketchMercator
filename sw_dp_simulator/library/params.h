#ifndef __PARAMS_H

#define __PARAMS_H

#include <iostream>

#include <stdio.h>
#include <string.h>

#include "pcap_helper.h"
#include "sys/sys.h"

using namespace std;

class MyHashFunction {
public:
    size_t operator()(const flowkey_t& key) const
    {
        return (std::hash<uint32_t>()(key.src_addr) ^
                std::hash<uint32_t>()(key.dst_addr) ^
                std::hash<uint16_t>()(key.src_port) ^
                std::hash<uint16_t>()(key.dst_port) ^
                std::hash<uint8_t>()(key.proto));
    }
};

struct flowkey_flags_t
{
    int srcIP;
    int srcPort;
    int dstIP;
    int dstPort;
    int proto;
};

struct parameters
{
	// common parameters
	char pcap_file_path[5000];
	char key[5000];
	int is_count_packet;
//    char window_bin_size[100];
    char output_folder_arg[5000];
    char pcap_file_name[5000];
    int epoch;

    // univmon specific
    int topk_heavy_hitter;
	int depth;
	int width;
	int level;

    int seed;
    int xor_hash_type;

    int is_count_sketch;
    int is_count_min;
	int is_update_last_level;
    int is_same_level_hash;
    int is_crc_hash;
	int is_compact_hash;
    int is_hardware;
    int sketch_aug_delay_ms;
    int is_hardware_pcount;

    // exp output parameters
    char hash_seed_name[5000];
    char run_info[5000];
	char output_dir[5000];
	char pcount_dir[5000];

    int threshold;

    flowkey_flags_t flowkey_flags;
    int current_epoch_count;
};

#include "string_lib.h"

void print_params(parameters &params);
void generate_string_key(string &key, flowkey_t flowkey, parameters &params);

// file related
void generate_common_param_string(string &str, parameters &params);
void generate_univmon_param_string(string &str, parameters &params);

//void set_ground_truth_dir(parameters &params);
//void set_univmon_dir(parameters &params);

#endif
