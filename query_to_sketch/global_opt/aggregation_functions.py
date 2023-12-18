import numpy as np

def min_agg_function(elements, break_ties=True):
    if break_ties:
        # compares based on first element; if tie, compares based on second element and so on
        return tuple(sorted(elements))
    else:
        return min(elements)

def max_agg_function(elements, break_ties=True):
    if break_ties:
        # compares based on first element; if tie, compares based on second element and so on
        return tuple(sorted(elements, reverse=True))
    else:
        return max(elements)

def avg_agg_function(elements, break_ties=True):
    return np.mean(elements)

def median_agg_function(elements, break_ties=True):
    return np.median(elements)
