API=${p4_repo}/p416/tofino/sketches/SketchMD/output/API
common_p4=${p4_repo}/p416/tofino/sketches/SketchMD/output/common_p4
echo $common_p4

$script_home/p4_build-9.0.0.sh p416_output.p4 \
    P4FLAGS="--no-dead-code-elimination" \
    P4PPFLAGS="-I ${API} -I ${common_p4}"
