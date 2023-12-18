#ifndef __STRING_H

#define __STRING_H

#include <string>
#include "params.h"

using namespace std;

void add_padding(string &temp, string str, int n);
void parse_delays(char* delay_str, parameters& params);

#endif
