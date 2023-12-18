#define ROW_SKETCH(D) \
    register  register_##D { \
        width: 32; \
        static: sketching_##D##_table; \
        instance_count: COL_SIZE; \
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
        algorithm : programmable_crc; \
        output_width : 11; \
    } \
    action sketching_##D##_act () { \
        modify_field_with_hash_based_offset(md_##D.alpha, 0, hll_hash_func_##D, 2048); \
        register_write(register_##D, md_##D.alpha, md_##D.level); \
    }




    // blackbox stateful_alu blackbox_##D { \
    //     reg: register_##D; \
    //     condition_lo: md_##D.level > register_lo; \
    //     update_lo_1_predicate: condition_lo; \
    //     update_lo_1_value    : md_##D.level;  \
    // } \
