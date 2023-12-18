date: 220210

-> no recirculation or sending it to the control plane.
-> I need to figure out again.


p416_many_sketches_1.p4

    4 flowkeys
    - key1. (srcip)
    - key6. (dstport)
    - key7. (dstip, dstport)
    - key8. (dstip)

    Per each flowkey there are 6 sketches
    - 5 sketches - count-min / entropy / k-ary / linear counting / HLL
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    - 4 flowkeys x 6 sketches = 24 sketches

    Applied Optimizations: {O1, O2, O3, O5}
    - O1. reuse hash results. X (not needed because of using hash calls directly)
    - O2. share counter arrays. Four sketches share counter arrays - count-min / entropy / k-ary / linear counting
    - O3. use SALU for two counter updates. (count-min, entropy), (count-min, HLL)
    - O4. sampling -> not used
    - O5. reuse heavy flowkey storage -> applied

    -> I used {srcip}, {dstip}, {both_port}, {proto}

p416_many_sketches_2.p4

    5 flowkeys
    - key1. (srcip)
    - key2. (srcip, srcport)
    - key6. (dstport)
    - key7. (dstip, dstport)
    - key8. (dstip)

    Per each flowkey there are 6 sketches
    - 5 sketches - count-min / entropy / k-ary / linear counting / HLL
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    - 5 flowkeys x 6 sketches = 30 sketches

    Applied Optimizations: {O1, O2, O3, O5}
    - O1. reuse hash results. X (not needed because of using hash calls directly)
    - O2. share counter arrays. Four sketches share counter arrays - count-min / entropy / k-ary / linear counting
    - O3. use SALU for two counter updates. (count-min, entropy), (count-min, HLL)
    - O4. sampling -> not used
    - O5. reuse heavy flowkey storage -> applied

    -> I used {srcip}, {dstip}, {srcport}, {dstport}, {proto}


p416_many_sketches_3.p4

    8 flowkeys
    - key1. (srcip)
    - key2. (srcip, srcport)
    - key3. (dstip, dstport)
    - key5. (dstip)
    - key6. (srcip, dstip)
    - key7. (srcip, dstip, srcport, dstport)

    Per each flowkey there are 6 sketches
    - 5 sketches - count-min / entropy / k-ary / linear counting / HLL
       - flow size definition = packet counts
    - 1 sketch - entropy
       - flow size definition (packet byte)

    - 6 flowkeys x 6 sketches = 36 sketches

    Applied Optimizations: {O1, O2, O3, O5}
    - O1. reuse hash results. X (not needed because of using hash calls directly)
    - O2. share counter arrays. Four sketches share counter arrays - count-min / entropy / k-ary / linear counting
    - O3. use SALU for two counter updates. (count-min, entropy), (count-min, HLL)
    - O4. sampling -> not used
    - O5. reuse heavy flowkey storage -> applied

    -> I used {srcip}, {dstip}, {srcport}, {srcport}
