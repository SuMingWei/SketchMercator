API=$(pwd)/../API
common_p4=$(pwd)/../common_p4
NAME="p416_hash_bit_mask_test_"

if [ $1 == "t1" ]
then
$script_home/p4_build.sh ${NAME}$2.p4 \
    -- P4_NAME=${NAME}${2}_tofino1 \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
fi

if [ $1 == "t2" ]
then
$script_home/p4_build.sh ${NAME}$2.p4 --with-tofino2 \
    -- P4_NAME=${NAME}${2}_tofino2 \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
fi
