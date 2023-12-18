CURRENT=`pwd`
NAME=`basename "$CURRENT"`
API=${p4_repo}/p416/tofino/sketches/SketchAug/API
common_p4=${p4_repo}/p416/tofino/sketches/common_p4


$tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}_pp.p4 -- P4_NAME="p416_${NAME}_pp" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}_pp_small.p4 -- P4_NAME="p416_${NAME}_pp_small" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4}"


# # HLL compile script
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_512_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=512 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_1024_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=1024 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_2048_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=2048 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -I ${API} -I ${common_p4}"

# # CS compile script
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_1_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -D ROW=1 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_2_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -D ROW=2 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_3_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -D ROW=3 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_4_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -D ROW=4 -I ${API} -I ${common_p4}"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_sketchaug_${NAME}_4096_5_hash_1" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=4096 -D ROW=5 -I ${API} -I ${common_p4}"

# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_small" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_large" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_4096_sim" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=1"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_4096" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_16384" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_32768" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_16384" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_65536" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_flowkey" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_2048" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_4096" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_8192" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_12288" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_16384" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_20480" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_32768" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_36864" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_65536" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=0"

# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -I/home/hnamkung/sketch_home/p4_repo/p416/tofino/sketches/hll"
# $tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}_01_sim" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIMULATOR=1"
