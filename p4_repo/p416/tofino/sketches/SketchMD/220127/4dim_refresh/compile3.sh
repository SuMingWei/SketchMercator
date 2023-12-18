API=${p4_repo}/p416/tofino/sketches/SketchMD/4dim_refresh/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/4dim_refresh/common_p4

$script_home/p4_build.sh p416_4dim_test3.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_4dim_test3/make.log