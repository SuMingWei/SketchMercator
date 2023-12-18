current=`pwd`
folder_name=`basename "$current"`
workload_folder=`dirname "$current"`
folder_name2=`basename "$workload_folder"`

file_name=p416_${folder_name2}_${folder_name}.p4
P4_NAME=p416_${folder_name2}_${folder_name}

API=${p4_repo}/SketchMD/API
common_p4=${p4_repo}/SketchMD/common_p4


echo p4_build.sh ${current}/${file_name} -- P4_NAME=${P4_NAME}_tofino1 P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4}"
$script_home/p4_build.sh ${current}/${file_name} \
    -- P4_NAME=${P4_NAME}_tofino1 \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"

