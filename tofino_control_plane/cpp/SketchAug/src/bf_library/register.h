#ifndef BF_LIBRARY_REGISTER
#define BF_LIBRARY_REGISTER

#include <stdint.h>
#include <iostream>
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

#include "library/params.h"

using namespace std;

uint64_t read_point(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, char* data_field_name, bf_rt_id_t &reg_index_key_id, uint64_t key, bfrt::BfRtTable::BfRtTableGetFlag flag);
void reset_point(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, char* data_field_name, bf_rt_id_t &reg_index_key_id, uint64_t key);
void write_point(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, char* data_field_name, bf_rt_id_t &reg_index_key_id, uint64_t key, uint64_t valueq);
void read_whole(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, bfrt::BfRtTable::BfRtTableGetFlag flag, int array_size, char* data_field_name, vector<int> &data);
void reset_whole(const bfrt::BfRtTable *register_table, bf_rt_target_t &dev_tgt, int array_size, char* data_field_name);

#endif // BF_LIBRARY_REGISTER

