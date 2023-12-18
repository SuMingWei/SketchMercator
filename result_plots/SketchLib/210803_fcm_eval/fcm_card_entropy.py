from statistics import median

def relative_error(true, estimate):
    return abs(true-estimate)/true

def func(fn):
    f = open(fn, "r")
    card_error_list = []
    entropy_error_list = []
    for line in f:
        data = line.strip().split(" ")
        card_error = relative_error(int(data[0]), int(data[1]))*100
        ent_error = relative_error(float(data[2]), float(data[3]))*100
        card_error_list.append(card_error)
        entropy_error_list.append(ent_error)
        # print(card_error, ent_error)
        # print(line)
    print("card:", median(card_error_list))
    print("ent:", median(entropy_error_list))

print("fcmsketch")
func("fcmsketch.txt")

print("fcm+topK")
func("fcmplus.txt")
