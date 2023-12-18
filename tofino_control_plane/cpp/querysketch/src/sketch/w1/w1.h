#ifndef SKETCH_W1
#define SKETCH_W1

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

class W1 : public Connection {
public:
    W1();

    virtual void init(parameters &params);
    virtual void table_init(parameters &params);
    virtual void sketch_main_loop(parameters &params, int e_count);
};

#endif // SKETCH_W1
