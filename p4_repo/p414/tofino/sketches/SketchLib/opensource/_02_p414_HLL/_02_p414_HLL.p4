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

control ingress {
	sketch();
}

control egress {
}

#define COL_SIZE 32

#include "library/1_metadata.p4"
#include "library/2_set_level.p4"
#include "library/3_mem_update.p4"

#include "../API/API_hash.p4"
#include "../API/API_tcam.p4"

field_list key_fields {
    ipv4.srcAddr;
}

METADATA_STAGE(1)

hash_init(hll_h_1, key_fields, 0x1798f10d1, md_1.h, 1048576)

lpm_optimization_init(hll_tcam_1, md_1.h, 1)

ROW_SKETCH(1)

control sketch {
    hash_call(hll_h_1)
    lpm_optimization_call(hll_tcam_1)
    apply(sketching_1_table);
}
