EXP_NAME="SketchAug"
SKETCH_NAME="hll"
HASH_SET_NUM=1

WIDTH=512
python $sketch_home/tofino_control_plane/python/tofino_main.py --exp_name $EXP_NAME --sketch_name $SKETCH_NAME --width $WIDTH --hash_set_num=$HASH_SET_NUM --ports --configure

# WIDTH=1024
# python $sketch_home/tofino_control_plane/python/tofino_main.py --exp_name $EXP_NAME --sketch_name $SKETCH_NAME --width $WIDTH --hash_set_num=$HASH_SET_NUM --ports --configure

# WIDTH=2048
# python $sketch_home/tofino_control_plane/python/tofino_main.py --exp_name $EXP_NAME --sketch_name $SKETCH_NAME --width $WIDTH --hash_set_num=$HASH_SET_NUM --ports --configure

# WIDTH=4096
# python $sketch_home/tofino_control_plane/python/tofino_main.py --exp_name $EXP_NAME --sketch_name $SKETCH_NAME --width $WIDTH --hash_set_num=$HASH_SET_NUM --ports --configure
