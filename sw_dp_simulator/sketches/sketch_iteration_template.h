
#ifndef SKETCH_ITERATION_TEMPLATE_H
#define SKETCH_ITERATION_TEMPLATE_H

#include "library/pcap_helper.h"
#include "library/params.h"

class sketchIterationTemplate {
public:
    virtual void init(parameters &params) {}
    virtual void load_hash(parameters &params) {}
    virtual void iteration(packet_summary &p, parameters &params) {}
    virtual void file_print(parameters &params) {}
    virtual void clear(parameters &params) {}
};

int get_last_level(uint32_t sampling_hash, int level);

#endif // SKETCH_ITERATION_TEMPLATE_H
