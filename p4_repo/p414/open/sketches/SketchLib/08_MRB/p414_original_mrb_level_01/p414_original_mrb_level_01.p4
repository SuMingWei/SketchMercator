#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"

control ingress {
    sketch();
}

control egress {
}
#define COL_SIZE 4096 
#include "../library/1_metadata.p4" 
#include "../library/2_set_level.p4" 
#include "../library/3_mem_update.p4" 
#include "../apis/API0.p4" 
field_list key_fields { 
    ipv4.srcAddr; 
} 
ORIGINAL_METADATA_STAGE(1)

API0_HASH_INIT(alpha, key_fields, 0x1798f10d3, md_1.alpha, 4096)
 

API0_HASH_INIT(hll_h1, key_fields, 0x1798f1011, md_1.h1, 2)

SET_LEVEL(1, 1)

ROW_SKETCH(1, 1)

control sketch {
	API0_HASH_CALL(alpha)

	apply(set_level_1_1_table);

	if(md_1.level == 1) {
		apply(sketching_1_1_table);
	}
}