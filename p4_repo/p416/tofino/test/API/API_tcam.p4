control HLL_TCAM(
    in bit<20> sampling_hash,
    out bit<16> ret_level)
{
    action tbl_act (bit<16> level) {
        ret_level = level;
    }

    table tbl_select_level {
        key = {
            sampling_hash : lpm;
        }
        actions = {
            tbl_act;
        }
        // const default_action = tbl_act;
    }

    apply {
        tbl_select_level.apply();
    }
}

control MRB_TCAM(
    in bit<15> sampling_hash,
    out bit<4> ret_level)
{
    action tbl_act (bit<4> level) {
        ret_level = level;
    }

    table tbl_select_level {
        key = {
            sampling_hash : lpm;
        }
        actions = {
            tbl_act;
        }
        // const default_action = tbl_act;
    }

    apply {
        tbl_select_level.apply();
    }
}

control TCAM(
    in bit<16> sampling_hash,
    out bit<10> ret_level,
    out bit<16> ret_base,
    out bit<32> ret_threshold)
{
    action tbl_act (bit<10> level, bit<16> base, bit<32> threshold) {
        ret_level = level;
        ret_base = base;
        ret_threshold = threshold;
    }

    table tbl_select_level {
        key = {
            sampling_hash : lpm;
        }
        actions = {
            tbl_act;
        }
        // const default_action = tbl_act;
    }

    apply {
        tbl_select_level.apply();
    }
}
