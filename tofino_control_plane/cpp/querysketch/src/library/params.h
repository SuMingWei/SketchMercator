#ifndef LIBRARY_PARAMS
#define LIBRARY_PARAMS

#include <iostream>
#include <stdio.h>
#include <vector>
#include <tuple>
#include <map>

using namespace std;

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

class Connection;

struct parameters
{
    uint32_t switch_ip;
    char* workload_name;
    char* program_name;
    char* before_after;

    char msg[500];

    char pcap_name[500];
    char op[500];
    char date[500];
    Connection* connection;

    // epoch packet counting
    const bfrt::BfRtTable *register_index_table;

    // resource configuration for both before/after
    int d_count;
    vector<tuple<int, int, int, int, int, int, int>> resource_param_vec;

    vector<int> read_signal_list;
    vector<int> reset_signal_list;
    vector<int> write_signal_list;

    vector<vector<const bfrt::BfRtTable *>> table_list;
    vector<vector< tuple<int, int, string, string> >> info_list;

    map<pair<int, int>, vector<int>> cache_map;




    int after_hkey_count;
    int after_HT_SIZE;
    // table_list / info_list
        // before
            // each entry has both counter array / heavy flowkey information
        // after
            // each entry has only counter array information
            // last entry has information for merged heavy flowkey

    
    int e_count;
    int row;
};



#include "common/connection.h"

void print_params(parameters &params);

#endif // LIBRARY_PARAMS
