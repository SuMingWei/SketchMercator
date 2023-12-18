#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"

control ingress {
    sketch();
}

control egress {
}
#define COL_SIZE 2048 
#include "../library/1_metadata.p4" 
#include "../library/2_set_level.p4" 
#include "../library/3_mem_update.p4" 
#include "../apis/API0.p4" 
field_list key_fields { 
    ipv4.srcAddr; 
} 
ORIGINAL_METADATA_STAGE(1)
ROW_SKETCH(1)

API0_HASH_INIT(hll_h1, key_fields, 0x1798f1011, md_1.h1, 2)
API0_HASH_INIT(hll_h2, key_fields, 0x1798f1021, md_1.h2, 2)
API0_HASH_INIT(hll_h3, key_fields, 0x1798f1031, md_1.h3, 2)
API0_HASH_INIT(hll_h4, key_fields, 0x1798f1041, md_1.h4, 2)
API0_HASH_INIT(hll_h5, key_fields, 0x1798f1051, md_1.h5, 2)
API0_HASH_INIT(hll_h6, key_fields, 0x1798f1061, md_1.h6, 2)
API0_HASH_INIT(hll_h7, key_fields, 0x1798f1071, md_1.h7, 2)
API0_HASH_INIT(hll_h8, key_fields, 0x1798f1081, md_1.h8, 2)
API0_HASH_INIT(hll_h9, key_fields, 0x1798f1091, md_1.h9, 2)
API0_HASH_INIT(hll_h10, key_fields, 0x1798f10a1, md_1.h10, 2)
API0_HASH_INIT(hll_h11, key_fields, 0x1798f10b1, md_1.h11, 2)
API0_HASH_INIT(hll_h12, key_fields, 0x1798f10c1, md_1.h12, 2)
API0_HASH_INIT(hll_h13, key_fields, 0x1798f10d1, md_1.h13, 2)
API0_HASH_INIT(hll_h14, key_fields, 0x1798f10e1, md_1.h14, 2)
API0_HASH_INIT(hll_h15, key_fields, 0x1798f10f1, md_1.h15, 2)
API0_HASH_INIT(hll_h16, key_fields, 0x1798f10101, md_1.h16, 2)
API0_HASH_INIT(hll_h17, key_fields, 0x1798f10111, md_1.h17, 2)
API0_HASH_INIT(hll_h18, key_fields, 0x1798f10121, md_1.h18, 2)

SET_LEVEL(1, 1)
SET_LEVEL(1, 2)
SET_LEVEL(1, 3)
SET_LEVEL(1, 4)
SET_LEVEL(1, 5)
SET_LEVEL(1, 6)
SET_LEVEL(1, 7)
SET_LEVEL(1, 8)
SET_LEVEL(1, 9)
SET_LEVEL(1, 10)
SET_LEVEL(1, 11)
SET_LEVEL(1, 12)
SET_LEVEL(1, 13)
SET_LEVEL(1, 14)
SET_LEVEL(1, 15)
SET_LEVEL(1, 16)
SET_LEVEL(1, 17)
SET_LEVEL(1, 18)

control sketch {
	API0_HASH_CALL(hll_h1)

	if (md_1.h1 == 0) {
		apply(set_level_1_1_table);
	}

	if (md_1.h1 == 1) {
		API0_HASH_CALL(hll_h2)

		if (md_1.h2 == 0) {
			apply(set_level_1_2_table);
		}

		if (md_1.h2 == 1) {
			API0_HASH_CALL(hll_h3)

			if (md_1.h3 == 0) {
				apply(set_level_1_3_table);
			}

			if (md_1.h3 == 1) {
				API0_HASH_CALL(hll_h4)

				if (md_1.h4 == 0) {
					apply(set_level_1_4_table);
				}

				if (md_1.h4 == 1) {
					API0_HASH_CALL(hll_h5)

					if (md_1.h5 == 0) {
						apply(set_level_1_5_table);
					}

					if (md_1.h5 == 1) {
						API0_HASH_CALL(hll_h6)

						if (md_1.h6 == 0) {
							apply(set_level_1_6_table);
						}

						if (md_1.h6 == 1) {
							API0_HASH_CALL(hll_h7)

							if (md_1.h7 == 0) {
								apply(set_level_1_7_table);
							}

							if (md_1.h7 == 1) {
								API0_HASH_CALL(hll_h8)

								if (md_1.h8 == 0) {
									apply(set_level_1_8_table);
								}

								if (md_1.h8 == 1) {
									API0_HASH_CALL(hll_h9)

									if (md_1.h9 == 0) {
										apply(set_level_1_9_table);
									}

									if (md_1.h9 == 1) {
										API0_HASH_CALL(hll_h10)

										if (md_1.h10 == 0) {
											apply(set_level_1_10_table);
										}

										if (md_1.h10 == 1) {
											API0_HASH_CALL(hll_h11)

											if (md_1.h11 == 0) {
												apply(set_level_1_11_table);
											}

											if (md_1.h11 == 1) {
												API0_HASH_CALL(hll_h12)

												if (md_1.h12 == 0) {
													apply(set_level_1_12_table);
												}

												if (md_1.h12 == 1) {
													API0_HASH_CALL(hll_h13)

													if (md_1.h13 == 0) {
														apply(set_level_1_13_table);
													}

													if (md_1.h13 == 1) {
														API0_HASH_CALL(hll_h14)

														if (md_1.h14 == 0) {
															apply(set_level_1_14_table);
														}

														if (md_1.h14 == 1) {
															API0_HASH_CALL(hll_h15)

															if (md_1.h15 == 0) {
																apply(set_level_1_15_table);
															}

															if (md_1.h15 == 1) {
																API0_HASH_CALL(hll_h16)

																if (md_1.h16 == 0) {
																	apply(set_level_1_16_table);
																}

																if (md_1.h16 == 1) {
																	API0_HASH_CALL(hll_h17)

																	if (md_1.h17 == 0) {
																		apply(set_level_1_17_table);
																	}

																	if (md_1.h17 == 1) {
																		apply(set_level_1_18_table);
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
	}
	apply(sketching_1_table);
}
