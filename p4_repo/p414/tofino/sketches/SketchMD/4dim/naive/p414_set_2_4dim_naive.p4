#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#include "headers.p4"
#include "parsers.p4"

field_list key_srcip {
    ipv4.srcAddr;
}

field_list key_dstip {
    ipv4.dstAddr;
}

field_list key_srcip_dstip {
    ipv4.srcAddr;
    ipv4.dstAddr;
}

field_list key_four_tuple {
    ipv4.srcAddr;
    ipv4.dstAddr;
    tcp.srcPort;
    tcp.dstPort;
}

field_list key_srcip_dstip_srcport {
    ipv4.srcAddr;
    ipv4.dstAddr;
    tcp.srcPort;
}

field_list key_srcip_dstip_dstport {
    ipv4.srcAddr;
    ipv4.dstAddr;
    tcp.dstPort;
}

#include "API_common.p4"
#include "API_O1_hash.p4"
#include "API_O3_tcam.p4"
#include "API_O5_salu.p4"
#include "API_O6_flowkey.p4"
#include "API_threshold.p4"

#include "cm/cm.p4"
#include "ent/ent.p4"
#include "hll/hll.p4"
#include "kary/kary.p4"
#include "mrac/mrac.p4"
#include "mrb/mrb.p4"
#include "ss/ss.p4"
#include "um/um.p4"

// CM_INSTANCE(1, key_srcip)
// CM_INSTANCE(2, key_dstip)
// CM_INSTANCE(3, key_srcip_dstip)
// CM_INSTANCE(4, key_four_tuple)

HLL_INSTANCE(1, key_srcip)
HLL_INSTANCE(2, key_dstip)
HLL_INSTANCE(3, key_srcip_dstip)
HLL_INSTANCE(4, key_four_tuple)

// ENT_INSTANCE(1, key_srcip)
// ENT_INSTANCE(2, key_dstip)
// ENT_INSTANCE(3, key_srcip_dstip)
// ENT_INSTANCE(4, key_four_tuple)

// MRAC_INSTANCE(1, key_srcip)
// MRAC_INSTANCE(2, key_dstip)
// MRAC_INSTANCE(3, key_srcip_dstip)
// MRAC_INSTANCE(4, key_four_tuple)

// KARY_INSTANCE(1, key_srcip)
// KARY_INSTANCE(2, key_dstip)
// KARY_INSTANCE(3, key_srcip_dstip)
// KARY_INSTANCE(4, key_four_tuple)

SS_INSTANCE_KEY_1(1, key_srcip, key_dstip, ipv4.srcAddr)
SS_INSTANCE_KEY_1(2, key_dstip, key_srcip, ipv4.dstAddr)
// SS_INSTANCE_KEY_1(3, key_dstip, key_srcip_dstip_srcport, ipv4.dstAddr)
// SS_INSTANCE_KEY_2(4, key_srcip_dstip_dstport, key_dstip, ipv4.dstAddr, tcp.seqNo)


control ingress {
    // CM_RUN(1)
    // CM_RUN(2)
    // CM_RUN(3)
    // CM_RUN(4)

    // HLL_RUN(1)
    // HLL_RUN(2)
    // HLL_RUN(3)
    // HLL_RUN(4)

    // ENT_RUN(1)
    // ENT_RUN(2)
    // ENT_RUN(3)
    // ENT_RUN(4)

    // MRAC_RUN(1)
    // MRAC_RUN(2)
    // MRAC_RUN(3)
    // MRAC_RUN(4)

    // KARY_RUN(1)
    // KARY_RUN(2)
    // KARY_RUN(3)
    // KARY_RUN(4)

    SS_RUN_KEY_1(1)
    SS_RUN_KEY_1(2)
    // SS_RUN_KEY_1(3)
    // SS_RUN_KEY_2(4)
}

control egress {
}