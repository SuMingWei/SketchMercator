CURRENT=`pwd`
NAME=`basename "$CURRENT"`

API=$CURRENT/countmin/API
common_p4=${p4_repo}/p416/tofino/sketches/common_p4

# echo $CURRENT
# echo $API
# echo $common_p4

$tofino/p4_build-9.0.0.sh $CURRENT/countmin/p416_eval_countmin.p4 \
    -- P4_NAME="p416_eval_countmin" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"


# API=$CURRENT/fcm/API

# $tofino/p4_build-9.0.0.sh $CURRENT/fcm/p416_eval_fcm.p4 \
#     -- P4_NAME="p416_eval_fcm" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API}"
