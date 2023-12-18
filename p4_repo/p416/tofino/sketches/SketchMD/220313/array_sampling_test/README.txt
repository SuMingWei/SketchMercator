date: 220201

array_sampling_test_1
    Purpose of this test:
    - does PHV affect the idea of sampling counter array?

    Method:
    - let's merge two sketches with counter array sampling
    - then see how PHV affects this

    Things that need to be checked
    -> index1 / index2 should be in the same containers?
    -> yes.
    -> Then aren't PHV bottlenecked?
    -> Yes, they are bottlenecked.
    -> we should not merge multiple sketches into one.
    -> A great insight!!

array_sampling_test_2
    Purpose of this test:
    - The idea of reusing hash is still making sense?

    Method:
    - we used one five tuple, and one four tuple.
    - can we reduce this?

    Conclusion
    -> totally possible. O1 is still very valid and brilliant idea.



array_sampling_test_3
    Purpose of this test:
    - does O1 make difference?
    - suppose there are four sketches and you want to merge 2 and 2
    - try separately first
        -> okay, we have seen some problem regarding sending digest to control plane
        -> I found out an issue of sending multiple digests to the control plane
        

    - then try to reuse hash results
