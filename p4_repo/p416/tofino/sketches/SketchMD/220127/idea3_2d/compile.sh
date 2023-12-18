API=${p4_repo}/p416/tofino/sketches/SketchMD/idea3_2d/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4

$script_home/p4_build.sh p416_set_1_idea3_2d.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_1_idea3_2d_test1/make.log
# $script_home/p4_build.sh p416_set_1_idea3_2d_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_2_idea3_2d.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_set_3_idea3_2d.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
