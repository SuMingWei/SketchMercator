#ifndef __MAIN_LOOP_H
#define __MAIN_LOOP_H

#include <iostream>
#include <vector>

#include <stdio.h>
#include <string.h>

#include "library/timer.h"
#include "library/pcap_helper.h"
#include "sketches/sketch_iteration_template.h"
#include "library/params.h"

void main_loop(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance);

void main_loop_pcount(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance);

void main_loop_sketchmd(parameters &params, vector<packet_summary> &packet_stream, sketchIterationTemplate* sketch_iteration_instance);

#endif
