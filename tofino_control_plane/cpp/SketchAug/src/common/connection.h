#ifndef COMMON_CONNECTION
#define COMMON_CONNECTION

#include <iostream>
#include <stdio.h>
#include <pcap.h>
#include <arpa/inet.h>

#include <bf_rt/bf_rt_info.hpp>
#include <bf_rt/bf_rt_init.hpp>
#include <bf_rt/bf_rt_common.h>
#include <bf_rt/bf_rt_table_key.hpp>
#include <bf_rt/bf_rt_table_data.hpp>
#include <bf_rt/bf_rt_table_attributes.hpp>
#include <bf_rt/bf_rt_table.hpp>
#include <bf_rt/bf_rt_table_operations.hpp>

#ifdef __cplusplus
extern "C"
{
#endif

#include <bf_switchd/bf_switchd.h>
#include <bfutils/bf_utils.h> // required for bfshell

#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
extern "C"
{
#endif
#include <bf_switchd/bf_switchd.h>
#include <lld/bf_ts_if.h>
#include <pkt_mgr/pkt_mgr_intf.h>
#include <port_mgr/bf_port_if.h>
#ifdef __cplusplus
}
#endif

#define THRIFT_PORT_NUM 7777
#define ALL_PIPES 0xffff

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

#include "library/params.h"
#include "library/timer.h"
#include "bf_library/register.h"
#include "library/file.h"

using namespace std;

class Connection {
public:
    const bfrt::BfRtInfo *bfrtInfo = nullptr;
    uint32_t g_switch_ip;
    bf_pkt *tx_pkt = NULL;
	bf_rt_target_t dev_tgt;

    virtual void init(parameters &params);
    virtual void test(parameters &params) {}
    virtual void table_init(parameters &params);
    virtual void sketch_main_loop(parameters &params, int e_count);
    virtual void setup_pingpong(parameters &params, int e_count) {}
    virtual void file_print_single_row(parameters &params, vector<int> &data);
    virtual void file_print_multiple_rows(parameters &params, vector<int> &data1, vector<int> &data2, vector<int> &data3, vector<int> &data4);
};

#endif // COMMON_CONNECTION
