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

UM_NOHH_INSTANCE(1, key_srcip)
UM_NOHH_INSTANCE(2, key_dstip)
UM_NOHH_INSTANCE(3, key_srcip_dstip)
UM_NOHH_INSTANCE(4, key_four_tuple)

SS_ADV_INSTANCE(1, key_srcip, key_srcip_dstip)
SS_ADV_INSTANCE(2, key_dstip, key_srcip_dstip)
SS_ADV_INSTANCE(3, key_srcip_dstip, key_srcip_dstip_srcport)
SS_ADV_INSTANCE(4, key_four_tuple, key_srcip_dstip_dstport)


control ingress {
    UM_NOHH_RUN(1)
    UM_NOHH_RUN(2)
    UM_NOHH_RUN(3)
    UM_NOHH_RUN(4)

    SS_ADV_RUN(1)
    SS_ADV_RUN(2)
    SS_ADV_RUN(3)
    SS_ADV_RUN(4)

    // UNION KEY IMPL
}

control egress {
}