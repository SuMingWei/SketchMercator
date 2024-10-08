#ifndef CS_H
#define CS_H

#include <vector>
#include <iostream>
#include <map>

#include <stdio.h>
#include <math.h>

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

class csIteration : public sketchIterationTemplate {
public:

    map <flowkey_t, int> packetMap;

    HashSeedSet *sampling_hash;
    vector<sketchTemplate> cs_level;
    csIteration();

    void init(parameters &params);
    void load_hash(parameters &params);
    void iteration(packet_summary &p, parameters &params);
    void file_print(parameters &params);
    void clear(parameters &params);
    void counter_file_print(parameters &params, int idx, int window_size);

};

#endif // CS_H
