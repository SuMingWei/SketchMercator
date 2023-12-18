control lpm_optimization_16_um(
    in bit<16> sampling_hash,
    out bit<32> ret_level,
    out bit<16> ret_base,
    out bit<32> ret_um_threshold)
{
    action tbl_act (bit<32> level, bit<16> base, bit<32> um_threshold) {
        ret_level = level;
        ret_base = base;
        ret_um_threshold = um_threshold;
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

control lpm_optimization_16_ss(
    in bit<16> sampling_hash,
    out bit<32> ret_level,
    out bit<16> ret_ss_base)
{
    action tbl_act (bit<32> level, bit<16> ss_base) {
        ret_level = level;
        ret_ss_base = ss_base;
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

control lpm_optimization_16_um_ss(
    in bit<16> sampling_hash,
    out bit<32> ret_level,
    out bit<16> ret_base,
    out bit<32> ret_um_threshold,
    out bit<16> ret_ss_base_1,
    out bit<16> ret_ss_base_2)
{
    action tbl_act (bit<32> level, bit<16> base, bit<32> um_threshold, bit<16> ss_base_1, bit<16> ss_base_2) {
        ret_level = level;
        ret_base = base;
        ret_um_threshold = um_threshold;
        ret_ss_base_1 = ss_base_1;
        ret_ss_base_2 = ss_base_2;
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

