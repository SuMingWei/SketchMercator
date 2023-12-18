from scapy.all import * 

# from scapy.sendrecv import AsyncSniffer

# from table.exact_table import EXACT_TABLE
# from lib.file_saver import FileSaver
import netaddr

class FLOWKEY_LEARN:
    def __init__(self, gc, bfrt_info, simulator, is_print):

        # self.exact_table = EXACT_TABLE(gc, bfrt_info)
        self.simulator = simulator
        self.is_print = is_print
        self.flowkey_storage_dict = {}

        # if self.simulator == 0:
        #     if self.is_print:
        #         print('Async sniff [Tofino HW], iface=enp5s0')
        #     self.t = AsyncSniffer(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="enp5s0")
        # else:
        #     if self.is_print:
        #         print('Async sniff [simulator], iface=veth250')
        #     self.t = AsyncSniffer(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="veth250")

    def sniff_start(self):
        print("sniff start")
        sniff(prn=self.process_pkt, iface="enp5s0")
        # # self.t.start()
        # if self.simulator == 0:
        #     if self.is_print:
        #         print('sniff [Tofino HW], iface=enp5s0')
        #     sniff(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="enp5s0")
        # else:
        #     if self.is_print:
        #         print('sniff [simulator], iface=veth250')
        #     sniff(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="veth250")

    def process_pkt(self, pkt):
        print('New packet received!')
        if self.is_print:
            print('New packet received!')
        try:
            original_pkt = Ether(pkt[Ether].load)
            print(original_pkt.show())

            src_addr = original_pkt[IP].src
            src_addr_int = int(netaddr.IPAddress(src_addr))
            if self.is_print:
                print(src_addr, src_addr_int)

            self.flowkey_storage_dict[src_addr_int] = src_addr
            # if src_addr_int in self.flowkey_storage_dict:
            #     if self.is_print:
            #         print("key already exist", src_addr, src_addr_int)
            #     self.logging.append((src_addr_int, src_addr))
            # else:
            #     if self.is_print:
            #         print("add src IP into the table", src_addr, src_addr_int)
            #     self.flowkey_storage_dict[src_addr_int] = src_addr
            #     self.exact_table.add_entry(src_addr_int)
            #     self.logging.append((src_addr_int, src_addr))
        except Exception as e:
            print("[flowkey_learn.py] packet parse fail")
            print(e.message)
            print(e.args)

    def clear_and_save(self):
        print("clear and save")
        print(self.flowkey_storage_dict)

