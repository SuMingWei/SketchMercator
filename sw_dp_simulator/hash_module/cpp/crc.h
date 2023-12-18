#ifndef CRC_H
#define CRC_H

#include <iostream>
#include <vector>
#include <map>
#include <unordered_map>

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <string.h>

#include "library/params.h"

using namespace std;

uint32_t crc_general(void* buf, int len, uint32_t poly, uint32_t init, uint32_t x_out);

#endif // CRC_H
