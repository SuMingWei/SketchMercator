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
    inout bit<16> ret_level)
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

control UNIVMON_TCAM(
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

control RHHH_TABLE(
    in bit<5> random_bits,
    out bit<10> ret_level,
    out bit<16> ret_base,
    out bit<32> ret_threshold,
    out bit<32> ret_s_mask,
    out bit<32> ret_d_mask,
    inout bit<32> masked_srcip,
    inout bit<32> masked_dstip,
    in bit<32> src_addr,
    in bit<32> dst_addr)
{
    action tbl_act (bit<10> level, bit<16> base, bit<32> threshold, bit<32> s_mask, bit<32> d_mask) {
        ret_level = level;
        ret_base = base;
        ret_threshold = threshold;
        ret_s_mask = s_mask;
        ret_d_mask = d_mask;
        masked_srcip = src_addr & s_mask;
        masked_dstip = dst_addr & d_mask;
    }

    table tbl_select_level {
        key = {
            random_bits : exact;
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
