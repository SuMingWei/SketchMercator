date: 220130

Experiments that need to be executed.

Q1. About PHV experiment - does Tofino2 has the same constraint?
 -> Answer is YES
 -> look at 220127/phv_test

Q2. O5. merging storage using union-key idea.
 - Okay, Then (sketch1 > threshold) = true but (sketch2 > threshold) = false.
 - then I need to put (srcIP, 0) -> basically we should use "mask".
 - how do I implement this?
 - will this have difficulty in terms of PHVs?
 - I doubt it 

Q3. O6. recirculation
 -> I think no problem.

Q4.
- O2. share counter arrays -> no problem
- O3. update two counter arrays -> no problem
- O4. Applying counter array sampling

Then rest of the questions are about actual implementations.


date: 220201

-> Today I want to focus on O1 optimization.

-> Q. does "reusing hash" even make sense?
  -> I need to figure this out because reusing means more pressure on PHV constraint.
    -> Q. how can I check this?
      -> let's implement O4. counter array sampling and see if "reusing hash" make sense?

