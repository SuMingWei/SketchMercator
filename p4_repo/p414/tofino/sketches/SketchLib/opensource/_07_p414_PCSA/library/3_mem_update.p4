
#define ROW_SKETCH(D, R) \
    register  register_##D##_##R { \
        width: 32; \
        instance_count: COL_SIZE; \
    } \
    blackbox stateful_alu blackbox_##D##_##R { \
        reg: register_##D##_##R; \
        update_lo_1_value    : 1;  \
    } \
    table sketching_##D##_##R##_table { \
        actions { \
            sketching_##D##_##R##_act; \
        } \
        default_action: sketching_##D##_##R##_act; \
    } \
    action sketching_##D##_##R##_act () { \
        blackbox_##D##_##R.execute_stateful_alu(md_##D.level); \
    }





register  register_1_1 {
    width: 32;
    instance_count: 2048;
}
blackbox stateful_alu blackbox_1_1 {
    reg: register_1_1;
    update_lo_1_value    : 1;
}
table sketching_1_1_table {
    actions {
        sketching_1_1_act;
    }
    default_action: sketching_1_1_act;
}
action sketching_1_1_act () {
    blackbox_1_1.execute_stateful_alu(md_1.level);
}


register  register_1_1 {
    width: 32;
    instance_count: COL_SIZE;
}
table sketching_1_1_table {
    actions {
        sketching_1_1_act;
    }
    default_action: sketching_1_1_act;
}
action sketching_1_1_act () {
    register_write(register_1_1, md_1.level, 1);
}
