API=${p4_repo}/p416/tofino/sketches/SketchMD/set_3_naive/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4

# # success
# $script_home/p4_build.sh p416_set_3_naive.p4 \
#     -- P4_NAME="p416_set_3_naive_um" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # success
# $script_home/p4_build.sh p416_set_3_naive.p4 \
#     -- P4_NAME="p416_set_3_naive_mrac_ss_um" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # success
# $script_home/p4_build.sh p416_set_3_naive.p4 \
#     -- P4_NAME="p416_set_3_naive_kary_um" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # # fail
# $script_home/p4_build.sh p416_set_3_naive.p4 \
#     -- P4_NAME="p416_set_3_naive_kary_ss_um" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"



# $script_home/p4_build.sh p416_set_3_naive_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_3_naive_test2.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_3_naive_test3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_3_naive_test4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_3_naive_test4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set_3_naive_test5.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
