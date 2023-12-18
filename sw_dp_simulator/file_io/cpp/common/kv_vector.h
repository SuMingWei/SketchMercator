#ifndef KV_VECTOR_H
#define KV_VECTOR_H

#include <iostream>
#include <map>
#include <algorithm>
#include <vector>
#include <string>

#include <stdio.h>
#include <inttypes.h>

#include "library/params.h"
#include "library/priority_queue.h"

using namespace std;

struct kv_elem {
    flowkey_t flowkey;
    string string_flowkey;
    int value;
};
struct kv_cmp {
    bool operator()(kv_elem a, kv_elem b) {
        return a.value > b.value;
    }
};

class KeyValueVector {
public:
    vector<kv_elem> vec;
    KeyValueVector(map <flowkey_t, int> &packetMap, parameters &params);
    KeyValueVector(PriorityQueue &pq, parameters &params);
    void sort_vector();
    void file_print(parameters &params, string fn, int line_count);
//    KeyValueTable();
//    KeyValueTable(map <string, int> packetMap);
//    KeyValueTable(map <uint32_t, int> packetMap);
//
//    void load(map <string, int> packetMap);
//    void clear();
//    void load_int(map <uint32_t, int> packetMap);
//    void sort_table();
//    void print_table(int line_count);
//    void file_print_table(int line_count, parameters &params);
//    void file_print_table_extend(int line_count, struct parameters &params, string folder_name, string file_name);
//    void file_print_table_with_hash(int line_count, parameters &params);
//    void file_print_table_with_index_res(parameters &params, countSketch &cs);

};

#endif // KV_VECTOR_H
