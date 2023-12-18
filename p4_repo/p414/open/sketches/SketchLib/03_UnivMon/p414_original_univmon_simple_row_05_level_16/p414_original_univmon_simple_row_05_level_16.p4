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
metadata original_md_t md;

field_list key_fields {
    ipv4.srcAddr;
}

#define DIM_SETUP(D) \
    ORIGINAL_METADATA_STAGE(D) \
    COMPUTE_SAMPLING(D) \
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

control start {

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

	SKETCHING(1)
	apply(sampling_1_table);
	if (md_1.sampling == 1) {
		SKETCHING(2)
		apply(sampling_2_table);
		if (md_2.sampling == 1) {
			SKETCHING(3)
			apply(sampling_3_table);
			if (md_3.sampling == 1) {
				SKETCHING(4)
				apply(sampling_4_table);
				if (md_4.sampling == 1) {
					SKETCHING(5)
					apply(sampling_5_table);
					if (md_5.sampling == 1) {
						SKETCHING(6)
						apply(sampling_6_table);
						if (md_6.sampling == 1) {
							SKETCHING(7)
							apply(sampling_7_table);
							if (md_7.sampling == 1) {
								SKETCHING(8)
								apply(sampling_8_table);
								if (md_8.sampling == 1) {
									SKETCHING(9)
									apply(sampling_9_table);
									if (md_9.sampling == 1) {
										SKETCHING(10)
										apply(sampling_10_table);
										if (md_10.sampling == 1) {
											SKETCHING(11)
											apply(sampling_11_table);
											if (md_11.sampling == 1) {
												SKETCHING(12)
												apply(sampling_12_table);
												if (md_12.sampling == 1) {
													SKETCHING(13)
													apply(sampling_13_table);
													if (md_13.sampling == 1) {
														SKETCHING(14)
														apply(sampling_14_table);
														if (md_14.sampling == 1) {
															SKETCHING(15)
															apply(sampling_15_table);
															if (md_15.sampling == 1) {
																SKETCHING(16)
																apply(sampling_16_table);
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
