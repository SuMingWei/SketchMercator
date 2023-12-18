API=${p4_repo}/p416/tofino/sketches/SketchMD/set_2_naive/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4

# # success
# $script_home/p4_build-9.0.0.sh p416_set_2_naive.p4 \
#     -- P4_NAME="p416_set_2_naive_cm_hll_mrac_kary_ss" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# # fail
# $script_home/p4_build-9.0.0.sh p416_set_2_naive.p4 \
#     -- P4_NAME="p416_set_2_naive_cm_ent_hll_mrac_kary_ss" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set_2_naive.p4 \
    -- P4_NAME="p416_set_2_naive" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
