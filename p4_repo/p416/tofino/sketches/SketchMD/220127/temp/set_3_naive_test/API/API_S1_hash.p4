#define PLAIN_HASH_KEY32(TOTAL_LENGTH, HASH_LENGTH)                 \
  control HASH_COMPUTE_KEY32_##TOTAL_LENGTH##_##HASH_LENGTH## (     \
    in bit<32> key,                                                 \
    out bit<##TOTAL_LENGTH##> result)(                              \
    bit<32> polynomial)                                             \
  {                                                                 \
      CRCPolynomial<bit<32>>(polynomial,                            \
                             true,                                  \
                             false,                                 \
                             false,                                 \
                             32w0xFFFFFFFF,                         \
                             32w0xFFFFFFFF                          \
                             ) poly1;                               \
                                                                    \
      Hash<bit<##HASH_LENGTH##>>(HashAlgorithm_t.CUSTOM, poly1) hash;\
                                                                    \
      action action_hash() {                                        \
          result = (bit<##TOTAL_LENGTH##>) hash.get({key});         \
      }                                                             \
                                                                    \
      table tbl_hash {                                              \
          actions = {                                               \
              action_hash;                                          \
          }                                                         \
          const default_action = action_hash();                     \
      }                                                             \
                                                                    \
     apply {                                                        \
          tbl_hash.apply();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32(16, 16)
PLAIN_HASH_KEY32(32, 10)
PLAIN_HASH_KEY32(32, 11)
PLAIN_HASH_KEY32(32, 15)
PLAIN_HASH_KEY32(32, 16)
PLAIN_HASH_KEY32(32, 32)

#define PLAIN_HASH_KEY32_KEY32(TOTAL_LENGTH, HASH_LENGTH)            \
  control HASH_COMPUTE_KEY32_KEY32_##TOTAL_LENGTH##_##HASH_LENGTH## (\
    in bit<32> key1,                                                \
    in bit<32> key2,                                                \
    out bit<##TOTAL_LENGTH##> result)(                              \
    bit<32> polynomial)                                             \
  {                                                                 \
      CRCPolynomial<bit<32>>(polynomial,                            \
                             true,                                  \
                             false,                                 \
                             false,                                 \
                             32w0xFFFFFFFF,                         \
                             32w0xFFFFFFFF                          \
                             ) poly1;                               \
                                                                    \
      Hash<bit<##HASH_LENGTH##>>(HashAlgorithm_t.CUSTOM, poly1) hash;\
                                                                    \
      action action_hash() {                                        \
          result = (bit<##TOTAL_LENGTH##>) hash.get({key1, key2});  \
      }                                                             \
                                                                    \
      table tbl_hash {                                              \
          actions = {                                               \
              action_hash;                                          \
          }                                                         \
          const default_action = action_hash();                     \
      }                                                             \
                                                                    \
     apply {                                                        \
          tbl_hash.apply();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32_KEY32(32, 16)
PLAIN_HASH_KEY32_KEY32(32, 32)
