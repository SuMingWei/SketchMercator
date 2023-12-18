control HASH_COMPUTE_KEY32_STAGE0_16_10 (
  in bit<32> key,
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

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 0
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}


control HASH_COMPUTE_KEY32_STAGE1_16_10 (
  in bit<32> key,
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

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 1
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_STAGE2_16_10 (
  in bit<32> key,
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

    Hash<bit<10>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 2
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}



control HASH_COMPUTE_KEY32_STAGE0_16_16 (
  in bit<32> key,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 0
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_STAGE1_16_16 (
  in bit<32> key,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 1
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_STAGE2_16_16 (
  in bit<32> key,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key});
    }
    @pragma stage 2
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_STAGE0_16_16 (
  in bit<32> key1,
  in bit<32> key2,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2});
    }
    @pragma stage 0
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_STAGE2_16_16 (
  in bit<32> key1,
  in bit<32> key2,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2});
    }
    @pragma stage 2
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_STAGE3_16_16 (
  in bit<32> key1,
  in bit<32> key2,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2});
    }
    @pragma stage 3
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_KEY16_STAGE0_16_16 (
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2, key3});
    }
    @pragma stage 0
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE0_16_16 (
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
  in bit<16> key4,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2, key3, key4});
    }
    @pragma stage 0
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE3_16_16 (
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
  in bit<16> key4,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2, key3, key4});
    }
    @pragma stage 3
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}

control HASH_COMPUTE_KEY32_KEY32_KEY16_KEY16_STAGE4_16_16 (
  in bit<32> key1,
  in bit<32> key2,
  in bit<16> key3,
  in bit<16> key4,
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

    Hash<bit<16>>(HashAlgorithm_t.CUSTOM, poly1) hash;

    action hash_table_act()
    {
        result = (bit<16>) hash.get({key1, key2, key3, key4});
    }
    @pragma stage 4
    table hash_table {
        actions = {
            hash_table_act;
        }
        const default_action = hash_table_act;
    }

    apply {
        hash_table.apply();
    }
}


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
