#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "../common/headers.p4"
#include "../common/util.p4"
#include "../library/1_metadata.p4"

struct metadata_t {
	METADATA_SETUP(1)
	METADATA_SETUP(2)
	METADATA_SETUP(3)
	METADATA_SETUP(4)
	METADATA_SETUP(5)
	METADATA_SETUP(6)
	METADATA_SETUP(7)
	METADATA_SETUP(8)
}

#include "../common/parser.p4"
#include "../library/2_compute_hash.p4"
#include "../library/3_sketching.p4"

#define LEVEL_SETUP(D) \
COMPUTE_SAMPLING(D) \
COMPUTE_RES_1(D) \
SKETCHING_STAGE_1(D)

#define RES_CALL(D) \
	action_res_hash_##D##_1();

#define SKETCHING(D) \
	action_index_hash_and_salu_##D##_1();

control SwitchIngress(
    inout header_t hdr,
    inout metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

	LEVEL_SETUP(1)
	LEVEL_SETUP(2)
	LEVEL_SETUP(3)
	LEVEL_SETUP(4)
	LEVEL_SETUP(5)
	LEVEL_SETUP(6)
	LEVEL_SETUP(7)
	LEVEL_SETUP(8)

	apply {
		RES_CALL(1)
		RES_CALL(2)
		RES_CALL(3)
		RES_CALL(4)
		RES_CALL(5)
		RES_CALL(6)
		RES_CALL(7)
		RES_CALL(8)

		SKETCHING(1)
		action_sampling_hash_1();
		if(ig_md.sampling_bit_1 == 1) {
			SKETCHING(2)
			action_sampling_hash_2();
			if(ig_md.sampling_bit_2 == 1) {
				SKETCHING(3)
				action_sampling_hash_3();
				if(ig_md.sampling_bit_3 == 1) {
					SKETCHING(4)
					action_sampling_hash_4();
					if(ig_md.sampling_bit_4 == 1) {
						SKETCHING(5)
						action_sampling_hash_5();
						if(ig_md.sampling_bit_5 == 1) {
							SKETCHING(6)
							action_sampling_hash_6();
							if(ig_md.sampling_bit_6 == 1) {
								SKETCHING(7)
								action_sampling_hash_7();
								if(ig_md.sampling_bit_7 == 1) {
									SKETCHING(8)
									action_sampling_hash_8();
								}
							}
						}
					}
				}
			}
		}
	}
}

struct my_egress_headers_t {
}

struct my_egress_metadata_t {
}

parser EgressParser(packet_in        pkt,
out my_egress_headers_t          hdr,
out my_egress_metadata_t         meta,
out egress_intrinsic_metadata_t  eg_intr_md)
{
state start {
    pkt.extract(eg_intr_md);
    transition accept;
}
}

control EgressDeparser(packet_out pkt,
inout my_egress_headers_t                       hdr,
in    my_egress_metadata_t                      meta,
in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
apply {
    pkt.emit(hdr);
}
}

Pipeline(
SwitchIngressParser(),
SwitchIngress(),
SwitchIngressDeparser(),
EgressParser(),
EmptyEgress(),
EgressDeparser()
) pipe;

Switch(pipe) main;
