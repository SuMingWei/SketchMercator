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

SET_LEVEL(1, 1)

control sketch {
	apply(set_level_1_1_table);
	apply(sketching_1_table);
}
