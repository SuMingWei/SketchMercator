from global_var import H
import random

def GenerateInput(N):
    F = []
    R = []
    for i in range(N):
        flowkey = []
        for h in H:
            rand_bit = random.randint(0, 1)
            if rand_bit == 1:
                flowkey.append(h)
        if len(flowkey) == 0:
            flowkey.append(H[random.randint(0, 4)])
        F.append(flowkey)
        R.append(random.randint(1, 5))
    return (F,R)