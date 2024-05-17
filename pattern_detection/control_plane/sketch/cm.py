import os
import random
from sw_dp_simulator.file_io.py.read_cm import load_cm
from sw_dp_simulator.file_io.py.common import parse_line
from sw_dp_simulator.hash_module.py.hash import compute_hash
from pattern_detection.control_plane.sketch.common import write_variation_file
from pattern_detection.control_plane.sketch.common import write_summation_file
from pattern_detection.control_plane.sketch.common import write_fsd_file

def relative_error(true, estimate):
    if true == 0:
        return 0
    return abs(true-estimate)/true*100

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
            
            cnt = 0
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                key_window_list.append(flowkey)
                cnt += 1
                if k != 0 and cnt >= k:
                    break
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
        f.close()
        
        # random sample k flow key
        if k != 0:
            random.shuffle(key_window_list)
            
            level_list.append(key_window_list[:k])
        else:
            level_list.append(key_window_list)
            
        print(f'There are {len(level_list)} windows')
        
        key_list.append(level_list)
    
    return key_list

def get_topk_str_flowkey(full_dir, row, width, level, window_size, k):
    key_list = []
    
    # load counter value
    for l in range(0, 1):
        key_window_dir = '%s/level_%02d/key_window_%d/' % (full_dir, l, window_size)
        print(key_window_dir)
        
        level_list = []
        for file in sorted(os.listdir(key_window_dir)):
            key_window_list = []
            path = os.path.join(key_window_dir, file)
            
            cnt = 0
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                key_window_list.append((string_key, flowkey))
                cnt += 1
                if k != 0 and cnt >= k:
                    break
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
            key_window_list.append((string_key, flowkey))
        f.close()
        
        # random sample k flow key
        if k != 0:
            random.shuffle(key_window_list)
            
            level_list.append(key_window_list[:k])
        else:
            level_list.append(key_window_list)
            
        print(f'There are {len(level_list)} windows')
        
        key_list.append(level_list)
    
    return key_list

def get_gt_flowkey(full_dir, row, width, level, window_size, k):
    key_list = []
    
    # load counter value
    for l in range(0, 1):
        key_window_dir = '%s/level_%02d/gt_window_%d/' % (full_dir, l, window_size)
        print(key_window_dir)
        
        level_list = []
        for file in sorted(os.listdir(key_window_dir)):
            key_window_list = []
            path = os.path.join(key_window_dir, file)
            
            cnt = 0
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                key_window_list.append((string_key, flowkey))
                cnt += 1
                if k != 0 and cnt >= k:
                    break
            f.close()
            
            level_list.append(key_window_list)
            
        final_counter_path = '%s/ground_truth.txt' % (full_dir)
        cnt = 0
        key_window_list = []
        f = open(final_counter_path)
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            key_window_list.append((string_key, flowkey))
        f.close()
        
        # random sample k flow key
        if k != 0:
            random.shuffle(key_window_list)
            
            level_list.append(key_window_list[:k])
        else:
            level_list.append(key_window_list)
            
        print(f'There are {len(level_list)} windows')
        
        key_list.append(level_list)
    
    return key_list

def get_topk_gt_fsd(full_dir, row, width, level, window_size, k, last_window_key_list):
    fsd_list = []
    
    # load counter value
    for l in range(0, 1):
        key_window_dir = '%s/level_%02d/key_window_%d/' % (full_dir, l, window_size)
        print(key_window_dir)
        
        level_list = []
        for file in sorted(os.listdir(key_window_dir)):
            window_fsd = {}
            path = os.path.join(key_window_dir, file)
            
            cnt = 0
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                if estimate in window_fsd.keys():
                    window_fsd[estimate] += 1
                else:
                    window_fsd[estimate] = 1
                    
                cnt += 1
                if k != 0 and cnt >= k:
                    break
            f.close()
            
            level_list.append(window_fsd)
            
        final_counter_path = '%s/flowkey.txt' % (full_dir)

        window_fsd = {}
        cnt = 0
        f = open(final_counter_path)
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            if flowkey in last_window_key_list:
                if estimate in window_fsd.keys():
                    window_fsd[estimate] += 1
                else:
                    window_fsd[estimate] = 1
                    
                cnt += 1
                if k != 0 and cnt >= k:
                    break
        f.close()
        
        level_list.append(window_fsd)
            
        print(f'There are {len(level_list)} windows')
        
        fsd_list.append(level_list)
    
    return fsd_list

def get_gt_dict(full_dir, row, width, level, window_size, k):
    fsd_list = []
    
    # load counter value
    for l in range(0, 1):
        # key_window_dir = '%s/level_%02d/key_window_%d/' % (full_dir, l, window_size)
        key_window_dir = '%s/level_%02d/gt_window_%d/' % (full_dir, l, window_size)
        print(key_window_dir)
        
        level_list = []
        for file in sorted(os.listdir(key_window_dir)):
            window_fsd = {}
            path = os.path.join(key_window_dir, file)

            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                window_fsd[string_key] = estimate 
            f.close()
            
            level_list.append(window_fsd)
            
        # final_counter_path = '%s/flowkey.txt' % (full_dir)
        final_counter_path = '%s/ground_truth.txt' % (full_dir)

        window_fsd = {}
        cnt = 0
        f = open(final_counter_path)
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            window_fsd[string_key] = estimate         
        f.close()
        
        level_list.append(window_fsd)
            
        print(f'There are {len(level_list)} windows')
        
        fsd_list.append(level_list)
    
    return fsd_list

