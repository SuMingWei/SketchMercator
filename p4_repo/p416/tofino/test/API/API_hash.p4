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

PLAIN_HASH(5, 4)
PLAIN_HASH(11, 10)
PLAIN_HASH(12, 11)
PLAIN_HASH(15, 14)
PLAIN_HASH(16, 15)
PLAIN_HASH(20, 19)

control HASH_COMPUTE_11_ADD_BASE(
  in ipv4_addr_t srcIP,
  in bit<16> base,
  out bit<16> result)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<11>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action action_hash() {
        result = (bit<16>) hash.get({srcIP[31:0]});
    }

    table tbl_hash {
        actions = {
            action_hash;
        }
        const default_action = action_hash();
    }

   apply {
        tbl_hash.apply();
        result = result + base;
        // tbl_add.apply();
    }
}

control HASH_COMPUTE_5_SPLIT(
  in ipv4_addr_t srcIP,
  out bit<5> res_all,
  out bit<1> res_1,
  out bit<1> res_2,
  out bit<1> res_3,
  out bit<1> res_4,
  out bit<1> res_5)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<5>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action action_hash() {
        res_all = hash.get({srcIP[31:0]});
    }

    table tbl_hash {
        actions = {
            action_hash;
        }
        const default_action = action_hash();
    }

   apply {
        tbl_hash.apply();
        res_1 = res_all[0:0];
        res_2 = res_all[1:1];
        res_3 = res_all[2:2];
        res_4 = res_all[3:3];
        res_5 = res_all[4:4];
    }
}

control HASH_COMPUTE_14_SPLIT(
  in ipv4_addr_t srcIP,
  out bit<14> res_all,
  out bit<1> res_1,
  out bit<1> res_2,
  out bit<1> res_3,
  out bit<1> res_4,
  out bit<1> res_5)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<14>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action action_hash() {
        res_all = hash.get({srcIP[31:0]});
    }

    table tbl_hash {
        actions = {
            action_hash;
        }
        const default_action = action_hash();
    }

   apply {
        tbl_hash.apply();
        res_1 = res_all[0:0];
        res_2 = res_all[1:1];
        res_3 = res_all[2:2];
        res_4 = res_all[3:3];
        res_5 = res_all[4:4];
    }
}

control HASH_COMPUTE_16_SPLIT(
  in ipv4_addr_t srcIP,
  out bit<16> res_all,
  out bit<1> res_1,
  out bit<1> res_2,
  out bit<1> res_3,
  out bit<1> res_4,
  out bit<1> res_5)(
  bit<32> polynomial)
{
    CRCPolynomial<bit<32>>(polynomial,
                           true,
                           false,
                           false,
                           32w0xFFFFFFFF,
                           32w0xFFFFFFFF
                           ) poly1;

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action action_hash() {
        res_all = hash.get({srcIP[31:0]});
    }

    table tbl_hash {
        actions = {
            action_hash;
        }
        const default_action = action_hash();
    }

   apply {
        tbl_hash.apply();
        res_1 = res_all[0:0];
        res_2 = res_all[1:1];
        res_3 = res_all[2:2];
        res_4 = res_all[3:3];
        res_5 = res_all[4:4];
    }
}