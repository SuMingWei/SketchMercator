CURRENT=`pwd`
NAME=`basename "$CURRENT"`
API=${p4_repo}/p416/tofino/sketches/API
common_p4=${p4_repo}/p416/tofino/sketches/common_p4


$tofino/p4_build-9.0.0.sh  $CURRENT/p416_${NAME}.p4 -- P4_NAME="p416_${NAME}" P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=1 -D SIZE=512 -I ${API} -I ${common_p4}"
