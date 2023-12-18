API=${p4_repo}/p416/tofino/sketches/SketchMD/set3/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/set3/common_p4

# $script_home/p4_build.sh p416_set3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_set3_no_pragma.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
