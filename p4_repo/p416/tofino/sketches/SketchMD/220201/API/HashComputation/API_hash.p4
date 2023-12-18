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
      apply {                                                        \
          action_hash();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32(16, 10)
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
      apply {                                                        \
          action_hash();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32_KEY32(16, 10)
PLAIN_HASH_KEY32_KEY32(16, 16)
PLAIN_HASH_KEY32_KEY32(32, 16)
PLAIN_HASH_KEY32_KEY32(32, 32)


#define PLAIN_HASH_KEY32_KEY32_KEY16(TOTAL_LENGTH, HASH_LENGTH)            \
  control HASH_COMPUTE_KEY32_KEY32_KEY16_##TOTAL_LENGTH##_##HASH_LENGTH## (\
    in bit<32> key1,                                                \
    in bit<32> key2,                                                \
    in bit<16> key3,                                                \
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
          result = (bit<##TOTAL_LENGTH##>) hash.get({key1, key2, key3});  \
      }                                                             \
                                                                    \
      apply {                                                        \
          action_hash();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32_KEY32_KEY16(16, 16)


#define PLAIN_HASH_KEY32_KEY32_KEY16_KEY16(TOTAL_LENGTH, HASH_LENGTH)            \
  control HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_##TOTAL_LENGTH##_##HASH_LENGTH## (\
    in bit<32> key1,                                                \
    in bit<32> key2,                                                \
    in bit<16> key3,                                                \
    in bit<16> key4,                                                \
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
          result = (bit<##TOTAL_LENGTH##>) hash.get({key1, key2, key3, key4});  \
      }                                                             \
                                                                    \
      apply {                                                        \
          action_hash();                                         \
      }                                                             \
  }

PLAIN_HASH_KEY32_KEY32_KEY16_KEY16(16, 10)
PLAIN_HASH_KEY32_KEY32_KEY16_KEY16(16, 16)
PLAIN_HASH_KEY32_KEY32_KEY16_KEY16(32, 16)
