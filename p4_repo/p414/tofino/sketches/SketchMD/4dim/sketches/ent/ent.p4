header_type ent_md_t {
    fields {
        res_1: 1;
        res_2: 1;
        res_3: 1;
        // res_4: 1;
        // res_5: 1;
        index_1: 16;
        index_2: 16;
        index_3: 16;
        // index_4: 16;
        // index_5: 16;
    }
}

#define ENT_WIDTH_BITLEN 10
#define ENT_WIDTH 1024

#define ROW_SKETCH(D, R, FLOWKEY) \
    field_list_calculation ent_index_hash_func_##D##_##R { \
        input { \
            FLOWKEY; \
        } \
        algorithm : poly_0x11e1##D##a##R##19_init_0x00000000_xout_0ffffffff; \
        output_width : ENT_WIDTH_BITLEN; \
    } \
    register  ent_register_##D##_##R { \
        width: 32; \
        instance_count: ENT_WIDTH; \
    } \
    blackbox stateful_alu ent_blackbox_##D##_##R { \
        reg: ent_register_##D##_##R; \
        update_lo_1_value    : register_lo+1;  \
        update_hi_1_value    : register_lo+1; \
        output_value: alu_hi; \
    } \
    table ent_sketching_##D##_##R##_table { \
        actions { \
            ent_sketching_##D##_##R##_act; \
        } \
        default_action: ent_sketching_##D##_##R##_act; \
    } \
    action ent_sketching_##D##_##R##_act () { \
        ent_blackbox_##D##_##R.execute_stateful_alu_from_hash(ent_index_hash_func_##D##_##R); \
    } \


#define ENT_INSTANCE(D, FLOWKEY) \
    metadata ent_md_t ent_md_##D; \
    ROW_SKETCH(D, 1, FLOWKEY) \
    ROW_SKETCH(D, 2, FLOWKEY) \
    ROW_SKETCH(D, 3, FLOWKEY) \


#define ENT_RUN(D) \
    apply(ent_sketching_##D##_1_table); \
    apply(ent_sketching_##D##_2_table); \
    apply(ent_sketching_##D##_3_table); \

