CURRENT=`pwd`

API=$CURRENT/../API
common_p4=$CURRENT/../common_p4
sketches=$CURRENT/../sketches

$script_home/p4_build.sh $CURRENT/p414_set_1_4dim_naive.p4 \
    -- P4_NAME="p414_set_1_4dim_naive" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4} -I ${sketches}"

