control GET_THRESHOLD(
    inout header_t hdr,
    inout metadata_t ig_md)
{
    action tbl_get_threshold_act (bit<32> cm_threshold, bit<32> kary_threshold, bit<1> kary_epoch) {
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
