#define ROW_SKETCH(D) \
    register  register_##D { \
        width: 32; \
        instance_count: COL_SIZE; \
    } \
    blackbox stateful_alu blackbox_##D { \
        reg: register_##D; \
        condition_lo: md_##D.level > register_lo; \
        update_lo_1_predicate: condition_lo; \
        update_lo_1_value    : md_##D.level;  \
    } \
    table sketching_##D##_table { \
        actions { \
            sketching_##D##_act; \
        } \
        default_action: sketching_##D##_act; \
    } \
    field_list_calculation hll_hash_func_##D { \
        input { \
            key_fields; \
        } \
        algorithm : poly_0x11e12a7##D##7_init_0x00000000_xout_0ffffffff; \
        output_width : 11; \
    } \
    action sketching_##D##_act () { \
        blackbox_##D.execute_stateful_alu_from_hash(hll_hash_func_##D); \
    }
