from input import GenerateInput
from getF2 import getF2_main
from getR2 import getR2_main

def run(N):
    (F,R) = GenerateInput(N)

    # F = [
    # ['A', 'B', 'C', 'D'],
    # ['A', 'B'],
    # ['A', 'B'],
    # ['C', 'D'],
    # ['A', 'B', 'E']
    # ]
    # R = [3, 2, 3, 4, 2]

    for f, r in zip(F, R):
        print(r, f)

    F2 = getF2_main(F)
    print("F2:", F2)

    return getR2_main(F,R,F2)

result = []
for i in range(5):
    result.append(run(30))

print(result)
