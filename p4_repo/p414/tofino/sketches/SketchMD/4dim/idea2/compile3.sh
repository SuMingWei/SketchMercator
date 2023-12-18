CURRENT=`pwd`

API=$CURRENT/../API
common_p4=$CURRENT/../common_p4

$script_home/p4_build.sh $CURRENT/p414_set_3_4dim_idea2.p4 \
    -- P4_NAME="p414_set_3_4dim_idea2" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

