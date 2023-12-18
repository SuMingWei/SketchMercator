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
DIM_SETUP(2)
DIM_SETUP(3)
DIM_SETUP(4)
DIM_SETUP(5)
DIM_SETUP(6)

#define RES_SETUP(D) \
	apply(res_##D##_1_table); \
	apply(res_##D##_2_table); \
	apply(res_##D##_3_table);

#define SKETCHING(D) \
	apply(sketching_##D##_1_table); \
	apply(sketching_##D##_2_table); \
	apply(sketching_##D##_3_table);

metadata md_t md;

table compute_level_table {
    actions {
        compute_level_act;
    }
    default_action: compute_level_act;
}
action compute_level_act () {
    shift_left(md.level, ipv4.srcAddr, 3);
}

control start {

	apply(compute_level_table);

	RES_SETUP(1)
	RES_SETUP(2)
	RES_SETUP(3)
	RES_SETUP(4)
	RES_SETUP(5)
	RES_SETUP(6)

	if (md.level == 1) {
		SKETCHING(1)
	}
	if (md.level == 2) {
		SKETCHING(2)
	}
	if (md.level == 3) {
		SKETCHING(3)
	}
	if (md.level == 4) {
		SKETCHING(4)
	}
	if (md.level == 5) {
		SKETCHING(5)
	}
	if (md.level == 6) {
		SKETCHING(6)
	}
}
