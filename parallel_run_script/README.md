# parallel_run_script

## `control_plane/`
run `$sketch_home/sketch_control_plane` in parallel

- `$sketch_home/parallel_run_script/control_plane/QuerySketch/select_param/run_parallel_cp_main.py`
It's used to generate control plane result for `QuerySketch (SketchMercator)`.

## `data_plane/`
run `$sketch_home/sw_dp_simulator` in parallel

- `$sketch_home/parallel_run_script/data_plane/QuerySketch/select_params/run_parallel_dp_main.py`
It's used to generate data plane result for `QuerySketch (SketchMercator)`.

## `QuerySketch/`
Automatically generates code for plotting scripts in `$sketch_home/result_plots/QuerySketch`

