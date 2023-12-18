#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"

control ingress {
    start();
}

control egress {
}

#define CS_HASH_WIDTH 11
#define COL_SIZE 2048

#include "../library/0_hash_params.p4"
#include "../library/1_metadata.p4"
#include "../library/2_compute_hash.p4"
#include "../library/3_sketching.p4"
#include "../library/4_logging.p4"

field_list key_fields {
    ipv4.srcAddr;
}

#define DIM_SETUP(D) \
    METADATA_STAGE(D) \
    COMPUTE_RES_3(D) \
    SKETCHING_STAGE_3(D)

DIM_SETUP(1)

#define RES_SETUP(D) \
	apply(res_##D##_1_table); \
	apply(res_##D##_2_table); \
	apply(res_##D##_3_table);

#define SKETCHING(D) \
	apply(sketching_##D##_1_table); \
	apply(sketching_##D##_2_table); \
	apply(sketching_##D##_3_table);

metadata md_t md;


control start {
	RES_SETUP(1)

	SKETCHING(1)
}
