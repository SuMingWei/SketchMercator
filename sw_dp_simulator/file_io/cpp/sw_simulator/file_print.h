#ifndef FILE_PRINT_H
#define FILE_PRINT_H

#include <map>
#include <vector>

#include "library/params.h"
#include "library/priority_queue.h"
#include "library/sketch_template.h"
#include "file_io/cpp/common/kv_vector.h"

void gt_file_print(map <flowkey_t, int> &packetMap, parameters &params, int line_count);
void univmon_file_print(vector<sketchTemplate> countSketch_level, vector<PriorityQueue> level_PQ_top200, HashSeedSet &sampling_hash, parameters &params, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count);
void mrac_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count);
void cs_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, uint64_t f2, map <flowkey_t, int> &packetMap, int line_count);
void cm_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, double entropy, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, int line_count);
void fcm_file_print(vector<sketchTemplate> countSketch_level, HashSeedSet &sampling_hash, parameters &params, map <flowkey_t, int> &packetMap, map <flowkey_t, int> &flowkey_tracking, map <flowkey_t, int> &flowkey_topk, int line_count);
void mrb_file_print(vector<sketchTemplate>  mrb_level, HashSeedSet &sampling_hash, parameters &params, int cardinality);
void hll_file_print(vector<sketchTemplate> hll_level, HashSeedSet &sampling_hash, parameters &params, int cardinality);
void lc_file_print(vector<sketchTemplate> lc_level, HashSeedSet &sampling_hash, parameters &params, int cardinality);

#endif // FILE_PRINT_H
