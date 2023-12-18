class Flowkey:
    def __init__(self, key, src_addr, src_port, dst_addr, dst_port, proto):
        self.key = key
        self.src_addr = src_addr
        self.src_port = src_port
        self.dst_addr = dst_addr
        self.dst_port = dst_port
        self.proto = proto

    def __repr__(self):
        return "%15u %15u %5u %5u %5u" % (self.src_addr, self.dst_addr, self.src_port, self.dst_port, self.proto)

    def __eq__(self, other):
        if self.key == other.key and \
            self.src_addr == other.src_addr and \
            self.src_port == other.src_port and \
            self.dst_addr == other.dst_addr and \
            self.dst_port == other.dst_port and \
            self.proto == other.proto:
            return True
    
    def null(self):
        if self.src_addr == 0 and self.src_port == 0 and self.dst_addr == 0 and self.dst_addr == 0 and self.proto == 0:
            return True
        return False

def parse_line(key, line):
    string_key = line.split(") ")[0]
    string_key += ")"

    left = line.split(") ")[1]

    left = left.replace("]", "")
    left = left.replace("[", "")
    splitted = left.split(" ")
    estimate = int(splitted[0])

    flowkey = Flowkey(key, int(splitted[1]), int(splitted[2]), int(splitted[3]), int(splitted[4]), int(splitted[5]))

    return string_key, estimate, flowkey

# def parse_line(line):
#     key = line.strip().split(") ")[0] + ')'
#     key = key.replace("scr", "src")
#     second = line.strip().split(") ")[1]
#     int_key = int(second.split(" ")[0])
#     value = int(second.split(" ")[1])
#     return key, int_key, value
#
#
# def parse_univmon_line(line):
#     # print(line)
#     key = line.strip().split(") ")[0] + ')'
#     second = line.strip().split(") ")[1]
#     int_key = int(second.split(" ")[0])
#     value = int(second.split(" ")[1])
#     # hash = int(second.split(" ")[2])
#     return key, int_key, value
#     # return key, int_key, value, hash
