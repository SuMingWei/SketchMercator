API=${p4_repo}/p416/tofino/sketches/SketchMD/4dim/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/4dim/common_p4

# $script_home/p4_build.sh p416_4dim_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$script_home/p4_build.sh p416_4dim_test2.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_4dim_test3/make.log

# $script_home/p4_build.sh p416_4dim_test3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test5.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test6.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test7.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test9.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $script_home/p4_build.sh p416_4dim_test10.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
