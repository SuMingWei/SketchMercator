
// control T1_KEY_UPDATE_211_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key1, key2, key3, key4}));\
//     }} \
// control T1_KEY_UPDATE_210_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T1_KEY_UPDATE_201_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T1_KEY_UPDATE_121_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key2, key3, key4, key5}));\
//     }} \
// control T1_KEY_UPDATE_120_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T1_KEY_UPDATE_111_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T1_KEY_UPDATE_101_##SIZE##( \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key2, key3}));\
//     }} \
// control T1_KEY_UPDATE_021_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key3, key4, key5}));\
//     }} \
// control T1_KEY_UPDATE_020_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T1_KEY_UPDATE_011_##SIZE##( \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T1_KEY_UPDATE_001_##SIZE##( \
//     in bit<8> key3, \
//     T1_UPDATE_CORE(SIZE, BITLEN) \
//     est = t1_ca_action.execute(hash.get({key3}));\
//     }} \




// control T2_KEY_UPDATE_211_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key1, key2, key3, key4}));\
//     }} \
// control T2_KEY_UPDATE_210_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T2_KEY_UPDATE_201_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T2_KEY_UPDATE_121_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key2, key3, key4, key5}));\
//     }} \
// control T2_KEY_UPDATE_120_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T2_KEY_UPDATE_111_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T2_KEY_UPDATE_101_##SIZE##( \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key2, key3}));\
//     }} \
// control T2_KEY_UPDATE_021_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key3, key4, key5}));\
//     }} \
// control T2_KEY_UPDATE_020_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T2_KEY_UPDATE_011_##SIZE##( \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T2_KEY_UPDATE_001_##SIZE##( \
//     in bit<8> key3, \
//     T2_UPDATE_CORE(SIZE, BITLEN) \
//     est = t2_ca_action.execute(hash.get({key3}));\
//     }} \


// control T3_KEY_UPDATE_211_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key1, key2, key3, key4}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_210_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key1, key2, key3}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_201_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key1, key2, key3}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_121_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key2, key3, key4, key5}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_120_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key2, key3, key4}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_111_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key2, key3, key4}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_101_##SIZE##( \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key2, key3}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_021_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key3, key4, key5}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_020_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key3, key4}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_011_##SIZE##( \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key3, key4}));\
//     T3_UPDATE_END() \
// control T3_KEY_UPDATE_001_##SIZE##( \
//     in bit<8> key3, \
//     T3_UPDATE_CORE(SIZE, BITLEN) \
//     est = t3_ca_action.execute(hash.get({key3}));\
//     T3_UPDATE_END() \



// control T4_KEY_UPDATE_211_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key1, key2, key3, key4}));\
//     }} \
// control T4_KEY_UPDATE_210_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T4_KEY_UPDATE_201_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T4_KEY_UPDATE_121_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key2, key3, key4, key5}));\
//     }} \
// control T4_KEY_UPDATE_120_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T4_KEY_UPDATE_111_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T4_KEY_UPDATE_101_##SIZE##( \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key2, key3}));\
//     }} \
// control T4_KEY_UPDATE_021_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key3, key4, key5}));\
//     }} \
// control T4_KEY_UPDATE_020_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T4_KEY_UPDATE_011_##SIZE##( \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T4_KEY_UPDATE_001_##SIZE##( \
//     in bit<8> key3, \
//     T4_UPDATE_CORE(SIZE, BITLEN) \
//     est = t4_ca_action.execute(hash.get({key3}));\
//     }} \


// control T5_KEY_UPDATE_211_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key1, key2, key3, key4}));\
//     }} \
// control T5_KEY_UPDATE_210_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T5_KEY_UPDATE_201_##SIZE##( \
//     in bit<32> key1, \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key1, key2, key3}));\
//     }} \
// control T5_KEY_UPDATE_121_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key2, key3, key4, key5}));\
//     }} \
// control T5_KEY_UPDATE_120_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T5_KEY_UPDATE_111_##SIZE##( \
//     in bit<32> key2, \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key2, key3, key4}));\
//     }} \
// control T5_KEY_UPDATE_101_##SIZE##( \
//     in bit<32> key2, \
//     in bit<8> key3, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key2, key3}));\
//     }} \
// control T5_KEY_UPDATE_021_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     in bit<8> key5, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key3, key4, key5}));\
//     }} \
// control T5_KEY_UPDATE_020_##SIZE##( \
//     in bit<16> key3, \
//     in bit<16> key4, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T5_KEY_UPDATE_011_##SIZE##( \
//     in bit<16> key3, \
//     in bit<8> key4, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key3, key4}));\
//     }} \
// control T5_KEY_UPDATE_001_##SIZE##( \
//     in bit<8> key3, \
//     T5_UPDATE_CORE(SIZE, BITLEN) \
//     est = t5_ca_action.execute(hash.get({key3}));\
//     }} \

