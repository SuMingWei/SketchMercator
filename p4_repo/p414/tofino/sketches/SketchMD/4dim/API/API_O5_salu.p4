#define CM_WIDTH_BITLEN 10
#define CM_WIDTH 1024

#define CM_ROW_SKETCH(D, R, FLOWKEY) \
    field_list_calculation cm_index_hash_func_##D##_##R { \
        input { \
            FLOWKEY; \
        } \
        algorithm : poly_0x11e1##D##a##R##19_init_0x00000000_xout_0ffffffff; \
        output_width : CM_WIDTH_BITLEN; \
    } \
    register  cm_register_##D##_##R { \
        width: 32; \
        instance_count: CM_WIDTH; \
    } \
    blackbox stateful_alu cm_blackbox_##D##_##R { \
        reg: cm_register_##D##_##R; \
        update_lo_1_value    : register_lo+1;  \
        update_hi_1_value    : register_lo+1; \
        output_value: alu_hi; \
        output_dst: cm_md_##D##.est_##R; \
    } \
    table cm_sketching_##D##_##R##_table { \
        actions { \
            cm_sketching_##D##_##R##_act; \
        } \
        default_action: cm_sketching_##D##_##R##_act; \
    } \
    action cm_sketching_##D##_##R##_act () { \
        cm_blackbox_##D##_##R.execute_stateful_alu_from_hash(cm_index_hash_func_##D##_##R); \
    }

#define KARY_WIDTH_BITLEN 10
#define KARY_WIDTH 1024

#define KARY_ROW_SKETCH(D, R, FLOWKEY) \
    field_list_calculation kary_index_hash_func_##D##_##R { \
        input { \
            FLOWKEY; \
        } \
        algorithm : poly_0x11e1##D##a##R##19_init_0x00000000_xout_0ffffffff; \
        output_width : KARY_WIDTH_BITLEN; \
    } \
    register  kary_register_##D##_##R { \
        width: 32; \
        instance_count: KARY_WIDTH; \
    } \
    blackbox stateful_alu kary_blackbox_##D##_##R { \
        reg: kary_register_##D##_##R; \
        update_lo_1_value    : register_lo+1;  \
        update_hi_1_value    : register_lo+1; \
        output_value: alu_hi; \
        output_dst: kary_md_##D##.est_##R; \
    } \
    table kary_sketching_##D##_##R##_table { \
        actions { \
            kary_sketching_##D##_##R##_act; \
        } \
        default_action: kary_sketching_##D##_##R##_act; \
    } \
    action kary_sketching_##D##_##R##_act () { \
        kary_blackbox_##D##_##R.execute_stateful_alu_from_hash(kary_index_hash_func_##D##_##R); \
    }

#define HLL_WIDTH_BITLEN 10
#define HLL_WIDTH 1024

#define HLL_SKETCH(D, FLOWKEY, LEVEL) \
    field_list_calculation hll_index_hash_func_##D { \
        input { \
            FLOWKEY; \
        } \
        algorithm : poly_0x11e1##D##a119_init_0x00000000_xout_0ffffffff; \
        output_width : HLL_WIDTH_BITLEN; \
    } \
    register  hll_register_##D { \
        width: 32; \
        instance_count: HLL_WIDTH; \
    } \
    blackbox stateful_alu hll_blackbox_##D { \
        reg: hll_register_##D; \
        condition_lo: LEVEL > register_lo; \
        update_lo_1_predicate: condition_lo; \
        update_lo_1_value    : LEVEL;  \
    } \
    table hll_sketching_##D##_table { \
        actions { \
            hll_sketching_##D##_act; \
        } \
        default_action: hll_sketching_##D##_act; \
    } \
    action hll_sketching_##D##_act () { \
        hll_blackbox_##D.execute_stateful_alu_from_hash(hll_index_hash_func_##D); \
    }

