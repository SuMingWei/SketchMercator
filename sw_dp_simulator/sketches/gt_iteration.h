#ifndef GROUND_TRUTH_H
#define GROUND_TRUTH_H

#include <vector>
#include <iostream>
#include <map>

#include <stdio.h>

#include "library/params.h"
#include "library/flowkey.h"
#include "library/pcap_helper.h"
#include "file_io/cpp/sw_simulator/file_print.h"
#include "sketch_iteration_template.h"

using namespace std;

class gtIteration : public sketchIterationTemplate {
public:

    map <flowkey_t, int> packetMap;

    gtIteration();
    void init(parameters &params);
    void load_hash(parameters &params);
    void iteration(packet_summary &p, parameters &params);
    void file_print(parameters &params);
    void clear(parameters &params);
};

#endif // GROUND_TRUTH_H
