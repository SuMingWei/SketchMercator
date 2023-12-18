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

header_type md_t {
    fields {
        recirculation: 1;
    }
}
metadata md_t md;
table recirculation_table {
    actions {
        recirculation_table_act;
    }
    default_action: recirculation_table_act;
}
action recirculation_table_act () {
    modify_field(md.recirculation, 1);
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


UM_INSTANCE_KEY_1(1, key_srcip, ipv4.srcAddr)
UM_INSTANCE_KEY_1(2, key_dstip, ipv4.dstAddr)
UM_INSTANCE_KEY_2(3, key_srcip_dstip, ipv4.srcAddr, ipv4.dstAddr)
UM_INSTANCE_KEY_3_SIZE(4, key_four_tuple, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo, 65536)

SS_INSTANCE_KEY_1(1, key_srcip, key_dstip, ipv4.srcAddr)
SS_INSTANCE_KEY_1(2, key_dstip, key_srcip, ipv4.dstAddr)
SS_INSTANCE_KEY_1(3, key_dstip, key_srcip_dstip_srcport, ipv4.dstAddr)
SS_INSTANCE_KEY_2(4, key_srcip_dstip_dstport, key_dstip, ipv4.dstAddr, tcp.seqNo)


control ingress {
    UM_RUN_KEY_ALL(4, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)
    UM_RUN_KEY_1_HALF(1, ipv4.srcAddr)
    UM_RUN_KEY_1_HALF(2, ipv4.dstAddr)
    UM_RUN_KEY_2_HALF(3, ipv4.srcAddr, ipv4.dstAddr)
    UM_RUN_KEY_3_HALF(4, ipv4.srcAddr, ipv4.dstAddr, tcp.seqNo)

    if(um_md_1.above_threshold == 1) {
        if(um_md_2.above_threshold == 1) {
            if(um_md_3.above_threshold == 1) {
                if(um_md_4.above_threshold == 1) {
                    apply(recirculation_table);
                }
            }
        }
    }

    SS_ADV_RUN_KEY_1(1)
    SS_ADV_RUN_KEY_1(2)
    SS_ADV_RUN_KEY_1(3)
    SS_ADV_RUN_KEY_2(4)
}

control egress {
}