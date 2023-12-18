from scapy.all import * 

from table.exact_table import EXACT_TABLE
from table.flowkey_register_table import FLOWKEY_REGISTER_TABLE
# from lib.file_saver import FileSaver
import netaddr

class FLOWKEY_LEARN:
    def __init__(self, gc, bfrt_info, simulator, is_print):

        self.exact_table = EXACT_TABLE(gc, bfrt_info)
        # self.flowkey_register_table = FLOWKEY_REGISTER_TABLE(gc, bfrt_info, 4, simulator)
        self.flowkey_register_table = FLOWKEY_REGISTER_TABLE(gc, bfrt_info, 65536, simulator)
        self.simulator = simulator
        self.is_print = is_print

        self.flowkey_storage_dict = {}
        self.logging = []
        self.from_hash_table = []

    def sniff(self):
        if self.simulator == 0:
            if self.is_print:
                print('Wait for sniff, iface=enp5s0')
            sniff(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="enp5s0")
        else:
            if self.is_print:
                print('Wait for sniff, iface=veth250')
            sniff(prn=self.process_pkt, filter='ether proto 0xBF01', store=0,  iface="veth250")

    def process_pkt(self, pkt):
        if self.is_print:
            print('New packet received!')
        try:
            original_pkt = Ether(pkt[Ether].load)

            src_addr = original_pkt[IP].src
            src_addr_int = int(netaddr.IPAddress(src_addr))
            if self.is_print:
                print(src_addr, src_addr_int)

            # self.from_hash_table
            if self.is_print:
                print(pkt[Ether].src)
            
            if pkt[Ether].src == "bb:bb:bb:bb:bb:bb":
                print("packet from hash table")
                self.from_hash_table.append((src_addr_int, src_addr))
                print(self.from_hash_table)
            else:
                print("packet NOT from hash table")
                if src_addr_int in self.flowkey_storage_dict:
                    if self.is_print:
                        print("key already exist", src_addr, src_addr_int)
                    self.logging.append((src_addr_int, src_addr))
                else:
                    if self.is_print:
                        print("add src IP into the table", src_addr, src_addr_int)
                    self.flowkey_storage_dict[src_addr_int] = src_addr
                    self.exact_table.add_entry(src_addr_int)
                    self.logging.append((src_addr_int, src_addr))
        except Exception as e:
            print("[flowkey_learn.py] packet parse fail")
            print(e.message)
            print(e.args)

    def save(self, folder_name, control_plane_dict_name, control_plane_logging_name, hash_table_name):

        print("save dict - count (%d)" % len(self.flowkey_storage_dict.keys()))
        fs1 = FileSaver(folder_name, control_plane_dict_name)
        fs1.save_dict(self.flowkey_storage_dict, is_print=self.is_print)

        print("save list - count (%d)" % len(self.logging))
        fs2 = FileSaver(folder_name, control_plane_logging_name)
        fs2.save_list(self.logging, is_print=self.is_print)

        print("save register")
        self.flowkey_register_table.load_registers()
        self.flowkey_register_table.save_to_file(folder_name, hash_table_name, is_print=self.is_print)

    def clear_exact_table(self):
        print("clear exact table")
        self.exact_table.tableClear()

    def clear_flowkey_table(self):
        print("clear exact table")
        self.flowkey_register_table.tableClear()
