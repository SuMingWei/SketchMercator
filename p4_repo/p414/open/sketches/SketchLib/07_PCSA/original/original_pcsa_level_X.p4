#define DDOS_TEST_PORT 0x00
#define DDOS_OUT_PORT 0x01


#include "../common_library/defines.p4"
#include "../common_library/headers.p4"
#include "../common_library/parsers.p4"
#include "original_pcsa.p4"

control ingress {
	pcsa();
}

control egress {
}
