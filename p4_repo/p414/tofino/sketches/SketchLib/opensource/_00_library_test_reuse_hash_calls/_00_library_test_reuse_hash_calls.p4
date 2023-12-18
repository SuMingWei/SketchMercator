#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>

#define DDOS_TEST_PORT 0x00
#define DDOS_OUT_PORT 0x01

#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"
#include "../common_library/route.p4"

#include "library/1_metadata.p4"
#include "../API/API_hash.p4"

field_list key_fields {
    ipv4.srcAddr;
}


METADATA_STAGE(1)

reuse_hash_result_3_init(api_test, key_fields, 0x119cf8781, md_1.index_1, md_1.index_2, md_1.index_3, md_1.index_4, 15, 31, 63)

control ingress {
    reuse_hash_result_3_call(api_test)
}

control egress {
}