def get_topk_gt(full_dir, row, width, level, window_size, k):
    gt_list = []
    
    # load counter value
    for l in range(0, 1):
        gt_window_dir = '%s/level_%02d/gt_window_%d/' % (full_dir, l, window_size)
        print(gt_window_dir)
        
        level_list = [0]
        for file in sorted(os.listdir(gt_window_dir)):
            gt_total = 0
            path = os.path.join(gt_window_dir, file)
            
            f = open(path)
            key = f.readline().strip()
            # print(key)
            for line in f:
                string_key, estimate, flowkey = parse_line(key, line.strip())
                gt_total += estimate
            f.close()
            
            level_list.append(gt_total)
            
        final_counter_path = '%s/ground_truth.txt' % (full_dir)
        cnt = 0
        gt_total = 0
        f = open(final_counter_path)
        key = f.readline().strip()
        # print(key)
        for line in f:
            string_key, estimate, flowkey = parse_line(key, line.strip())
            gt_total += estimate
            cnt += 1
            if k != 0 and cnt >= k:
                break
        f.close()
        
        level_list.append(gt_total)
        
        print(f'There are {len(level_list)} windows')
        
        gt_list.append(level_list)
    
    return gt_list


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
    # topks = [1000, 8000]
    topks = [5000]
    
    # window_size = [100, 200, 500]
    window_size = [200]
    
    # Final TopK
    for ws in window_size:
        counter_list = get_counter_value(full_dir, row, width, level, ws)
        
        window_name = "window_" + str(ws)
        final_dir = os.path.join(dist_dir, window_name)
    
        get_total_flow_size(counter_list, width, row, final_dir, ws)
                
    
    # for FSD
    # # RamdomK FSD
    for ws in window_size:
        gt_str_flowkey_list = get_gt_flowkey(full_dir, row, width, level, ws, 0)
        gt_dict = get_gt_dict(full_dir, row, width, level, ws, 0)
        
        # GT
        for i in range(len(counter_list[0])):
            cArray = counter_list[0][i]
            single_window_gt_fs_dist = {}
            
            # single window gt counter
            for strkey , _ in gt_str_flowkey_list[0][i]:
                if i == 0:
                    gt = gt_dict[0][i][strkey]
                    if gt in single_window_gt_fs_dist.keys(): 
                        single_window_gt_fs_dist[gt] += 1
                    else:
                        single_window_gt_fs_dist[gt] = 1
                else:
                    gt = gt_dict[0][i][strkey]
                    
                    if strkey not in gt_dict[0][i-1].keys():
                        if gt in single_window_gt_fs_dist.keys(): 
                            single_window_gt_fs_dist[gt] += 1
                        else:
                            single_window_gt_fs_dist[gt] = 1
                    else:
                        gt_prev = gt_dict[0][i-1][strkey]
                        var = gt - gt_prev
                        if var == 0:
                            continue
                        if var in single_window_gt_fs_dist.keys(): 
                            single_window_gt_fs_dist[var] += 1
                        else:
                            single_window_gt_fs_dist[var] = 1
                        
            single_window_gt_fs_dist = dict(sorted(single_window_gt_fs_dist.items()))
            write_fsd_file(final_dir, single_window_gt_fs_dist, f"gt/single_window_randk_gt_summation", str(i).zfill(2))
            
        # Sketch sample K    
        for topk in topks:
            randomk_str_flowkey_list = get_topk_str_flowkey(full_dir, row, width, level, ws, topk)
            
            # record each window fsd
            for i in range(len(counter_list[0])):
                cArray = counter_list[0][i]
                fs_dist = {}
                single_window_fs_dist = {}
                
                for _ , key in randomk_str_flowkey_list[0][i]:
                    ## accumulate counter
                    est = counter_estimate(key, cArray, index_hash_list[0], row, width, "crc_hash", 0)
                    # if est in fs_dist.keys(): 
                    #     fs_dist[est] += 1
                    # else:
                    #     fs_dist[est] = 1
                    
                    # single window counter
                    if i == 0:
                        if est in single_window_fs_dist.keys(): 
                            single_window_fs_dist[est] += 1
                        else:
                            single_window_fs_dist[est] = 1
                    else:
                        est_prev =  counter_estimate(key, counter_list[0][i-1], index_hash_list[0], row, width, "crc_hash", 0)
                        var = est - est_prev
                        if var == 0:
                            continue
                        if var in single_window_fs_dist.keys(): 
                            single_window_fs_dist[var] += 1
                        else:
                            single_window_fs_dist[var] = 1
                          
                        
                # fs_dist = dict(sorted(fs_dist.items()))
                # write_fsd_file(final_dir, fs_dist, "randk_summation", str(i).zfill(2))
                # write_fsd_file(final_dir, dict(sorted(gt_fsd_list[0][i].items())), "randk_gt_summation", str(i).zfill(2))
                
                single_window_fs_dist = dict(sorted(single_window_fs_dist.items()))
                write_fsd_file(final_dir, single_window_fs_dist, f"top{topk}/single_window_randk_summation", str(i).zfill(2))
                
                    