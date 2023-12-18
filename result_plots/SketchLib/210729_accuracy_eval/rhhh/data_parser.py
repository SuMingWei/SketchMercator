import os
import pickle

def relative_error(true, estimate):
    return abs(true-estimate)/true

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

    original = []
    hw = []

    for fn in sorted(os.listdir(controlplane_folder_name)):
        full_path = os.path.join(controlplane_folder_name, fn)
        flag = False
        for s in sample1:
            if str(time_list[s]) in fn:
                flag = True
                break
        if flag == True:
            # print(full_path)
            # print(fn)
            with open(full_path, 'rb') as f:
                v = pickle.load(f)
            (c1, c2, c3) = v
            # print(v)
            original.append(c1)
            hw.append(c3)
    return original, hw

def whatsmissing_samping1(controlplane_folder_name, date):
    missing = []

    map_dict = {}
    for s in sample1:
        for i in [1, 2, 3, 4, 5]:
            fn = "%s_%dtxt.pkl" % (time_list[s], i)
            map_dict[fn] = 1


    for fn in sorted(os.listdir(controlplane_folder_name)):
        if fn in map_dict.keys():
            map_dict[fn] = 0

    e_count = 0
    m_count = 0
    for k,v in map_dict.items():
        if v == 1:
            m_count += 1
            print(k)
            missing.append(str(date)+"_"+k)
        else:
            e_count += 1
    print("exist count: ", e_count)
    print("missing count: ", m_count)
    print(" ")
    return missing



def whatsmissing(controlplane_folder_name, date):
    missing = []

    map_dict = {}
    for minute in range(1300, 1360, 1):
        for sec in [0, 30]:
            for i in [1, 2, 3, 4, 5]:
                fn = "%d%02d_%dtxt.pkl" % (minute, sec, i)
                map_dict[fn] = 1


    for fn in sorted(os.listdir(controlplane_folder_name)):
        map_dict[fn] = 0

    e_count = 0
    m_count = 0
    for k,v in map_dict.items():
        if v == 1:
            m_count += 1
            print(k)
            missing.append(str(date)+"_"+k)
        else:
            e_count += 1
    print("exist count: ", e_count)
    print("missing count: ", m_count)
    print(" ")
    return missing
