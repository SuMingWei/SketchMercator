#ifndef LIBRARY_PARAMS
#define LIBRARY_PARAMS

#include <iostream>
#include <stdio.h>

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
    char* test_name;
    char* sketch_name;

    char* str_args_1;

    int is_simulator;
    char test_type[500];
    char date[500];
    int int_args_1;
    // int int_args_2;

    char program_name[500];
    char mode[500]; // baseline, pingpong, noreset, sol3
    char pcap_name[500]; // read
    char op[500]; // read
    int epoch;
    int array_size;
    int counter_size;
    int size;
    int e_count;

    Connection* connection;

    const bfrt::BfRtTable *register_table_1;
    const bfrt::BfRtTable *register_table_2;
    const bfrt::BfRtTable *register_table_3;
    const bfrt::BfRtTable *register_table_4;
    const bfrt::BfRtTable *register_table_5;
    const bfrt::BfRtTable *register_table_6;

    char data_field_name_1[1000];
    char data_field_name_2[1000];
    char data_field_name_3[1000];
    char data_field_name_4[1000];
    char data_field_name_5[1000];
    char data_field_name_6[1000];
};



#include "common/connection.h"

void print_params(parameters &params);

#endif // LIBRARY_PARAMS
