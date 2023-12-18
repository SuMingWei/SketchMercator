#include "mrb_iteration.h"

mrbIteration::mrbIteration()
{
}

void mrbIteration::init(parameters &params)
{
    sampling_hash = new HashSeedSet(25);
    for(int level=0; level<25; level++) {
        mrb_level.push_back(sketchTemplate(params, level));
    }
}

void mrbIteration::load_hash(parameters &params) {
    load_hash_seeds(*sampling_hash, mrb_level, params);
    for(int i = 0; i < 25; i++) {
        mrb_level[i].index_hash = mrb_level[0].index_hash;
        mrb_level[i].res_hash = mrb_level[0].res_hash;
    }
}

void mrbIteration::iteration(packet_summary &p, parameters &params)
{
    flowkey_t flowkey;
    get_flowkey(flowkey, p, params);
    uint32_t sh = sampling_hash->compute_hash(flowkey, params.flowkey_flags, 0, params.is_crc_hash, 33554432); // 33554432 = 2 ^25
    int last_level = get_last_level(sh, params.level-1);

    // printf("sh : 0x%x\n", sh&0xffff);
    // printf("sh : 0b");
    // for(int q=14; q>=0; q--) {
    //     printf("%d", ((sh >> q) & 1));
    // }
    // printf("\n");
    // printf("level : %d\n\n", last_level);

    mrb_level[last_level].mrb_sketch(flowkey, params);
    // exit(1);


    int elem = params.is_count_packet ? 1 : p.size;

    if (packetMap.find(flowkey) == packetMap.end()) {
        packetMap[flowkey] = elem;
    }
    else {
        packetMap[flowkey] = packetMap[flowkey] + elem;
    }
}

void mrbIteration::file_print(parameters &params)
{
    mrb_file_print(mrb_level, *sampling_hash, params, packetMap.size());
}

void mrbIteration::clear(parameters &params)
{
    for(int i = 0; i < 25; i++) {
        mrb_level[i].clear();
    }
    packetMap.clear();
}
