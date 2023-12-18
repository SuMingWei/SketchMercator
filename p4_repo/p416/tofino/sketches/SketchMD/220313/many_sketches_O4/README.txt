date: 220210

p416_many_sketches_O4_1.p4

    8 flowkeys
    - key1. (srcip)
    - key2. (srcip, srcport)
    - key3. (dstport)
    - key4. (dstip, dstport)

    - key5. (dstip)
    - key6. (srcip, dstip)


    4 sketches
    - 3 sketches - count-min / entropy / k-ary
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    For flowkey1-4, I implemented 2 epoches (e.g., 30s and 60s)
        - 4 flowkey x 4 sketches x 2 epochs = 32 sketches

    For flowkey5-6, I implemented 1 epoches (e.g., 30s)
        - 2 flowkey x 4 sketches x 1 epochs = 8 sketches

    -> 32 + 8 = 40
    
    Applied Optimizations: {O1, O2, O3, O4, O5}
    - O1. reuse hash results.
    - O2. share counter arrays. Three sketches share counter arrays - count-min / entropy / k-ary
    - O3. use SALU for two counter updates. (count-min, entropy)
    - O4. sampling -> used for all SALUs
    - O5. remove heavy flowkey storage -> applied
