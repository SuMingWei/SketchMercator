CURRENT=`pwd`
NAME=`basename "$CURRENT"`

API=$CURRENT/API
common_p4=$CURRENT/common_p4

$tofino/p4_build-9.0.0.sh $CURRENT/countsketch/p414_countsketch.p4 \
    -- P4_NAME="p414_countsketch" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
