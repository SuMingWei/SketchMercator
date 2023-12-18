#define PLAIN_HASH(LENGTH, LENGTH_MINUS_ONE)                        \
  control HASH_COMPUTE_##LENGTH(                                    \
  	in ipv4_addr_t srcIP,                                           \
  	out bit<##LENGTH##> result)(                                    \
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
      Hash<bit<##LENGTH##>>(HashAlgorithm_t.CUSTOM, poly1) hash;    \
                                                                    \
      action action_hash() {                                        \
          result[##LENGTH_MINUS_ONE##:0] = hash.get({srcIP[31:0]}); \
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

PLAIN_HASH(16, 15)
