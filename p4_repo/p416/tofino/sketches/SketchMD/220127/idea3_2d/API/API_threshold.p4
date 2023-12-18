control GET_THRESHOLD_SET_cm_kary(
    inout header_t hdr,
    inout metadata_t ig_md)
{
    action tbl_get_threshold_act (bit<1> kary_epoch, bit<32> cm_threshold_1, bit<32> kary_threshold_1, bit<32> cm_threshold_2, bit<32> kary_threshold_2) {
        ig_md.kary_epoch = kary_epoch;

        ig_md.d_1_cm_threshold = cm_threshold_1;
        ig_md.d_1_kary_threshold = kary_threshold_1;

        ig_md.d_2_cm_threshold = cm_threshold_2;
        ig_md.d_2_kary_threshold = kary_threshold_2;

    }
    table tbl_get_threshold {
        key = {
            hdr.ethernet.ether_type : exact;
        }
        actions = {
            tbl_get_threshold_act;
        }
    }
    apply {
        tbl_get_threshold.apply();
    }
}


control GET_THRESHOLD_SET_level(
    in bit<32> level,
    inout bit<32> um_threshold_out,
    inout bit<32> base_out)
{
    action tbl_get_um_threshold_act (bit<32> um_threshold, bit<32> base) {
        um_threshold_out = um_threshold;
        base_out = base;
    }
    table tbl_get_um_threshold {
        key = {
            level : exact;
        }
        actions = {
            tbl_get_um_threshold_act;
        }
    }
    apply {
        tbl_get_um_threshold.apply();
    }
}
