CURRENT=`pwd`
NAME=`basename "$CURRENT"`
API=${p4_repo}/p416/tofino/sketches/SketchMD/univmon/API
common_p4=${p4_repo}/p416/tofino/sketches/common_p4

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchMD/univmon/p416_test.p4 \
#     -- P4_NAME="p416_sketchmd_univmon_dim_1" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D DIM=1"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchMD/univmon/p416_test.p4 \
#     -- P4_NAME="p416_sketchmd_univmon_dim_2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D DIM=2"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchMD/univmon/p416_test.p4 \
#     -- P4_NAME="p416_sketchmd_univmon_dim_3" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D DIM=3"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchMD/univmon/p416_test.p4 \
#     -- P4_NAME="p416_sketchmd_univmon_dim_4" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D DIM=4"

$tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchMD/univmon/p416_test.p4 \
    -- P4_NAME="p416_sketchmd_univmon_dim_5" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4} -D DIM=5"
