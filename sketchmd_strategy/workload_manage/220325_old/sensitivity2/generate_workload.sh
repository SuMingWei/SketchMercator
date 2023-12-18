# I1. Flowkey
# I2. Flowsize
# I3. Epoch
# I4. Sketch Parameters (# of Rows)

# python3 workload_generator.py --folder input --filename workload_varing_flowkey.pkl --data_count 50
# python3 workload_generator.py --folder input --filename workload_varing_flowsize.pkl --data_count 50
# python3 workload_generator.py --folder input --filename workload_varing_epoch.pkl --data_count 50

# python3 workload_generator.py --folder input --filename workload_varing_sketch_parameter.pkl --data_count 50

# # B1. Index Computing Type
# # B2. Counter Update Type
# # B3. Counter Value in DP
# # B4. Sampling Compatible
# # B5. Heavy Flowkey Storage

python3 workload_generator.py --folder input --filename workload_varing_counter_update_type.pkl --data_count 50

# python3 workload_generator.py --folder input --filename workload_varing_index_couputing_type.pkl --data_count 50
# python3 workload_generator.py --folder input --filename workload_varing_counter_value_in_dp.pkl --data_count 50
# python3 workload_generator.py --folder input --filename workload_varing_sampling_compatible.pkl --data_count 50
# python3 workload_generator.py --folder input --filename workload_varing_heavy_flowkey.pkl --data_count 50
