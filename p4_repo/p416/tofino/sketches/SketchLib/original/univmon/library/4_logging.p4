header_type logging_md_t {
    fields {
        index: 32;
        logsize: 32;
        subtract_index: 32;
        shift: 1;
    }
}
metadata logging_md_t logging_md;

register  register_log_index {
    width: 32;
    instance_count: 1;
}
blackbox stateful_alu blackbox_log_index {
    reg: register_log_index;
    update_lo_1_value    : register_lo + 1;
    output_value: alu_lo;
    output_dst: logging_md.index;
}
table log_index_table {
    actions {
        log_index_act;
    }
    default_action: log_index_act;
}
action log_index_act () {
    blackbox_log_index.execute_stateful_alu(0);
    modify_field(logging_md.logsize, LOG_SIZE);
}

table log_diff_table {
    actions {
        log_diff_act;
    }
    default_action: log_diff_act;
}
action log_diff_act () {
    subtract(logging_md.subtract_index, logging_md.index, logging_md.logsize);
}

table log_shift_table {
    actions {
        log_shift_act;
    }
    default_action: log_shift_act;
}
action log_shift_act () {
    shift_right(logging_md.shift, logging_md.subtract_index, 31);
}

#define LOGGING(D) \
    register  register_log_##D##_1 { \
        width: 32; \
        instance_count: LOG_SIZE; \
    } \
    blackbox stateful_alu blackbox_log_##D##_1 { \
        reg: register_log_##D##_1; \
        update_lo_1_value    : ipv4.srcAddr;  \
    } \
    table log_##D##_table_1 { \
        actions { \
            log_##D##_act_1; \
        } \
        default_action: log_##D##_act_1; \
    } \
    action log_##D##_act_1 () { \
        blackbox_log_##D##_1.execute_stateful_alu(logging_md.index); \
    } \
    register  register_log_##D##_2 { \
        width: 32; \
        instance_count: LOG_SIZE; \
    } \
    blackbox stateful_alu blackbox_log_##D##_2 { \
        reg: register_log_##D##_2; \
        update_lo_2_value    : ipv4.srcAddr;  \
    } \
    table log_##D##_table_2 { \
        actions { \
            log_##D##_act_2; \
        } \
        default_action: log_##D##_act_2; \
    } \
    action log_##D##_act_2 () { \
        blackbox_log_##D##_2.execute_stateful_alu(logging_md.subtract_index); \
    }
