date: 220130

[Purpose]
- does both_port using ++ work?

[Conclusion]
- Both port using ++ works pretty well. I checked with simulator.

[Dependency]
heavy_storage_test -> both_port_test

[Problem]
- four tuple: both_port_test_1
- five tuple: both_port_test_2

- 9.5.1 both four tuples and five tuples compiled okay
- 9.1.1 four tuples okay, but compilation error for both_port_test_2
-> I found out weired error. we can deal with this later or we can upgrade tofino hardware to newer version of 9.5.1.

27         out metadata_t ig_md,
 28                        ^^^^^
 29 /data/hun/p4_repo/p416/tofino/sketches/SketchMD/both_port_test/../common_p4/parser.p4(1)
 30 parser SwitchIngressParser(
 31        ^^^^^^^^^^^^^^^^^^^
 32 In file: /bf-sde/submodules/bf-p4c-compilers/p4c/extensions/bf-p4c/phv/allocate_phv.cpp:2714
 33 ^[[31mCompiler Bug^[[0m: The compiler failed in slicing the following group of fields related by parser alignment and MAU constraints
 34 SUPERCLUSTER Uid: 279
 35     slice lists:
 36         [ ingress::hdr.ipv4.hdr_checksum<16> ^0 ^bit[0..95] deparsed exact_containers [0:15]
 37           ingress::hdr.ipv4.protocol<8> ^0 ^bit[0..79] deparsed exact_containers [0:7]
 38           ingress::hdr.ipv4.ttl<8> ^0 ^bit[0..71] deparsed exact_containers [0:7] ]
 39         [ ingress::hdr.cpu.proto<8> ^0 deparsed exact_containers [0:7]
 40           ingress::hdr.cpu.both_port<32> ^0 deparsed exact_containers [0:15]
 41           ingress::hdr.cpu.both_port<32> ^0 deparsed exact_containers [16:31] ]
 42         [ ingress::d_1_heavy_flowkey_entry_proto<8> meta [0:7] ]
 43         [ ingress::d_1_heavy_flowkey_entry_both_port<32> meta [0:15]
 44           ingress::d_1_heavy_flowkey_entry_both_port<32> meta [16:31] ]
 45         [ ingress::ig_md.src_port<16> ^0 ^bit[0..15] meta [0:15] ]
 46     rotational clusters:
 47         [[ingress::hdr.ipv4.hdr_checksum<16> ^0 ^bit[0..95] deparsed exact_containers [0:15]]]
 48         [[ingress::hdr.cpu.proto<8> ^0 deparsed exact_containers [0:7]], [ingress::hdr.ipv4.protocol<8> ^0 ^bit[0..79] deparsed exact_containers [0:7], ingress::d_1_heavy_flowkey_entry_proto<8> m    eta [0:7]]]
 49         [[ingress::hdr.ipv4.ttl<8> ^0 ^bit[0..71] deparsed exact_containers [0:7]]]
 50         [[ingress::hdr.cpu.both_port<32> ^0 deparsed exact_containers [16:31], ingress::d_1_heavy_flowkey_entry_both_port<32> meta [16:31]], [ingress::ig_md.src_port<16> ^0 ^bit[0..15] meta [0:15    ]], [ingress::hdr.cpu.both_port<32> ^0 deparsed exact_containers [0:15], ingress::d_1_heavy_flowkey_entry_both_port<32> meta [0:15]]]
 51 
 52 
 53 No valid sections found in assembly file
 54 failed command assembler
