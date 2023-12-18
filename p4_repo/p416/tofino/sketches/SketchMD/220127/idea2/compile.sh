API=${p4_repo}/p416/tofino/sketches/SketchMD/idea2/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4

$script_home/p4_build.sh p416_set_1_idea2.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set_2_idea2.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set_3_idea2.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
