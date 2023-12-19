class Sketch:
    def __init__(self, name):
        self.name = name

class FlowKey:
    def __init__(self, name):
        self.name = name

class Metric:
    def __init__(self, name):
        self.name = name

class ResourceAllocation:
    def __init__(self):
        self.allocation_map = {}

    def __str__(self):
        return str(self.allocation_map)

    def __repr__(self):
        return self.__str__()

    def add_resource(self, resource, allocation):
        self.allocation_map[resource] = allocation

    def get_resource_allocation(self):
        return self.allocation_map

class DeployedSketchInstance:
    def __init__(self, sketch, resource_allocation):
        self.sketch = sketch
        self.resource_allocation = resource_allocation

    def get_resource_allocation(self):
        return self.resource_allocation.get_resource_allocation()

#class SketchInstances:
#    def __init__(self, sketches, resource_allocations):
#        self.sketches = sketches
#        self.resource_allocations = resource_allocations
#
#        self.sketch_instances = [SketchInstance(s, r) for (s, r) in zip(self.sketches, self.resource_allocations)]
#
#    def get_accuracies(self, profilers):
#        return [p.get_accuracy(s) for (s, p) in zip(self.sketch_instances, profilers)]
