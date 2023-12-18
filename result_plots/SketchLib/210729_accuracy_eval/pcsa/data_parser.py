import os
import pickle

def relative_error(true, estimate):
    return abs(true-estimate)/true

import sys
def get_sample():
    import random
    sample_size = 20
    set_size = int(60 / sample_size)

    whole_list = [i for i in range(60)]
    check_list = []
    for i in whole_list:
        check_list.append(0)

    print(whole_list)
    print()

    for sampling_set in range(0, set_size):
        good = []
        count = 0
        while True:
            a = random.randint(0, 59)
            if check_list[a] == 0:
                check_list[a] = 1
                count += 1
                good.append(a)
            if count == sample_size:
                break
        # print(sampling_set)
        print(sorted(good), end='')
        # sys.stdout.write(sorted(good))
        sys.stdout.write(",\n")
        # print()

get_sample()

g_sample = []
sample1 = [1, 6, 13, 15, 20, 22, 24, 25, 26, 27, 29, 34, 40, 43, 44, 46, 50, 51, 58, 59, 61, 66, 73, 75, 80, 82, 84, 85, 86, 87, 89, 94, 100, 103, 104, 106, 110, 111, 118, 119]
sample2 = [2, 3, 4, 5, 7, 9, 16, 21, 30, 32, 33, 35, 37, 38, 41, 42, 45, 49, 52, 54, 62, 63, 64, 65, 67, 69, 76, 81, 90, 92, 93, 95, 97, 98, 101, 102, 105, 109, 112, 114]
sample3 = [0, 8, 10, 11, 12, 14, 17, 18, 19, 23, 28, 31, 36, 39, 47, 48, 53, 55, 56, 57, 60, 68, 70, 71, 72, 74, 77, 78, 79, 83, 88, 91, 96, 99, 107, 108, 113, 115, 116, 117]
time_list = []
for hour in range(0, 60):
    time_list.append("13%02d00" % hour)
    time_list.append("13%02d30" % hour)


def read_data(controlplane_folder_name):
    print(controlplane_folder_name)
    fn = os.path.join(controlplane_folder_name, "pcsa.pkl")
    with open(fn, 'rb') as f:
        data_dict = pickle.load(f)
    # print(data_dict)

    original = []
    new = []
    hw = []

    for k, v in sorted(data_dict.items()):
        flag = False
        for s in sample1:
            if "-" + str(time_list[s]) + "." in k:
                flag = True
                break

        if flag == True:
            # print(k, v)
            if len(v) >= 4:
                original.append(abs(v[0]-v[1])/v[0]*100)
                new.append(abs(v[0]-v[2])/v[0]*100)
                hw.append(abs(v[0]-v[3])/v[0]*100)


    return original, hw
