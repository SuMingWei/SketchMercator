#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#define DDOS_TEST_PORT 0x00
#define DDOS_OUT_PORT 0x01


#include "../../../common_library/defines.p4"
#include "../../../common_library/headers.p4"
#include "../../../common_library/parsers.p4"
#include "../../../common_library/route.p4"
#include "../../../common_library/debug.p4"
#include "opt_mrac.p4"

control ingress {
	sketch();
}

control egress {
}


#define COL_SIZE 32

#include "../library/1_metadata.p4"
#include "../library/2_set_level.p4"
#include "../library/3_mem_update.p4"

#include "../../../apis/API0.p4"
#include "../../../apis/API2.p4"
#include "../../../apis/API3.p4"
#include "../../../apis/API4.p4"
#include "../../../apis/API5.p4"
#include "../../../apis/API6.p4"

field_list key_fields {
    ipv4.srcAddr;
}

METADATA_STAGE(1)

API0_HASH_INIT(pcsa_alpha_1, key_fields, 0x1798f10d1, md_1.alpha, 256)
API0_HASH_INIT(pcsa_h_1, key_fields, 0x1798f10d2, md_1.h, 16777216)
API5_INIT(pcsa_tcam_1, md_1.h, 1)
API4_SALU_BITMAP_UPDATE_INIT(pcsa_update_1, md_1.base, md_1.level, md_1.est, 256)


control sketch {
    API0_HASH_CALL(pcsa_alpha_1)
    API0_HASH_CALL(pcsa_h_1)
    API5_CALL(pcsa_tcam_1)
    API4_SALU_BITMAP_UPDATE_CALL(pcsa_update_1)
}
