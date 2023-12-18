API=${p4_repo}/p416/tofino/sketches/SketchMD/4dim_refresh_2/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/4dim_refresh_2/common_p4

$script_home/p4_build.sh p416_4dim_test6.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

