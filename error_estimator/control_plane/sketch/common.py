def get_miss_rate(gt, flowkey, topk):
    true = 0
    false = 0

    for i in range(0, topk):
        gt_elem = gt[i]
        find = False
        for hh_elem in flowkey:
            if str(gt_elem[2]) == str(hh_elem[2]):
                find = True
                break
        if find == True:
            true+=1
        else:
            false+=1
    miss_rate = (false / topk)*100
    return miss_rate

def relative_error(true, estimate):
    return abs(true-estimate)/true

def get_ARE(gt, compare, topk):
    sum = 0
    for i in range(0, topk):
        gt_elem = gt[i]
        error = relative_error(gt_elem[1], compare[i])
        # print(gt_elem, compare[i])
        sum += error
    ARE = sum/topk*100
    return ARE

def write_file_fsd(flow_sizes, frequencies, fileName):
    print("write flow size distribution to ", fileName)
    with open(fileName, 'w') as file:
        for i in range(len(flow_sizes)):
            file.write(f'{flow_sizes[i]} {frequencies[i]}\n')
