date: 220205

p416_many_sketches_1.p4
    - Okay, implemented 48 sketches.

    8 flowkeys
    - key1. (srcip)
    - key2. (srcip, srcport)
    - key3. (dstip, dstport)
    - key4. (dstport)
    - key5. (dstip)
    - key6. (srcip, dstip)
    - key7. (srcip, dstip, srcport, dstport)
    - key8. (srcip, dstip, srcport ,dstport, proto)

    Per each flowkey there are 6 sketches
    - 5 sketches - count-min / entropy / k-ary / linear counting / HLL
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    - 8 flowkeys x 6 sketches = 48 sketches

    Applied Optimizations: {O2, O3, O5}
    - O1. reuse hash results. X (not needed because of using hash calls directly)
    - O2. share counter arrays. Four sketches share counter arrays - count-min / entropy / k-ary / linear counting
    - O3. use SALU for two counter updates. (count-min, entropy), (count-min, HLL)
    - O4. sampling -> not used
    - O5. remove heavy flowkey storage -> applied


date: 220207

p416_many_sketches_2.p4

    8 flowkeys
    - key1. (srcip)
    - key2. (srcip, srcport)
    - key3. (dstport)
    - key4. (dstip, dstport)
    - key5. (dstip)
    - key6. (srcip, dstip)
    - key7. (srcip, dstip, srcport, dstport)
    - key8. (srcip, dstip, srcport ,dstport, proto)

    4 sketches
    - 3 sketches - count-min / entropy / k-ary
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    For flowkey1-4, I implemented 2 epoches (e.g., 30s and 60s)
        - 4 flowkey x 4 sketches x 2 epochs = 32 sketches

    For flowkey5-8, I implemented 1 epoches (e.g., 30s)
        - 4 flowkey x 4 sketches x 1 epochs = 16 sketches

    -> 32 + 16 = 48
    
    Applied Optimizations: {O1, O2, O3, O4, O5}
    - O1. reuse hash results.
    - O2. share counter arrays. Three sketches share counter arrays - count-min / entropy / k-ary
    - O3. use SALU for two counter updates. (count-min, entropy)
    - O4. sampling -> used for all SALUs
    - O5. remove heavy flowkey storage -> applied


date: 220210
 -> It was all wrong!!! Alan pointed out!!

 