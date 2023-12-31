control lpm_optimization_32(
    in bit<32> sampling_hash,
    out bit<32> ret_level)
{
    action tbl_act (bit<32> level) {
        ret_level = level;
    }

    table tbl_select_level {
        key = {
            sampling_hash : lpm;
        }
        actions = {
            tbl_act;
        }
        size = 128;
    }

    apply {
        tbl_select_level.apply();
    }
}

control lpm_optimization_16(
    in bit<16> sampling_hash,
    out bit<32> ret_level,
    out bit<16> ret_base,
    out bit<32> ret_threshold)
{
    action tbl_act (bit<32> level, bit<16> base, bit<32> threshold) {
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
        size = 128;
    }

    apply {
        tbl_select_level.apply();
    }
}
