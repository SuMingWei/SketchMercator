import random
import os

hash_seeds_dir = "hash_seeds"

os.makedirs(hash_seeds_dir, exist_ok=True)

primeNumber = 39916801

random.seed(7)

for i in range(1, 11):
    file_name = os.path.join(hash_seeds_dir, "%02d.txt" % i)
    print(file_name)

    with open(file_name, "w") as f:
        f.write("1. basic hash\n\n")

        f.write("1.1 sampling hash\n")

        f.write("paramA ")
        for depth in range(1, 26):
            paramA = random.randint(1, 2147483647) % primeNumber
            f.write("%d " % (paramA))
        f.write("\n")

        f.write("paramB ")
        for depth in range(1, 26):
            paramB = random.randint(1, 2147483647) % primeNumber
            f.write("%d " % (paramB))
        f.write("\n\n")


        f.write("1.2 sketching hash\n")
        for level in range(1, 26):

            f.write("index\n")
            f.write("level%02d paramA " % level)
            for depth in range(1, 11):
                paramA = random.randint(1, 2147483647) % primeNumber
                f.write("%d " % (paramA))
            f.write("\n")

            f.write("level%02d paramB " % level)
            for depth in range(1, 11):
                paramB = random.randint(1, 2147483647) % primeNumber
                f.write("%d " % (paramB))
            f.write("\n\n")

            f.write("res\n")
            f.write("level%02d paramA " % level)
            for depth in range(1, 11):
                paramA = random.randint(1, 2147483647) % primeNumber
                f.write("%d " % (paramA))
            f.write("\n")

            f.write("level%02d paramB " % level)
            for depth in range(1, 11):
                paramB = random.randint(1, 2147483647) % primeNumber
                f.write("%d " % (paramB))

            f.write("\n\n")

        f.write("2. crc hash\n\n")

        f.write("2.1 sampling hash\n")

        f.write("paramPoly ")
        for depth in range(1, 26):
            paramPoly = 0
            while True:
                paramPoly = random.randint(1, 2147483647)
                if paramPoly % 2 == 1:
                    break
            f.write("%d " % (paramPoly))
        f.write("\n\n")

        f.write("2.2 sketching hash\n")
        for level in range(1, 26):
            f.write("index\n")
            f.write("level%02d paramPoly " % level)
            for depth in range(1, 11):
                paramPoly = 0
                while True:
                    paramPoly = random.randint(1, 2147483647)
                    if paramPoly % 2 == 1:
                        break
                f.write("%d " % (paramPoly))
            f.write("\n\n")

            f.write("res\n")
            f.write("level%02d paramPoly " % level)
            for depth in range(1, 11):
                paramPoly = 0
                while True:
                    paramPoly = random.randint(1, 2147483647)
                    if paramPoly % 2 == 1:
                        break
                f.write("%d " % (paramPoly))
            f.write("\n\n")

