API=${p4_repo}/p416/tofino/sketches/SketchMD/220127/hash_combination_test/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/220127/hash_combination_test/common_p4

# Fail
# $script_home/p4_build.sh p416_hash_combination_test_1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
# $script_home/p4_build.sh p416_hash_combination_test_2.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Fail
# $script_home/p4_build.sh p416_hash_combination_test_3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
# $script_home/p4_build.sh p416_hash_combination_test_4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
# $script_home/p4_build.sh p416_hash_combination_test_5.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Fail
# $script_home/p4_build.sh p416_hash_combination_test_6.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Fail
# $script_home/p4_build.sh p416_hash_combination_test_7.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"


# # Fail
# $script_home/p4_build.sh p416_hash_combination_test_1.p4 --with-tofino2 \
#     -- P4_NAME="p416_hash_combination_test_1_tofino2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
$script_home/p4_build.sh p416_hash_combination_test_2.p4 --with-tofino2 \
    -- P4_NAME="p416_hash_combination_test_2_tofino2" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Didn't check
# $script_home/p4_build.sh p416_hash_combination_test_3.p4 --with-tofino2 \
#     -- P4_NAME="p416_hash_combination_test_3_tofino2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
$script_home/p4_build.sh p416_hash_combination_test_4.p4 --with-tofino2 \
    -- P4_NAME="p416_hash_combination_test_4_tofino2" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# Success
$script_home/p4_build.sh p416_hash_combination_test_5.p4 --with-tofino2 \
    -- P4_NAME="p416_hash_combination_test_5_tofino2" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Didn't check
# $script_home/p4_build.sh p416_hash_combination_test_6.p4 --with-tofino2 \
#     -- P4_NAME="p416_hash_combination_test_6_tofino2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Didn't check
# $script_home/p4_build.sh p416_hash_combination_test_7.p4 --with-tofino2 \
#     -- P4_NAME="p416_hash_combination_test_7_tofino2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
