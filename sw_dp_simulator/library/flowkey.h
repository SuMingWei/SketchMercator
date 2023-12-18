#ifndef FLOWKEY_H
#define FLOWKEY_H

#include <iostream>
#include <string.h>
#include <stdio.h>
#include "params.h"

using namespace std;


void parse_key_flags(parameters &params);
void print_flowkey_flags(flowkey_flags_t &flowkey_flags);

void get_flowkey(flowkey_t &flowkey, packet_summary &packet, parameters &params);
void print_flowkey(flowkey_t &flowkey);

#endif // FLOWKEY_H
