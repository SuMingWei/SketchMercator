from collections import defaultdict

class LinearModeler:
    def __init__(self):
        self.name = 'LinearModeler'

    def get_resource_usage(self, sketch_instances):
        result = defaultdict(float)
        for instance in sketch_instances:
            resource_allocation = instance.get_resource_allocation()
            for key, val in resource_allocation:
                result[key] += val[1]
        return result
