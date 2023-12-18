from pcap_sender.SketchLib.lib.com import turn_on_switch_cpp
from pcap_sender.SketchLib.lib.com import turn_on_switch_python
from pcap_sender.SketchLib.lib.com import turn_off_switch_python
from pcap_sender.SketchLib.lib.com import turn_off_switch_cpp

from pcap_sender.SketchLib.lib.com import send_msg_cpp, send_msg_python

from pcap_sender.SketchLib.lib.tcpreplay import tcpreplay_execute

from python_lib.hun_timer import hun_timer

from time import sleep

sketch_list = ["cm_O6", "fcm_O6", "fcm_topk"]

def pcap_send():
    
    # read heavy flowkey from python
    send_msg_python("flowkey_start/small_ether.pcap")
    hun_timer("flowkey start", 2)

    tcpreplay_execute("/users/hnamkung/tcpreplay/p1.pcap")
    # tcpreplay_execute("/users/hnamkung/tcpreplay/small_ether.pcap")

    # # read register from C++
    # send_msg_cpp("read/small_ether.pcap")


    # # reset register from C++
    # send_msg_cpp("reset/small_ether.pcap")

    # pass

def main():
    for sketch_name in sketch_list:
        # turn_on_switch_cpp(sketch_name)
        # hun_timer("turn_on_switch", 15)

        # turn_on_switch_python(sketch_name)
        # hun_timer("turn_on_python", 5)

        pcap_send()
        # turn_off_switch_python(sketch_name)
        # hun_timer("turn_off_python", 3)

        # turn_off_switch_cpp(sketch_name)
        # hun_timer("turn_off_switch", 5)

        break

if __name__=="__main__":
    main()
