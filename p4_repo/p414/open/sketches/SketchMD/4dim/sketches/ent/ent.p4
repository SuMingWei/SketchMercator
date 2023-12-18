header_type ent_md_t {
    fields {
        res_1: 1;
        res_2: 1;
        res_3: 1;
        index_1: 16;
        index_2: 16;
        index_3: 16;
        est_1: 32;
        est_2: 32;
        est_3: 32;
    }
}

#define ENT_INSTANCE(D, FLOWKEY) \
    metadata ent_md_t ent_md_##D; \
    ENT_ROW_SKETCH(D, 1, FLOWKEY) \
    ENT_ROW_SKETCH(D, 2, FLOWKEY) \
    ENT_ROW_SKETCH(D, 3, FLOWKEY) \
    table ent_##D##_dummy_table { \
        actions { \
            ent_##D##_dummy_table_act; \
        } \
        default_action: ent_##D##_dummy_table_act; \
    } \
    action ent_##D##_dummy_table_act() {\
        add_to_field(ent_md_##D.est_1, 1);\
        add_to_field(ent_md_##D.est_2, 1);\
        add_to_field(ent_md_##D.est_3, 1);\
    }\


#define ENT_RUN(D) \
    apply(ent_sketching_##D##_1_table); \
    apply(ent_sketching_##D##_2_table); \
    apply(ent_sketching_##D##_3_table); \
    apply(ent_##D##_dummy_table); \
