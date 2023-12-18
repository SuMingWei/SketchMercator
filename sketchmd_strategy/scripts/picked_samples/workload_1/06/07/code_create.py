set1 = ["32w0x30243f0b",
"32w0x0f79f523",
"32w0x6b8cb0c5",
"32w0x00390fc3",
"32w0x298ac673",
"32w0x60180d91"]

set2 = ["32w0x0a9d4719",
"32w0x527f2ab1",
"32w0x503e1855",
"32w0x36a7edfd",
"32w0x009cbd15",
"32w0x57857ba5"]

set3 = ["32w0x6fbf2213",
"32w0x7a9d09a3",
"32w0x4e303003",
"32w0x09b68d7b",
"32w0x439e0185",
"32w0x27d744bd"]

set4 = ["32w0x63986f65",
"32w0x16261f2d",
"32w0x67c781ad",
"32w0x409900cd",
"32w0x08123a4d",
"32w0x7a2db5bd"]

set5 = ["32w0x67bb5cbf",
"32w0x01891da9",
"32w0x234e0cc5",
"32w0x24db30cb",
"32w0x148238a5",
"32w0x783aab09"]

for setid, set in enumerate([set1, set2, set3, set4, set5], 1):
    if setid == 1:
        print("    #if HASH_SET == %d" % setid)
    else:
        print("    #elif HASH_SET == %d" % setid)

    print("        T2_INIT_HH_1_THRESHOLD( 1, 100, 4096", end = "")
    for i in range(0, 2):
        print(", " + set[i], end="")
    print(")")

    print("        T2_INIT_HH_5_THRESHOLD( 2, 100, 16384", end = "")
    for i in range(0, 6):
        print(", " + set[i], end="")
    print(")")

    print("        T2_INIT_HH_2_THRESHOLD( 3, 200, 16384", end = "")
    for i in range(0, 3):
        print(", " + set[i], end="")
    print(")")

    print("        T2_INIT_HH_5_THRESHOLD( 4, 110, 8192", end = "")
    for i in range(0, 6):
        print(", " + set[i], end="")
    print(")")

    print("        T2_INIT_HH_2_THRESHOLD( 5, 110, 4096", end = "")
    for i in range(0, 3):
        print(", " + set[i], end="")
    print(")")

    print("        T2_INIT_HH_5_THRESHOLD( 6, 221, 8192", end = "")
    for i in range(0, 6):
        print(", " + set[i], end="")
    print(")")
    print("        HEAVY_FLOWKEY_STORAGE_CONFIG_221(%s) heavy_flowkey_storage;" % set[5])
print("    #endif")
