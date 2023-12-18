#define PLAIN_HASH(LENGTH)                        \
  control HASH_COMPUTE_##LENGTH## (                                 \
  	in ipv4_addr_t key,                                           \
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
          result = hash.get({key}); \
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

PLAIN_HASH(32)
