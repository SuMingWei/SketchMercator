current=`pwd`
sample_number=`basename "$current"`

inst_number_folder=`dirname "$current"`
inst_number=`basename "$inst_number_folder"`

workload_folder=`dirname "$inst_number_folder"`
workload_name=`basename "$workload_folder"`

file_name=p416_${workload_name}_${inst_number}_${sample_number}_$1_$3.p4
P4_NAME=p416_${workload_name}_${inst_number}_${sample_number}_$1_$3_hash_$4

API=${p4_repo}/SketchMD/API
common_p4=${p4_repo}/SketchMD/common_p4


if [ -z "$1" ]; then
    echo "comp.sh before/after t1/t2 trial hash_set#"
  else
    if [ "$2" = "t1" ]; then
        echo p4_build.sh ${current}/${file_name} -- P4_NAME=${P4_NAME}_tofino1 P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=$4 -I ${API} -I ${common_p4}"
        $script_home/p4_build.sh ${current}/${file_name} \
            -- P4_NAME=${P4_NAME}_tofino1 \
            P4FLAGS="--no-dead-code-elimination" \
            P4PPFLAGS="-D HASH_SET=$4 -I ${API} -I ${common_p4}"
    fi

    if [ "$2" = "t2" ]; then
        echo p4_build.sh ${current}/${file_name} --with-tofino2 -- P4_NAME=${P4_NAME}_tofino2 P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-D HASH_SET=$4 -I ${API} -I ${common_p4}"
        $script_home/p4_build.sh ${current}/${file_name} --with-tofino2 \
            -- P4_NAME=${P4_NAME}_tofino2 \
            P4FLAGS="--no-dead-code-elimination" \
            P4PPFLAGS="-D HASH_SET=$4 -I ${API} -I ${common_p4}"
    fi
fi

