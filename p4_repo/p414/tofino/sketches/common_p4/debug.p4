#define DEBUG_TEST(name, md, field) \
	register debug_reg_##name { \
	    width: 32; \
	    instance_count: 16; \
	} \
	blackbox stateful_alu debug_blackbox_##name { \
	    reg: debug_reg_##name; \
	    update_lo_1_value:md.field; \
	} \
	table debug_blackbox_##name##_table { \
	    actions { \
	        debug_blackbox_##name##_act; \
	    } \
	    default_action:debug_blackbox_##name##_act; \
	} \
	action debug_blackbox_##name##_act() { \
	    debug_blackbox_##name.execute_stateful_alu(0); \
	}

#define DEBUG() \
	DEBUG_TEST(ipv4, ipv4, srcAddr) \
	DEBUG_TEST(shash, md, sampling_hash_value) \
	DEBUG_TEST(lastlevel, md, lastlevel) \
	DEBUG_TEST(index_0, md, index_0) \
	DEBUG_TEST(index_1, md, index_1) \
	DEBUG_TEST(index_2, md, index_2) \
	DEBUG_TEST(index_3, md, index_3) \
	DEBUG_TEST(res_0, md, res_0) \
	DEBUG_TEST(res_1, md, res_1) \
	DEBUG_TEST(res_2, md, res_2) \
	DEBUG_TEST(res_3, md, res_3)