#define consolidate_update_cs_init(NAME, BASE, INDEX, RES, EST, SIZE) \
	table NAME##_add_base_table { \
	    actions { \
	        NAME##_add_base_table_act; \
	    } \
	    default_action: NAME##_add_base_table_act; \
	} \
	action NAME##_add_base_table_act () { \
        add_to_field(INDEX, BASE); \
	} \
    register  NAME##_register { \
        width: 32; \
        instance_count: SIZE; \
    } \
    blackbox stateful_alu NAME##_salu { \
        reg: NAME##_register; \
        condition_lo: RES > 0; \
        update_lo_1_predicate: condition_lo;     /* if (res == 0)  */ \
        update_lo_1_value    : register_lo + 1; \
        update_lo_2_predicate: not condition_lo; /* else */ \
        update_lo_2_value    : register_lo - 1; \
        condition_hi: RES > 0; \
        update_hi_1_predicate: condition_hi;     /* if   */ \
        update_hi_1_value    : register_lo + 1; \
        update_hi_2_predicate: not condition_hi; /* else */ \
        update_hi_2_value    : ~register_lo; \
        output_value: alu_hi; \
        output_dst: EST; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        NAME##_salu.execute_stateful_alu(INDEX); \
    }

#define consolidate_update_cs_call(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_update_table);




#define consolidate_update_mrac_init(NAME, BASE, INDEX, SIZE) \
	table NAME##_add_base_table { \
	    actions { \
	        NAME##_add_base_table_act; \
	    } \
	    default_action: NAME##_add_base_table_act; \
	} \
	action NAME##_add_base_table_act () { \
        add_to_field(INDEX, BASE); \
	} \
    register  NAME##_register { \
        width: 32; \
        instance_count: SIZE; \
    } \
    blackbox stateful_alu NAME##_salu { \
        reg: NAME##_register; \
        update_lo_1_value    : register_lo + 1; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        NAME##_salu.execute_stateful_alu(INDEX); \
    }

#define consolidate_update_mrac_call(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_update_table);





#define consolidate_update_mrb_init(NAME, BASE, INDEX, SIZE) \
	table NAME##_add_base_table { \
	    actions { \
	        NAME##_add_base_table_act; \
	    } \
	    default_action: NAME##_add_base_table_act; \
	} \
	action NAME##_add_base_table_act () { \
        add_to_field(INDEX, BASE); \
	} \
    register  NAME##_register { \
        width: 1; \
        instance_count: SIZE; \
    } \
    blackbox stateful_alu NAME##_salu { \
        reg: NAME##_register; \
        update_lo_1_value    : 1; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        NAME##_salu.execute_stateful_alu(INDEX); \
    }

#define consolidate_update_mrb_call(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_update_table);






#define consolidate_update_ss_init(NAME, BASE, XYHASH, INDEX, SIZE) \
	table NAME##_add_base_table { \
	    actions { \
	        NAME##_add_base_table_act; \
	    } \
	    default_action: NAME##_add_base_table_act; \
	} \
	action NAME##_add_base_table_act () { \
        add_to_field(INDEX, BASE); \
	} \
	table NAME##_add_base_table_2 { \
	    actions { \
	        NAME##_add_base_table_2_act; \
	    } \
	    default_action: NAME##_add_base_table_2_act; \
	} \
	action NAME##_add_base_table_2_act () { \
        add_to_field(INDEX, XYHASH); \
	} \
    register  NAME##_register { \
        width: 1; \
        instance_count: SIZE; \
    } \
    blackbox stateful_alu NAME##_salu { \
        reg: NAME##_register; \
        update_lo_1_value    : 1; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        NAME##_salu.execute_stateful_alu(INDEX); \
    }

#define consolidate_update_ss_call(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_add_base_table_2); \
    apply(NAME##_update_table);





#define consolidate_update_ss_update_init(NAME, INDEX, VAL, SIZE) \
    register  NAME##_register { \
        width: 32; \
        instance_count: SIZE; \
    } \
    blackbox stateful_alu NAME##_salu { \
        reg: NAME##_register; \
        update_lo_1_value    : VAL; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        NAME##_salu.execute_stateful_alu(INDEX); \
    }

#define consolidate_update_ss_update_call(NAME) \
    apply(NAME##_update_table_act); \
