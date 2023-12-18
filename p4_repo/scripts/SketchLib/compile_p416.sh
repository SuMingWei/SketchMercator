# p4_16
CURRENT=`pwd`
NAME=`basename "$CURRENT"`
API=${p4_repo}/p416/tofino/sketches/SketchLib/optimized/API
common_p4=${p4_repo}/p416/tofino/sketches/common_p4


# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_nfs_l2.p4 \
#     -- P4_NAME="p416_l2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_nfs_l3.p4 \
#     -- P4_NAME="p416_l3" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_nfs_lb.p4 \
#     -- P4_NAME="p416_lb" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_eval_l2_l3_lb.p4 \
#     -- P4_NAME="p416_univmon_eval_l2_l3_lb" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_l2.p4 \
#     -- P4_NAME="p416_univmon_l2" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_l3.p4 \
#     -- P4_NAME="p416_univmon_l3" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_lb.p4 \
#     -- P4_NAME="p416_univmon_lb" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_fw.p4 \
#     -- P4_NAME="p416_univmon_lb" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon_nfs.p4 \
#     -- P4_NAME="p416_univmon_eval_nfs" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"


# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/rhhh/p416_rhhh_nfs.p4 \
#     -- P4_NAME="p416_rhhh_eval_nfs" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=3"


# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/countmin/p416_countmin.p4 \
#     -- P4_NAME="p416_countmin_sim_0_hash_1_row_5" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

$tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/countsketch/p416_countsketch.p4 \
    -- P4_NAME="p416_countsketch_sim_0_hash_1_row_5" \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/fcm/p416_fcm.p4 \
#     -- P4_NAME="p416_fcm" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -D SIMULATOR=0"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/optimized/univmon/p416_univmon.p4 \
#     -- P4_NAME="p416_univmon_sim_0_hash_1_row_5" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=5"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/rhhh/p416_rhhh.p4 \
#     -- P4_NAME="p416_rhhh_sim_0_hash_1_row_3" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1 -D ROW=3"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/hll/p416_hll.p4 \
#     -- P4_NAME="p416_hll_sim_0_hash_1" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/mrac/p416_mrac.p4 \
#     -- P4_NAME="p416_mrac_sim_0_hash_1" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/mrb/p416_mrb.p4 \
#     -- P4_NAME="p416_mrb_sim_0_hash_1" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/pcsa/p416_pcsa.p4 \
#     -- P4_NAME="p416_pcsa_sim_0_hash_1" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4} -D SIMULATOR=0 -D HASH_SET=1"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/hhh/p416_hhh.p4 \
#     -- P4_NAME="p416_hhh" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/kary/p416_kary.p4 \
#     -- P4_NAME="p416_kary" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/loglog/p416_loglog.p4 \
#     -- P4_NAME="p416_loglog" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/sketchlearn/p416_sketchlearn.p4 \
#     -- P4_NAME="p416_sketchlearn" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh ${p4_repo}/p416/tofino/sketches/SketchLib/spreadsketch/p416_spreadsketch.p4 \
#     -- P4_NAME="p416_spreadsketch" \
#     P4FLAGS="--no-dead-code-elimination" \
#     P4PPFLAGS="-I ${API} -I ${common_p4}"
