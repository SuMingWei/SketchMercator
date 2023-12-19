import os
import sys
import numpy as np

#sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
#import classes

class LinearProfiler:
    def __init__(self):
        self.name = 'LinearProfiler'

    def get_accuracy(self, sketch_instance, metric, norm, metadata):
        resource_allocation = sketch_instance.get_resource_allocation()
        values = np.array([r[1] for r in list(resource_allocation.values())])
        return np.prod(values/norm)

class LogProfiler:
    def __init__(self):
        self.name = 'LogProfiler'

    def get_accuracy(self, sketch_instance, metric, norm, metadata):
        resource_allocation = sketch_instance.get_resource_allocation()
        values = np.array([r[1] for r in list(resource_allocation.values())])/norm
        values = 1 + np.log10(0.9 * values + 0.1)
        return np.prod(values)

class ActualProfiler:
    def __init__(self):
        self.name = 'ActualProfiler'

    def get_error(self, sketch_instance, metric, norm, profiles):
        resource_allocation = sketch_instance.get_resource_allocation()
        if 'level' in resource_allocation and 'row' in resource_allocation and 'width' in resource_allocation:
            return profiles[sketch_instance.sketch][metric][resource_allocation['level']][resource_allocation['row']][resource_allocation['width']]
        else:
            print('Unsupported resources!')
            assert(False)
