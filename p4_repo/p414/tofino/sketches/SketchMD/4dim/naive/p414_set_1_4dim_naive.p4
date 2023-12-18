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
#include "um/um.p4"

// CM_INSTANCE_KEY_1(1, key_srcip, ipv4.srcAddr)
// CM_INSTANCE_KEY_1(2, key_dstip, ipv4.dstAddr)
// CM_INSTANCE_KEY_2(3, key_srcip_dstip, ipv4.srcAddr, ipv4.dstAddr)
// CM_INSTANCE_KEY_3(4, key_four_tuple, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

// MRB_INSTANCE(1, key_srcip)
// MRB_INSTANCE(2, key_dstip)
// MRB_INSTANCE(3, key_srcip_dstip)
// MRB_INSTANCE(4, key_four_tuple)

// ENT_INSTANCE(1, key_srcip)
// ENT_INSTANCE(2, key_dstip)
// ENT_INSTANCE(3, key_srcip_dstip)
// ENT_INSTANCE(4, key_four_tuple)

// MRAC_INSTANCE(1, key_srcip)
// MRAC_INSTANCE(2, key_dstip)
// MRAC_INSTANCE(3, key_srcip_dstip)
// MRAC_INSTANCE(4, key_four_tuple)

KARY_INSTANCE_KEY_1(1, key_srcip, ipv4.srcAddr)
// KARY_INSTANCE_KEY_1(2, key_dstip, ipv4.dstAddr)
// KARY_INSTANCE_KEY_2(3, key_srcip_dstip, ipv4.srcAddr, ipv4.dstAddr)
KARY_INSTANCE_KEY_3(4, key_four_tuple, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

// SS_INSTANCE(1, key_srcip, key_srcip_dstip)
// SS_INSTANCE(2, key_dstip, key_srcip_dstip)
// SS_INSTANCE(3, key_srcip_dstip, key_srcip_dstip_srcport)
// SS_INSTANCE(4, key_four_tuple, key_srcip_dstip_dstport)


control ingress {
    // CM_RUN_KEY_1(1, ipv4.srcAddr)
    // CM_RUN_KEY_1(2, ipv4.dstAddr)
    // CM_RUN_KEY_2(3, ipv4.srcAddr, ipv4.dstAddr)
    // CM_RUN_KEY_3(4, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

    // MRB_RUN(1)
    // MRB_RUN(2)
    // MRB_RUN(3)
    // MRB_RUN(4)

    // ENT_RUN(1)
    // ENT_RUN(2)
    // ENT_RUN(3)
    // ENT_RUN(4)

    // MRAC_RUN(1)
    // MRAC_RUN(2)
    // MRAC_RUN(3)
    // MRAC_RUN(4)

    KARY_RUN_KEY_1(1, ipv4.srcAddr)
    // KARY_RUN_KEY_1(2, ipv4.dstAddr)
    // KARY_RUN_KEY_2(3, ipv4.srcAddr, ipv4.dstAddr)
    KARY_RUN_KEY_3(4, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

    // SS_RUN(1)
    // SS_RUN(2)
    // SS_RUN(3)
    // SS_RUN(4)
}

control egress {
}