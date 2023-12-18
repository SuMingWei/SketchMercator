import numpy as np

# get mean value from multiple runs at solver
def get_mean_from_iterations(ret_sol1_ll, ret_sol2_ll, ret_sol3_ll, ret_sol4_ll, ret_us_ll, all_metrics = ['hh', 'change_det', 'entropy', 'card', 'fsd']):
    ret_sol1 = {}
    ret_sol2 = {}
    ret_sol3 = {}
    ret_sol4 = {}
    ret_us = {}

    print("Num of run:", len(ret_sol1_ll))
    
    for m in all_metrics:
        np1 = np.zeros(len(ret_sol1_ll[0][m]))
        np2 = np.zeros(len(ret_sol2_ll[0][m]))
        np3 = np.zeros(len(ret_sol3_ll[0][m]))
        np4 = np.zeros(len(ret_sol4_ll[0][m]))
        np5 = np.zeros(len(ret_us_ll[0][m]))

        # sum the result from all runs
        for i in range(len(ret_sol1_ll)):
            np1 += ret_sol1_ll[i][m]
            np2 += ret_sol2_ll[i][m]
            np3 += ret_sol3_ll[i][m]
            np4 += ret_sol4_ll[i][m]
        # bruteforce only has 1 run
        np5 += ret_us_ll[0][m]

        # calculate mean
        np1 /= len(ret_sol1_ll)
        np2 /= len(ret_sol2_ll)
        np3 /= len(ret_sol3_ll)
        np4 /= len(ret_sol4_ll)
        # bruteforce only has 1 run
        # np5 /= len(ret_us_ll)
        
        ret_sol1[m] = np1.tolist()
        ret_sol2[m] = np2.tolist()
        ret_sol3[m] = np3.tolist()
        ret_sol4[m] = np4.tolist()
        ret_us[m] = np5.tolist()
            
    return (ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us)


def normalize_error_result(ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us, all_metrics = ['hh', 'change_det', 'entropy', 'card', 'fsd']):
    r1 = {}
    r2 = {}
    r3 = {}
    r4 = {}
    r5 = {}
    max_list = {}
    
    for m in all_metrics:
        r1[m] = np.zeros(len(ret_sol1[m]))
        r2[m] = np.zeros(len(ret_sol2[m]))
        r3[m] = np.zeros(len(ret_sol3[m]))
        r4[m] = np.zeros(len(ret_sol4[m]))
        r5[m] = np.zeros(len(ret_us[m]))
        
        max_list[m] = 0
        
        for i in range(len(ret_sol1[m])):
            max_list[m] = max(max_list[m], ret_sol1[m][i], ret_sol2[m][i], ret_sol3[m][i], ret_sol4[m][i], ret_us[m][i])
    
    print('max_list:', max_list)
    
    for m in all_metrics:
        for i in range(len(ret_sol1[m])):
            r1[m][i] = (ret_sol1[m][i] / max_list[m]) * 100
            r2[m][i] = (ret_sol2[m][i] / max_list[m]) * 100
            r3[m][i] = (ret_sol3[m][i] / max_list[m]) * 100
            r4[m][i] = (ret_sol4[m][i] / max_list[m]) * 100
            r5[m][i] = (ret_us[m][i] / max_list[m]) * 100
    return (r1, r2, r3, r4, r5)


## warning: global_ensemble_error is a global variable
def get_ensemble_error(ret_sol1, ret_sol2, ret_sol3, ret_sol4, ret_us, all_metrics, global_ensemble_error):
    merge_error_result = np.zeros((5, len(ret_sol1[all_metrics[0]]))) # 4 strawman + 1 bruteforce
    
    for m in all_metrics:
        # get mean gain from all metrics (measure it as an ensemble)
        merge_error_result[0] += np.array(ret_sol1[m]) / len(all_metrics)
        merge_error_result[1] += np.array(ret_sol2[m]) / len(all_metrics)
        merge_error_result[2] += np.array(ret_sol3[m]) / len(all_metrics)
        merge_error_result[3] += np.array(ret_sol4[m]) / len(all_metrics)
        merge_error_result[4] += np.array(ret_us[m]) / len(all_metrics)

    for d in merge_error_result:
        global_ensemble_error.append(d)
    return global_ensemble_error
