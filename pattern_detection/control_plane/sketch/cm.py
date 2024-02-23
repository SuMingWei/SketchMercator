import os
from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.file_io.py.common import parse_line
from sw_dp_simulator.hash_module.py.hash import compute_hash
from pattern_detection.control_plane.sketch.common import write_variation_file
from pattern_detection.control_plane.sketch.common import write_summation_file

def counter_estimate(key, sketch_array, index_hash_sub_list, d, w, hash, level):
    a = []

    for i in range(0, d):
        index = compute_hash(key, hash, index_hash_sub_list[i], w)
        estimate = sketch_array[i * w + index]
        a.append(estimate)

    return min(a)

def get_counter_value(full_dir, row, width, level, window_size):
    counter_list = []
    
    # load counter value
    for l in range(0, 1):
        window_dir = '%s/level_%02d/window_%d/' % (full_dir, l, window_size)
        print(window_dir)
        
        level_list = []
        for file in sorted(os.listdir(window_dir)):
            window_list = []
            path = os.path.join(window_dir, file)
            
            f = open(path)
            for i in range(0, row * width):
                pline = f.readline().strip()
                window_list.append(int(pline))
            f.close()
            
            level_list.append(window_list)
            
        final_counter_path = '%s/level_%02d/sketch_counter.txt' % (full_dir, l)
        window_list = []
        f = open(final_counter_path)
        for i in range(0, row * width):
            pline = f.readline().strip()
            window_list.append(int(pline))
        f.close()
        
        level_list.append(window_list)
        
        print(f'There are {len(level_list)} windows')
        
        counter_list.append(level_list)
    
    return counter_list

def get_topk_flowkey(full_dir, row, width, level, window_size, k):
    key_list = []
    
    # load counter value
    for l in range(0, 1):
        key_window_dir = '%s/level_%02d/key_window_%d/' % (full_dir, l, window_size)
        print(key_window_dir)
        
        level_list = []
        for file in sorted(os.listdir(key_window_dir)):
            key_window_list = []
            path = os.path.join(key_window_dir, file)
            
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                key_window_list.append(flowkey)
            f.close()
            
            level_list.append(key_window_list)
            
        final_counter_path = '%s/flowkey.txt' % (full_dir)
        cnt = 0
        key_window_list = []
        f = open(final_counter_path)
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            key_window_list.append(flowkey)
            cnt += 1
            if cnt >= k:
                break
        f.close()
        
        level_list.append(key_window_list)
        
        print(f'There are {len(level_list)} windows')
        
        key_list.append(level_list)
    
    return key_list

def get_total_flow_size(counter_list, width, row, dist_dir, window_size):
    flow_size = [0]
    for cArray in counter_list[0]:
        val = sum(cArray[:width])
        flow_size.append(val)
    
    os.makedirs(dist_dir, exist_ok=True)
    
    fileName = os.path.join(dist_dir, "total_flow_size.txt")
    print("write total flow size variation to ", fileName)
    with open(fileName, 'w') as file:
        for val in flow_size:
            file.write(f'{val}\n')

def cm_main(full_dir, dist_dir, row, width, level):
    result = load_cm(full_dir, width, row)
    
    flowkey_list = result["flowkey"]
    index_hash_list = result["index_hash_list"]
    counter_list = []
    topk = 10
    
    # window_size = [100, 200, 500]
    window_size = [200]
    
    # Final TopK
    for ws in window_size:
        counter_list = get_counter_value(full_dir, row, width, level, ws)
        
        window_name = "window_" + str(ws)
        final_dir = os.path.join(dist_dir, window_name)
    
        get_total_flow_size(counter_list, width, row, final_dir, ws)
        
        # calculate accumulate
        change_list = {}
        for i in range(0, min(topk, len(flowkey_list))):
            flowkey = flowkey_list[i][2]
            
            val = [0]
            for cArray in counter_list[0]:
                est = counter_estimate(flowkey, cArray, index_hash_list[0], row, width, "crc_hash", 0)
                val.append(est)
            
            change_list[flowkey_list[i][0]] = val
            
        write_variation_file(final_dir, change_list, "accumulate.txt")
        
        # calculate variation
        var_dict = {}
        for key in change_list:
            print(key, change_list[key])
            var = [change_list[key][0]]
            for i in range(1, len(change_list[key])):
                var.append(change_list[key][i] - change_list[key][i-1])
            
            var_dict[key] = var
            print(key, var_dict[key])
        
        write_variation_file(final_dir, var_dict, "variation.txt")
        
        # calculate second derivative
        second_var_dict = {}
        for key in var_dict:
            print(key, var_dict[key])
            var = [var_dict[key][0]]
            for i in range(1, len(var_dict[key])):
                var.append(abs(var_dict[key][i] - var_dict[key][i-1]))
            
            second_var_dict[key] = var
            print(key, second_var_dict[key])
        
        write_variation_file(final_dir, second_var_dict, "second_variation.txt")
        
        
    # Summation
    for ws in window_size:
        topk_flowkey_list = get_topk_flowkey(full_dir, row, width, level, ws, topk)
        
        key_window_name = "summation_" + str(ws)
        final_dir = os.path.join(dist_dir, key_window_name)
        
        # calculate accumulate
        dynamic_change_list = [0]
        final_change_list = [0]
        for i in range(len(counter_list[0])):
            dynamic_total = 0
            final_total = 0
            cArray = counter_list[0][i]
                    
            for key in topk_flowkey_list[0][i]:
                est = counter_estimate(key, cArray, index_hash_list[0], row, width, "crc_hash", 0)
                dynamic_total += est
                
            for i in range(topk):
                key = flowkey_list[i][2]
                est = counter_estimate(key, cArray, index_hash_list[0], row, width, "crc_hash", 0)
                final_total += est
                
            dynamic_change_list.append(dynamic_total)
            final_change_list.append(final_total)
            
        write_summation_file(final_dir, dynamic_change_list, "dynamic_topk_summation.txt")
        write_summation_file(final_dir, final_change_list, "final_topk_summation.txt")
        
    
    
            
    
    