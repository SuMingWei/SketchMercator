#ifndef MRAC_ITERATION_H
#define MRAC_ITERATION_H

#include <vector>
#include <iostream>

#include <stdio.h>

#include "sketch_iteration_template.h"

#include "library/params.h"
#include "library/flowkey.h"
#include "library/pcap_helper.h"
#include "library/timer.h"
#include "library/priority_queue.h"
#include "library/sketch_template.h"

#include "hash_module/cpp/crc.h"
#include "hash_module/cpp/hash.h"
#include "hash_module/cpp/seed.h"
#include "file_io/cpp/sw_simulator/file_print.h"

using namespace std;

class mracIteration : public sketchIterationTemplate {
public:

    map <flowkey_t, int> packetMap;
    map <flowkey_t, int> flowkey_tracking; // this is heavy flowkey tracking

//    HashSeedSet sampling_hash(25);

    int threshold[100];

    HashSeedSet *sampling_hash;
    vector<sketchTemplate> cm_level;
    // vector<PriorityQueue> level_PQ_top200;
    mracIteration();
    void init(parameters &params);
    void load_hash(parameters &params);
    void iteration(packet_summary &p, parameters &params);
    void file_print(parameters &params);
    void clear(parameters &params);
};

#endif // MRAC_ITERATION_H
