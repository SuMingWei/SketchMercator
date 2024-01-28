#ifndef SKETCH_TEMPLATE_H
#define SKETCH_TEMPLATE_H

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include <stdlib.h>
#include <math.h>

#include "params.h"
#include "hash_module/cpp/hash.h"

using namespace std;

class sketchTemplate {
public:

    int level;
    int depth;
    int width;

    int* sketchArray;

    int total_counter;

    HashSeedSet *index_hash;
    HashSeedSet *res_hash;

    sketchTemplate(parameters &params, int _level);
    int count_sketch(flowkey_t flowkey, parameters &params, int elem);
    int count_min_sketch(flowkey_t flowkey, parameters &params, int elem);
    int fcm_sketch(flowkey_t flowkey, parameters &params, int elem);
    int get_index_hash(flowkey_t flowkey, parameters &params);

    void hll_sketch(flowkey_t flowkey, parameters &params, int last_level);
    void lc_sketch(flowkey_t flowkey, parameters &params);
    void mrb_sketch(flowkey_t flowkey, parameters &params);

    void sketch_info_file_print(parameters &params, HashSeedSet sampling_hash);
    void counter_info_file_print(parameters &params, string idx);
    void clear();
};

#endif // SKETCH_TEMPLATE_H
