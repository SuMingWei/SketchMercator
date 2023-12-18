# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --ports
# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --configure

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --ports --configure
# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --str_args_1 timer_ready
python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --ports --configure --read --str_args_1 timer_ready

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --str_args_1 epoch_counter

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --str_args_1 clear

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --str_args_1 counters
# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --int_args_1 4096
# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --ports --configure
# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name mrb --read --int_args_1 4096
