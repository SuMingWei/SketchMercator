#ifndef LC_H
#define LC_H

#include <vector>
#include <iostream>
#include <map>

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

class lcIteration : public sketchIterationTemplate {
public:

    map <flowkey_t, int> packetMap;

    HashSeedSet *sampling_hash;
    vector<sketchTemplate> lc_level;
    lcIteration();

    void init(parameters &params);
    void load_hash(parameters &params);
    void iteration(packet_summary &p, parameters &params);
    void file_print(parameters &params);
    void clear(parameters &params);

};

#endif // LC_H
