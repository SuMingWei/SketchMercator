import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as gc
import grpc

from tofino_control_plane.python.querysketch.module.common.table import Table




def value_iteration(number_list, limit):
    if len(number_list) == 1:
        yield [0]
        yield [1]
        return

    for partial_number_list in value_iteration(number_list[1:], limit):
        if sum(partial_number_list) <= limit:
            yield [0] + partial_number_list
        if sum(partial_number_list) + 1 <= limit:
            yield [1] + partial_number_list


class ABOVE_THRESHOLD_TABLE(Table):

    def __init__(self, client, bfrt_info, table_name, row, type):
        # set up base class
        super(ABOVE_THRESHOLD_TABLE, self).__init__(client, bfrt_info)

        print("[PYTHON] table init - %s" % table_name)
        self.table = self.bfrt_info.table_get(table_name)
        self.table_name = table_name
        self.row = row
        self.type = type

    def configure(self):
        target = gc.Target(device_id=0, pipe_id=0xffff)
        #  1 means est < threshold
        #  0 means est >= threshold
        print("Configure - %s" % self.table_name)
        self.clear()
        if self.type == "cm":
            # if all of them are 0
            tuple_list = []
            for r in range(1, self.row+1):
                tuple_list.append(gc.KeyTuple('diff_%d[31:31]' % r, 0))
            self.table.entry_add(
                target,
                [self.table.make_key(
                    tuple_list
                )],
                [
                self.table.make_data(
                    [],
                    'above_threshold_table_act'
                    )
                ]
            )

        elif self.type == "cs":
            number_list = [i for i in range(1, self.row+1)]
            # print(self.row)
            # print(number_list)
            # print()

            number_limit_for_zero = int((self.row+1)/2)
            number_limit_for_one = self.row - number_limit_for_zero

            for value_list in value_iteration(number_list, number_limit_for_one):
                print(value_list)
                tuple_list = []
                for i, value in enumerate(value_list, 1):
                    tuple_list.append(gc.KeyTuple('diff_%d[31:31]' % i, value))
                self.table.entry_add(
                    target,
                    [self.table.make_key(
                        tuple_list
                    )],
                    [
                    self.table.make_data(
                        [],
                        'above_threshold_table_act'
                        )
                    ]
                )
