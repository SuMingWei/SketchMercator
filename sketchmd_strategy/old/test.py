def partition(collection):
    if len(collection) == 1:
        yield [ collection ]
        return

    first = collection[0]
    for smaller in partition(collection[1:]):
        if len(collection) == 3:
            print("smaller", smaller)
        #     print()
        # insert `first` in each of the subpartition's subsets
        for n, subset in enumerate(smaller):
            # if len(collection) == 4:
            #     print("n", n, "subset", subset)
            yield smaller[:n] + [[ first ] + subset]  + smaller[n+1:]
        # put `first` in its own subset 
        yield [ [ first ] ] + smaller
        if len(collection) == 3:
            print("-------- --------")


something = list(range(1,5))
print(something)

for n, p in enumerate(partition(something), 1):
    print(n, sorted(p))

# def test():
#     for i in range(10):
#         print("come2")
#         yield i

# for a in test():
#     print("come1")
#     print(a)
