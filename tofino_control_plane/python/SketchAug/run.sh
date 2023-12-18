# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name cs --mode baseline --tcp

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name cs --mode sol3 --array_size 16384 --tcp

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name cs --mode pingpong --array_size 1024 --tcp

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name univmon --mode baseline --tcp

# python $sketch_home/tofino_control_plane/python/tofino_main.py --sketch_name hll --mode baseline --tcp

# python $sketch_home/tofino_control_plane/python/SketchAug/tofino_main.py --sketch_name cs --mode baseline --tcp

# python $sketch_home/tofino_control_plane/python/SketchAug/tofino_main.py --sketch_name cm --mode baseline --tcp

# python $sketch_home/tofino_control_plane/python/SketchAug/tofino_main.py --sketch_name univmon --mode pingpong --tcp


# python $sketch_home/tofino_control_plane/python/SketchAug/test_main.py --test_name hw_behave --ports

python $sketch_home/tofino_control_plane/python/SketchAug/tofino_main.py --sketch_name cm --mode baseline --array_size 1024 --tcp
