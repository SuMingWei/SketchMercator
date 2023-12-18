# # p4_14
# common_p4=${p4_repo}/p414/tofino/sketches/common_p4
# API=${p4_repo}/p414/tofino/sketches/SketchLib/API

# $tofino/p4_build-9.0.0.sh  ${p4_repo}/p414/tofino/sketches/SketchLib/fcm/p414_fcm_topk.p4 \
#     -- P4_NAME="p414_fcm_topk" P4FLAGS="--no-dead-code-elimination"


# p4_16
common_p4=${p4_repo}/p416/tofino/sketches/common_p4
API=${p4_repo}/p416/tofino/sketches/SketchLib/API

CURRENT=${p4_repo}/p416/tofino/sketches/SketchLib/fcm_vs_countmin
API=$CURRENT/countmin/API

$tofino/p4_build-9.0.0.sh $CURRENT/countmin/p416_eval_countmin.p4 \
    -- P4_NAME="p416_eval_countmin" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0"


# API=$CURRENT/fcm/API

# $tofino/p4_build-9.0.0.sh $CURRENT/fcm/p416_eval_fcm.p4 \
#     -- P4_NAME="p416_eval_fcm" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API}"
