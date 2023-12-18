# # p4_14

common_p4=${p4_repo}/p414/tofino/sketches/common_p4
API=${p4_repo}/p414/tofino/sketches/SketchLib/API

# $tofino/p4_build-9.0.0.sh  ${p4_repo}/p414/tofino/sketches/SketchLib/countmin/p414_countmin.p4 \
#     -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination"\
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D ROW=5 -D WIDTH=2048 -D WIDTH_BIT_LEN=11"

# $tofino/p4_build-9.0.0.sh  ${p4_repo}/p414/tofino/sketches/SketchLib/fcm/p414_fcm.p4 \
#     -- P4_NAME="p414_fcm" P4FLAGS="--no-dead-code-elimination"

API=${p4_repo}/p414/tofino/sketches/SketchLib/fcm/API
$tofino/p4_build-9.0.0.sh  ${p4_repo}/p414/tofino/sketches/SketchLib/fcm/p414_fcm_O6.p4 \
    -- P4_NAME="p414_fcm_O6" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API}"

# $tofino/p4_build-9.0.0.sh  ${p4_repo}/p414/tofino/sketches/SketchLib/fcm/p414_fcm_topk.p4 \
#     -- P4_NAME="p414_fcm_topk" P4FLAGS="--no-dead-code-elimination"
