#ifndef HASH_H
#define HASH_H

#include <ctime>
#include <cstdlib>
#include <vector>
#include <functional>
#include <string>
#include <iostream>

#include "library/pcap_helper.h"
#include "library/params.h"
#include "hash_module/cpp/crc.h"

using namespace std;

//enum HashType {
//    crc_tofino_hash,
//    universal_hash
//};

//void generate_key(key_value_elem &key_e, packet_summary &p, parameters &params);
//void generate_rhhh_key(key_value_elem &key_e, packet_summary &p, parameters &params);
//bool key_compare(key_value_elem &key_a, key_value_elem &key_b);

class HashSeedSet {
public:

    uint64_t primeNumber = 39916801;
    uint32_t size;

    vector<uint32_t> aParams;
    vector<uint32_t> bParams;

    vector<uint32_t> polyParams;
    vector<uint32_t> initParams;
    vector<uint32_t> xoutParams;

    HashSeedSet(uint32_t _size);

    void printParams();
    void filePrintParams(FILE* fp, int i);
    uint32_t compute_hash(flowkey_t flowkey, flowkey_flags_t flowkey_flags, int index, int is_crc, int range);

    uint32_t crc_hash(flowkey_t flowkey, flowkey_flags_t flowkey_flags, uint32_t poly, uint32_t init, uint32_t xout);
    uint32_t universal_hash(flowkey_t flowkey, uint32_t a, uint32_t b, int range);

    uint32_t compute_hash_xor_type(flowkey_t flowkey, flowkey_flags_t flowkey_flags, int index, int is_crc, int range, int xor_hash_type);
    uint32_t compute_hash_xor_type_two(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, int index, int range);
    uint32_t compute_hash_xor_type_three(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, flowkey_flags_t flowkey_flags_3, int index, int range);
    uint32_t compute_hash_xor_type_four(flowkey_t flowkey, flowkey_flags_t flowkey_flags_1, flowkey_flags_t flowkey_flags_2, flowkey_flags_t flowkey_flags_3, flowkey_flags_t flowkey_flags_4, int index, int range);


};

#endif
