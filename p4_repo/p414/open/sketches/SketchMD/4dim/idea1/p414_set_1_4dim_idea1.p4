#include "../common_p4/headers.p4"
#include "../common_p4/parsers.p4"

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

#include "../API/API_common.p4"
#include "../API/API_O1_hash.p4"
#include "../API/API_O3_tcam.p4"
#include "../API/API_O5_salu.p4"
#include "../API/API_O6_flowkey.p4"
#include "../API/API_threshold.p4"

#include "../sketches/cm/cm.p4"
#include "../sketches/ent/ent.p4"
#include "../sketches/hll/hll.p4"
#include "../sketches/kary/kary.p4"
#include "../sketches/mrac/mrac.p4"
#include "../sketches/mrb/mrb.p4"
#include "../sketches/ss/ss.p4"
#include "../sketches/um/um.p4"

CM_INSTANCE_KEY_1(1, key_srcip, ipv4.srcAddr)
CM_INSTANCE_KEY_1(2, key_dstip, ipv4.dstAddr)
CM_INSTANCE_KEY_2(3, key_srcip_dstip, ipv4.srcAddr, ipv4.dstAddr)
CM_INSTANCE_KEY_3(4, key_four_tuple, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

MRAC_INSTANCE(1, key_srcip)
MRAC_INSTANCE(2, key_dstip)
MRAC_INSTANCE(3, key_srcip_dstip)
MRAC_INSTANCE(4, key_four_tuple)

SS_INSTANCE_KEY_1(1, key_srcip, key_dstip, ipv4.srcAddr)
SS_INSTANCE_KEY_1(2, key_dstip, key_srcip, ipv4.dstAddr)
SS_INSTANCE_KEY_1(3, key_dstip, key_srcip_dstip_srcport, ipv4.dstAddr)
SS_INSTANCE_KEY_2(4, key_srcip_dstip_dstport, key_dstip, ipv4.dstAddr, tcp.seqNo)


control ingress {
    CM_RUN_KEY_1(1, ipv4.srcAddr)
    CM_RUN_KEY_1(2, ipv4.dstAddr)
    CM_RUN_KEY_2(3, ipv4.srcAddr, ipv4.dstAddr)
    CM_RUN_KEY_3(4, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

    MRAC_RUN(1)
    MRAC_RUN(2)
    MRAC_RUN(3)
    MRAC_RUN(4)

    SS_RUN_KEY_1(1)
    SS_RUN_KEY_1(2)
    SS_RUN_KEY_1(3)
    SS_RUN_KEY_2(4)
}

control egress {
}