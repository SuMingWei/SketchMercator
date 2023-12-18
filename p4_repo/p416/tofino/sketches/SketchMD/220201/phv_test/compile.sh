API=${p4_repo}/p416/tofino/sketches/SketchMD/220127/phv_test/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/220127/phv_test/common_p4

# # Success
# $script_home/p4_build.sh p416_phv_test_1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Success
# $script_home/p4_build.sh p416_phv_test_2.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Success
# $script_home/p4_build.sh p416_phv_test_3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # # Fail
# $script_home/p4_build.sh p416_phv_test_4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Fail due to hash_1 split
# $script_home/p4_build.sh p416_phv_test_5.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Fail not 16 supported
# $script_home/p4_build.sh p416_phv_test_6.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Fail not 12 supported
# $script_home/p4_build.sh p416_phv_test_7.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Success! 8 is supported
# $script_home/p4_build.sh p416_phv_test_8.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Success! 11 is supported
# $script_home/p4_build.sh p416_phv_test_9.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # Fail!
# $script_home/p4_build.sh p416_phv_test_10.p4 --with-tofino2 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_phv_test_11.p4 --with-tofino2 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
