API=$(pwd)/../API
common_p4=$(pwd)/../common_p4

$script_home/p4_build.sh p416_multiple_cs_$1.p4 \
    -- P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"