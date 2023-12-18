#ifndef SKETCH_HLL
#define SKETCH_HLL

#include <vector>
#include <iostream>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <sched.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <unistd.h>
#include <pcap.h>
#include <arpa/inet.h>

#include "common/connection.h"
#include "bf_library/register.h"
#include "library/params.h"
#include "library/timer.h"
#include "library/com.h"

using namespace std;

class HLL : public Connection {
public:
    HLL();

    virtual void init(parameters &params);
    virtual void test(parameters &params);
    virtual void table_init(parameters &params);
    virtual void setup_pingpong(parameters &params, int e_count);
};

#endif // SKETCH_CS
