import sys
sys.path.append("../py")

from hash import compute_hash

# hash_params = [16807, 3057642, 1622650073, 0, 4294967295]
# hash_params = [26940434, 26438502, 470211272, 0, 4294967295]
# hash_params = [16807, 3057642, 807681803, 0, 4294967295]
hash_params = [13456091, 14884994, 807681803, 0, 4294967295]

# flowkey = [2289198401, 100, 146116538, 53, 6]
flowkey = [964048477, 100, 146116538, 53, 6]



class Flowkey:
    def __init__(self, key, src_addr, src_port, dst_addr, dst_port, proto):
        self.key = key
        self.src_addr = src_addr
        self.src_port = src_port
        self.dst_addr = dst_addr
        self.dst_port = dst_port
        self.proto = proto

    def __repr__(self):
        return "%u %u %u %u %u" % (self.src_addr, self.src_port, self.dst_addr, self.dst_port, self.proto)

for key in ["srcIP",
            "srcIP, dstIP",
            "srcIP, dstIP, proto",
            "srcIP, dstIP, dstPort",
            "srcIP, dstIP, dstPort, proto",
            "srcIP, srcPort",
            "srcIP, srcPort, dstIP",
            "srcIP, srcPort, dstIP, proto",
            "srcIP, srcPort, dstIP, dstPort, proto"]:
    # flowkey_flags = parse_key_flags(key)
    # masked_flowkey = get_flowkey(flowkey, flowkey_flags)
    # flowkey = Flowkey(key, 2289198401, 100, 146116538, 53, 6)
    flowkey = Flowkey(key, 964048477, 100, 146116538, 53, 6)
    print(key)
    ret1 = compute_hash(flowkey, "universal_hash", hash_params, 2048)
    ret2 = compute_hash(flowkey, "crc_hash", hash_params, 2048)
    print("%d 0x%X\n" % (ret1, ret2))
