CURRENT=`pwd`
NAME=`basename "$CURRENT"`

API=$CURRENT/API
common_p4=$CURRENT/common_p4

# echo $CURRENT
# echo $API
# # echo $common_p4

# $tofino/p4_build-9.0.0.sh $CURRENT/countmin/p416_countmin.p4 \
#     -- P4_NAME="p416_countmin" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/countsketch/p416_countsketch.p4 \
#     -- P4_NAME="p416_countsketch" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/fcm/p416_fcm.p4 \
#     -- P4_NAME="p416_fcm" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -D SIMULATOR=0"

# $tofino/p4_build-9.0.0.sh $CURRENT/univmon/p416_univmon.p4 \
#     -- P4_NAME="p416_univmon" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

$tofino/p4_build-9.0.0.sh $CURRENT/rhhh/p416_rhhh.p4 \
    -- P4_NAME="p416_rhhh" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/hll/p416_hll.p4 \
#     -- P4_NAME="p416_hll" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/mrac/p416_mrac.p4 \
#     -- P4_NAME="p416_mrac" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/mrb/p416_mrb.p4 \
#     -- P4_NAME="p416_mrb" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/pcsa/p416_pcsa.p4 \
#     -- P4_NAME="p416_pcsa" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/hhh/p416_hhh.p4 \
#     -- P4_NAME="p416_hhh" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/kary/p416_kary.p4 \
#     -- P4_NAME="p416_kary" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/loglog/p416_loglog.p4 \
#     -- P4_NAME="p416_loglog" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/sketchlearn/p416_sketchlearn.p4 \
#     -- P4_NAME="p416_sketchlearn" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh $CURRENT/spreadsketch/p416_spreadsketch.p4 \
#     -- P4_NAME="p416_spreadsketch" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
