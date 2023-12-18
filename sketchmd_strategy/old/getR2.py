from global_var import H

R2 = []
min_count = 0
min_R2 = []
J = []

def getJ(F, F2):
    global J
    for i, fi in enumerate(F):
        sequence = []
        for j, fj in enumerate(F2):
            if fj[0] in fi:
                sequence.append(j)
        J.append(sequence)

def CheckConstraints(F1, R1, F2, step):
    for (fi, ri, Ji) in zip(F1, R1, J):
        Flag = True
        for j in Ji:
            if j > step:
                Flag = False
                break
        if Flag:
            result = 1
            for j in Ji:
                result *= R2[j]
            if ri > result:
                return False
    return True


def Recursive(F,R,F2,step):
    global R2
    global min_count
    global min_R2
    if step == len(F2):
        sumR2 = sum(R2)
        if sumR2 < min_count:
            min_count = sumR2
            min_R2 = R2
            print("[new R2]")
            print("min_count: ", min_count)
            print("min_R2: ", min_R2)
        return

    i = 0
    R2[step] = 1
    while True:
        # print("[%d] R2:" % step, R2)
        sumR2 = sum(R2[:step+1])
        if sumR2 >= min_count:
            break
        if CheckConstraints(F, R, F2, step):
            Recursive(F,R,F2,step+1)
        R2[step] = R2[step]+1
        # i += 1
        # if i == 5:
        #     exit(1)


def getR2_main(F,R,F2):
    global R2
    global min_count
    global min_R2
    getJ(F, F2)
    # print("J:", J)

    min_count = 0
    for r in R:
        min_count += r
    before = min_count
    # print("min_count:", min_count)
    R2 = [1] * len(F2)
    # print("R2:", R2)
    # print(" ")
    # print(" ")
    Recursive(F,R,F2,0)
    after = min_count

    return (before, after)
