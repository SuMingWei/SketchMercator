API=${p4_repo}/p416/tofino/sketches/SketchMD/idea4/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/common_p4


$script_home/p4_build.sh p416_set_1_idea4.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

#[set 1]

# fail
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_1_idea4_test1/make.log
# $script_home/p4_build.sh p416_set_1_idea4_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# fail
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_1_idea4_test2/make.log
# $script_home/p4_build.sh p416_set_1_idea4_test2.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# success but hash_in does not help
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_1_idea4_test3/make.log
# $script_home/p4_build.sh p416_set_1_idea4_test3.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# fail
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_1_idea4_test4/make.log
# $script_home/p4_build.sh p416_set_1_idea4_test4.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

#[set 2]
# success
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_2_idea4_test1/make.log
# $script_home/p4_build.sh p416_set_2_idea4_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# fail
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_2_idea4_test2/make.log
# $script_home/p4_build.sh p416_set_2_idea4_test2.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

#[set 3]
# fail
# vi /home/hnamkung/barefoot/bf-sde-9.5.1/logs/p4-build/p416_set_2_idea4_test2/make.log
# $script_home/p4_build.sh p416_set_3_idea4_test1.p4 \
#     -- P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
