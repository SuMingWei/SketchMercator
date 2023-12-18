import os

def file_write(file_path, counters):
    folder_name = os.path.dirname(file_path)
    print(folder_name)
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)
    f = open(file_path, "w+")
    for elem in counters:
        f.write(str(elem) + "\n")
    print("saved to [%s]" % file_path)

def file_write_2(file_path, counters_1, counters_2):
    f = open(file_path, "w")
    for elem1, elem2 in zip(counters_1, counters_2):
        f.write(str(elem1) + " " + str(elem1) + "\n")
    print("saved to [%s]" % file_path)

