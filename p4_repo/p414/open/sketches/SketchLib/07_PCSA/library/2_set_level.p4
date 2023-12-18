#define SET_LEVEL(D, L) \
    table set_level_##D##_##L##_table { \
        actions { \
            set_level_##D##_##L##_table_act; \
        } \
        default_action: set_level_##D##_##L##_table_act; \
    } \
    action set_level_##D##_##L##_table_act () { \
        modify_field(md_##D.level, L); \
    }

