# I1. Flowkey
# I2. Flowsize
# I3. Epoch
# I4. Sketch Parameters (# of Rows)

# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_flowkey.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_flowsize.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_epoch.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_sketch_parameter.pkl --run gd --type1 bf --type2 bf

# B1. Index Computing Type
# B2. Counter Update Type
# B3. Counter Value in DP
# B4. Sampling Compatible
# B5. Heavy Flowkey Storage

# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_counter_update_type.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_index_couputing_type.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_counter_value_in_dp.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_sampling_compatible.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/sensitivity2/input --out ../workload_manage/sensitivity2/output --filename workload_varing_heavy_flowkey.pkl --run gd --type1 bf --type2 bf

# python workload_main.py --folder ../workload_manage/random2/input --out ../workload_manage/random2/output --filename default_random_workload.pkl --run bf
# python workload_main.py --folder ../workload_manage/random2/input --out ../workload_manage/random2/output --filename default_random_workload.pkl --run gd --type1 bf --type2 bf
# python workload_main.py --folder ../workload_manage/random2/input --out ../workload_manage/random2/output --filename default_random_workload.pkl --run gd --type1 gd --type2 bf
# python workload_main.py --folder ../workload_manage/random2/input --out ../workload_manage/random2/output --filename default_random_workload.pkl --run gd --type1 bf --type2 gd
# python workload_main.py --folder ../workload_manage/random2/input --out ../workload_manage/random2/output --filename default_random_workload.pkl --run gd --type1 gd --type2 gd

python workload_point.py --folder ../workload_manage/landscape/input --out ../workload_manage/landscape/output --filename landscape.pkl --run gd --type1 bf --type2 bf
