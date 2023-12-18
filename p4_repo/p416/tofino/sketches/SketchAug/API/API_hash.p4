#define PLAIN_HASH(HASH_LENGTH, TOTAL_LENGTH)                       \
  control HASH_COMPUTE_##HASH_LENGTH##_##TOTAL_LENGTH## (           \
  	in ipv4_addr_t srcIP,                                           \
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
          result = (bit<##TOTAL_LENGTH##>) hash.get({srcIP});       \
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

PLAIN_HASH(15, 15)
PLAIN_HASH(16, 16)
PLAIN_HASH(8, 16)
PLAIN_HASH(9, 16)
PLAIN_HASH(10, 16)
PLAIN_HASH(11, 16)
PLAIN_HASH(12, 16)
PLAIN_HASH(20, 20)


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
    }
}

control HASH_COMPUTE_16_SPLIT_RHHH(
  in ipv4_addr_t srcIP,
  in ipv4_addr_t dstIP,
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
        res_all = hash.get({srcIP[31:0], dstIP[31:0]});
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

control HASH_COMPUTE_11_ADD_BASE_RHHH(
  in ipv4_addr_t srcIP,
  in ipv4_addr_t dstIP,
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
        result = (bit<16>) hash.get({srcIP[31:0], dstIP[31:0]});
        // result = result + base;
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
    }
}
