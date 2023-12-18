#define ENT_WIDTH_BITLEN 10
#define ENT_WIDTH 1024

#define ENT_ROW_SKETCH(D, R, FLOWKEY) \
    field_list_calculation ent_index_hash_func_##D##_##R { \
        input { \
            FLOWKEY; \
        } \
        algorithm : poly_0x11e1##D##a##R##19_init_0x00000000_xout_0ffffffff; \
        output_width : ENT_WIDTH_BITLEN; \
    } \
    register  ent_register_##D##_##R { \
        width: 32; \
        static: ent_sketching_##D##_##R##_table; \
        instance_count: ENT_WIDTH; \
    } \
    table ent_sketching_##D##_##R##_table { \
        actions { \
            ent_sketching_##D##_##R##_act; \
        } \
        default_action: ent_sketching_##D##_##R##_act; \
    } \
    action ent_sketching_##D##_##R##_act () { \
        register_write(ent_register_##D##_##R, 10, ent_md_##D.est_##R); \
    } \


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
        static: cm_sketching_##D##_##R##_table; \
        instance_count: CM_WIDTH; \
    } \
    table cm_sketching_##D##_##R##_table { \
        actions { \
            cm_sketching_##D##_##R##_act; \
        } \
        default_action: cm_sketching_##D##_##R##_act; \
    } \
    action cm_sketching_##D##_##R##_act () { \
        register_read(cm_md_##D.est_##R, cm_register_##D##_##R, 10); \
        add_to_field(cm_md_##D.est_##R, 1); \
        register_write(cm_register_##D##_##R, 10, cm_md_##D.est_##R); \
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
        static: kary_sketching_##D##_##R##_table; \
        instance_count: KARY_WIDTH; \
    } \
    table kary_sketching_##D##_##R##_table { \
        actions { \
            kary_sketching_##D##_##R##_act; \
        } \
        default_action: kary_sketching_##D##_##R##_act; \
    } \
    action kary_sketching_##D##_##R##_act () { \
        register_read(kary_md_##D.est_##R, kary_register_##D##_##R, 10); \
        add_to_field(kary_md_##D.est_##R, 1); \
        register_write(kary_register_##D##_##R, 10, kary_md_##D.est_##R); \
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
        static: hll_sketching_##D##_table; \
        instance_count: HLL_WIDTH; \
    } \
    table hll_sketching_##D##_table { \
        actions { \
            hll_sketching_##D##_act; \
        } \
        default_action: hll_sketching_##D##_act; \
    } \
    action hll_sketching_##D##_act () { \
        register_write(hll_register_##D, 10, LEVEL); \
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
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_read(EST, NAME##_register, INDEX); \
        add_to_field(EST, RES); \
        register_write(NAME##_register, INDEX, EST); \
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
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_write(NAME##_register, INDEX, 1); \
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
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_write(NAME##_register, INDEX, 1); \
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
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_write(NAME##_register, INDEX, 1); \
    }

#define consolidate_update_ss_call(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_add_base_table_2); \
    apply(NAME##_update_table);





#define consolidate_update_ss_update_init(NAME, INDEX, VAL, SIZE) \
    register  NAME##_register { \
        width: 32; \
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_write(NAME##_register, INDEX, VAL); \
    }

#define consolidate_update_ss_update_call(NAME) \
    apply(NAME##_update_table); \
