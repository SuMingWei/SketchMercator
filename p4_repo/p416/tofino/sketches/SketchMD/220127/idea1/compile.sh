API=${p4_repo}/p416/tofino/sketches/SketchMD/idea1/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4

$script_home/p4_build.sh p416_set_1_idea1.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set_2_idea1.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
