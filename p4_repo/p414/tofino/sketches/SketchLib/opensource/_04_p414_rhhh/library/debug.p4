#define DEBUG_TEST(NAME, MD, FIELD) \
	register debug_reg_##NAME { \
	    width: 32; \
	    instance_count: 16; \
	} \
	blackbox stateful_alu debug_blackbox_##NAME { \
	    reg: debug_reg_##NAME; \
	    update_lo_1_value:MD.FIELD; \
	} \
	table debug_blackbox_##NAME##_table { \
	    actions { \
	        debug_blackbox_##NAME##_act; \
	    } \
	    default_action:debug_blackbox_##NAME##_act; \
	} \
	action debug_blackbox_##NAME##_act() { \
	    debug_blackbox_##NAME.execute_stateful_alu(0); \
	}

#define DEBUG() \
	DEBUG_TEST(ipv4, ipv4, srcAddr) \
	DEBUG_TEST(shash, md_1, sampling_hash_value) \
	DEBUG_TEST(level, md_1, level) \
	DEBUG_TEST(res_1, md_1, res_1) \
	DEBUG_TEST(res_2, md_1, res_2) \
	DEBUG_TEST(res_3, md_1, res_3) \
	DEBUG_TEST(res_4, md_1, res_4) \
	DEBUG_TEST(res_5, md_1, res_5) \
	DEBUG_TEST(index_1, md_1, index_1) \
	DEBUG_TEST(index_2, md_1, index_2) \
	DEBUG_TEST(index_3, md_1, index_3) \
	DEBUG_TEST(index_4, md_1, index_4) \
	DEBUG_TEST(index_5, md_1, index_5) \
	DEBUG_TEST(est_1, md_1, est_1) \
	DEBUG_TEST(est_2, md_1, est_2) \
	DEBUG_TEST(est_3, md_1, est_3) \
	DEBUG_TEST(est_4, md_1, est_4) \
	DEBUG_TEST(est_5, md_1, est_5) \



DEBUG()



	// DEBUG_TEST(comp_1, md_1, comp_1) \
	// DEBUG_TEST(comp_2, md_1, comp_2) \
	// DEBUG_TEST(comp_3, md_1, comp_3) \
	// DEBUG_TEST(comp_4, md_1, comp_4) \
	// DEBUG_TEST(comp_5, md_1, comp_5) \
	// DEBUG_TEST(above_threshold, md_1, above_threshold) \
	// DEBUG_TEST(hash_entry, md_1, hash_entry) \
	// DEBUG_TEST(match_hit, md_1, match_hit)
