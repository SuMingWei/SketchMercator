# standard
# I1. Flowkey 1 > 2 > ... > 8        (less # of flowkeys, more similar)
# I2. Flowsize 1 > 2                 (less # of flowsize, more similar)
# I3. Epoch 1 > 2 > 3 > ... > 7      (less # of epochs, more similar)
# I4. Sketch Parameters -> all similar 5
# B1. Index Computing Type [1] > [2] > [1, 2] (single level has more opportunity to be optimized)
# B2. Counter Update Type 2 > 3 > 4 > 5  (less # of counter update type, more similar)
# B3. Counter Value in DP [0, 1] > [0] or [1]  (correlation with o5)
# B4. Sampling Compatible [1] > [0,1] > [0]    (correlation with o5)
# B5. Heavy Flowkey Storage [1] > [0, 1] > [0] (correlation with o5)

python3 workload_generator.py --folder input --filename landscape3.pkl --data_count 100