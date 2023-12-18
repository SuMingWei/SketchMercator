control GET_THRESHOLD_SET_cm_kary(
    inout header_t hdr,
    inout metadata_t ig_md)
{
    action tbl_get_threshold_act (bit<32> cm_threshold, bit<32> kary_threshold, bit<1> kary_epoch, bit<32> um_threshold) {
        ig_md.cm_threshold = cm_threshold;
        ig_md.kary_threshold = kary_threshold;
        ig_md.kary_epoch = kary_epoch;

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
    inout metadata_t ig_md)
{
    action tbl_get_um_threshold_act (bit<32> um_threshold, bit<32> base) {
        ig_md.um_threshold = um_threshold;
        ig_md.base = base;
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
