import os

def print_tab(f, j):
    for k in range(1, j+1):
        f.write('\t')

def generate_code(row, level):
    folder_name = "p416_original_univmon_row_%d_level_%02d_one" % (row, level)
    print(folder_name)
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    f = open(os.path.join(folder_name, folder_name+".p4"), "w+")
    f.write('\
#include <core.p4>\n\
#if __TARGET_TOFINO__ == 2\n\
#include <t2na.p4>\n\
#else\n\
#include <tna.p4>\n\
#endif\n\n\
#include "../common/headers.p4"\n\
#include "../common/util.p4"\n\
#include "../library/1_metadata.p4"\n\n\
struct metadata_t {\n')
    for k in range(1, level+1):
        f.write('\tMETADATA_SETUP(%d)\n' % k)
    f.write("}\n\n")

    f.write('\
#include "../common/parser.p4"\n\
#include "../library/2_compute_hash.p4"\n\
#include "../library/3_sketching.p4"\n\n\
#define LEVEL_SETUP(D) \\\n\
COMPUTE_SAMPLING(D) \\\n\
COMPUTE_RES_%d(D) \\\n\
SKETCHING_STAGE_%d(D)\n\n' % (row, row))

    f.write('#define RES_CALL(D) \\\n')
    for k in range(1, row):
        f.write('\taction_res_hash_##D##_%d(); \\\n' % k)
    f.write('\taction_res_hash_##D##_%d();\n\n' % row)

    f.write('#define SKETCHING(D) \\\n')
    for k in range(1, row):
        f.write('\taction_index_hash_and_salu_##D##_%d(); \\\n' % k)
    f.write('\taction_index_hash_and_salu_##D##_%d();\n\n' % row)

    f.write('\
control SwitchIngress(\n\
    inout header_t hdr,\n\
    inout metadata_t ig_md,\n\
    in ingress_intrinsic_metadata_t ig_intr_md,\n\
    in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,\n\
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,\n\
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {\n\n')

    for k in range(1, level+1):
        f.write('\tLEVEL_SETUP(%d)\n' % k)
    f.write('\n')

    f.write('\tapply {\n')
    for k in range(1, level+1):
        f.write('\t\tRES_CALL(%d)\n' % k)
    f.write('\n')
    
    f.write('\t\tSKETCHING(1)\n')
    f.write('\t\taction_sampling_hash_1();\n');

    for k in range(2, level+1):
        print_tab(f, k)
        f.write('if(ig_md.sampling_bit_%d == 1) {\n' % (k-1))

        print_tab(f, k+1)
        f.write('SKETCHING(%d)\n' % k)
        print_tab(f, k+1)
        f.write('action_sampling_hash_%d();\n' % k)

    for j in reversed(range(1, level)):
        print_tab(f, j+1)
        f.write('}\n')

    for j in reversed(range(0, 2)):
        print_tab(f, j)
        f.write('}\n')
    f.write('\n\
struct my_egress_headers_t {\n\
}\n\
\n\
struct my_egress_metadata_t {\n\
}\n\
\n\
parser EgressParser(packet_in        pkt,\n\
out my_egress_headers_t          hdr,\n\
out my_egress_metadata_t         meta,\n\
out egress_intrinsic_metadata_t  eg_intr_md)\n\
{\n\
state start {\n\
    pkt.extract(eg_intr_md);\n\
    transition accept;\n\
}\n\
}\n\
\n\
control EgressDeparser(packet_out pkt,\n\
inout my_egress_headers_t                       hdr,\n\
in    my_egress_metadata_t                      meta,\n\
in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)\n\
{\n\
apply {\n\
    pkt.emit(hdr);\n\
}\n\
}\n\
\n\
Pipeline(\n\
SwitchIngressParser(),\n\
SwitchIngress(),\n\
SwitchIngressDeparser(),\n\
EgressParser(),\n\
EmptyEgress(),\n\
EgressDeparser()\n\
) pipe;\n\
\n\
Switch(pipe) main;\n\
')

for row in [5]:
    # for level in range(8):
    for level in [3]:
        generate_code(row, level)
