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
    COMPUTE_RES_5(D) \
    SKETCHING_STAGE_5(D)

DIM_SETUP(1)
DIM_SETUP(2)
DIM_SETUP(3)
DIM_SETUP(4)
DIM_SETUP(5)
DIM_SETUP(6)
DIM_SETUP(7)
DIM_SETUP(8)
DIM_SETUP(9)
DIM_SETUP(10)
DIM_SETUP(11)
DIM_SETUP(12)
DIM_SETUP(13)
DIM_SETUP(14)
DIM_SETUP(15)
DIM_SETUP(16)
DIM_SETUP(17)
DIM_SETUP(18)
DIM_SETUP(19)
DIM_SETUP(20)
DIM_SETUP(21)
DIM_SETUP(22)
DIM_SETUP(23)
DIM_SETUP(24)
DIM_SETUP(25)

#define RES_SETUP(D) \
	apply(res_##D##_1_table); \
	apply(res_##D##_2_table); \
	apply(res_##D##_3_table); \
	apply(res_##D##_4_table); \
	apply(res_##D##_5_table);

#define SKETCHING(D) \
	apply(sketching_##D##_1_table); \
	apply(sketching_##D##_2_table); \
	apply(sketching_##D##_3_table); \
	apply(sketching_##D##_4_table); \
	apply(sketching_##D##_5_table);

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
	RES_SETUP(7)
	RES_SETUP(8)
	RES_SETUP(9)
	RES_SETUP(10)
	RES_SETUP(11)
	RES_SETUP(12)
	RES_SETUP(13)
	RES_SETUP(14)
	RES_SETUP(15)
	RES_SETUP(16)
	RES_SETUP(17)
	RES_SETUP(18)
	RES_SETUP(19)
	RES_SETUP(20)
	RES_SETUP(21)
	RES_SETUP(22)
	RES_SETUP(23)
	RES_SETUP(24)
	RES_SETUP(25)

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
	if (md.level == 7) {
		SKETCHING(7)
	}
	if (md.level == 8) {
		SKETCHING(8)
	}
	if (md.level == 9) {
		SKETCHING(9)
	}
	if (md.level == 10) {
		SKETCHING(10)
	}
	if (md.level == 11) {
		SKETCHING(11)
	}
	if (md.level == 12) {
		SKETCHING(12)
	}
	if (md.level == 13) {
		SKETCHING(13)
	}
	if (md.level == 14) {
		SKETCHING(14)
	}
	if (md.level == 15) {
		SKETCHING(15)
	}
	if (md.level == 16) {
		SKETCHING(16)
	}
	if (md.level == 17) {
		SKETCHING(17)
	}
	if (md.level == 18) {
		SKETCHING(18)
	}
	if (md.level == 19) {
		SKETCHING(19)
	}
	if (md.level == 20) {
		SKETCHING(20)
	}
	if (md.level == 21) {
		SKETCHING(21)
	}
	if (md.level == 22) {
		SKETCHING(22)
	}
	if (md.level == 23) {
		SKETCHING(23)
	}
	if (md.level == 24) {
		SKETCHING(24)
	}
	if (md.level == 25) {
		SKETCHING(25)
	}
}
