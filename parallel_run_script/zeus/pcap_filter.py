from env_setting.env_module import pcap_storage_path
from env_setting.env_module import pcap_editor_path
import os

pcap_input_folder = os.path.join(pcap_storage_path, "caida", "20140320", "60s")
# print(pcap_input_folder) # /data1/hun/sketch_home/pcap_storage/caida/20140320/60s

pcap_output_folder = os.path.join(pcap_storage_path, "zeus")
# print(pcap_output_folder) # /data1/hun/sketch_home/pcap_storage/zeus

filter_binary_path = os.path.join(pcap_editor_path, "bin", "filter")
# print(filter_binary_path) # /data1/hun/sketch_home/pcap_editor/bin/filter

dummy_location = os.path.join(pcap_editor_path, "dummy.pcap")
# print(dummy_location) # /data1/hun/sketch_home/pcap_editor/dummy.pcap

file_list = []
for file_name in sorted(os.listdir(pcap_input_folder)):
    file_list.append(file_name)

# file_name = file_list[0]
# if file_name.endswith(".pcap"):
#     filter_name = "syn"
#     final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)
#     # print(final_pcap_output_folder) # /data1/hun/sketch_home/pcap_storage/zeus/syn

#     cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, 2)
#     print(cmd)
#     # os.system(cmd)
#     # from python_lib.pcap_helper import convert_pcap_to_rawip
#     # convert_pcap_to_rawip(final_pcap_output_folder, file_name)

# file_name = file_list[1]
# if file_name.endswith(".pcap"):
#     filter_name = "syn"
#     final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)
#     # print(final_pcap_output_folder) # /data1/hun/sketch_home/pcap_storage/zeus/syn

#     cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, 2)
#     print(cmd)
#     os.system(cmd)
#     # from python_lib.pcap_helper import convert_pcap_to_rawip
#     # convert_pcap_to_rawip(final_pcap_output_folder, file_name)

cmd_list = []


count = 0
for file_name in file_list:
    if file_name.endswith(".pcap"):
        count += 1
        if count <= 2:
            num = 1
        else:
            num = 2
        if num == 1:
            continue
        filter_name = "dns"
        final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)

        cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, num)
        # print(cmd)
        cmd_list.append(cmd)
        # os.system(cmd)
        # from python_lib.pcap_helper import convert_pcap_to_rawip
        # convert_pcap_to_rawip(final_pcap_output_folder, file_name)

count = 0
for file_name in file_list:
    if file_name.endswith(".pcap"):
        count += 1
        if count <= 4:
            num = 1
        else:
            num = 2
        if num == 1:
            continue
        filter_name = "http"
        final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)

        cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, num)
        # print(cmd)
        cmd_list.append(cmd)
        # os.system(cmd)
        # from python_lib.pcap_helper import convert_pcap_to_rawip
        # convert_pcap_to_rawip(final_pcap_output_folder, file_name)



# file_list = []
# for file_name in sorted(os.listdir(pcap_input_folder)):
#     file_list.append(file_name)

# file_name = file_list[0]
# if file_name.endswith(".pcap"):
#     for filter_name in ["syn", "dns", "http"]:
#         final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)
#         # print(final_pcap_output_folder) # /data1/hun/sketch_home/pcap_storage/zeus/syn

#         cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, 1)
#         print(cmd)
#         os.system(cmd)
#         break
#     break


# pcap_input_folder = os.path.join(pcap_editor_path, "pcaps")
# file_name = "small.pcap"

# for filter_name in ["syn", "dns", "http"]:
#     final_pcap_output_folder = os.path.join(pcap_output_folder, filter_name)
#     # print(final_pcap_output_folder) # /data1/hun/sketch_home/pcap_storage/zeus/syn

#     cmd = "%s %s %s %s %s %s %d" % (filter_binary_path, pcap_input_folder, final_pcap_output_folder, file_name, dummy_location, filter_name, 3)
#     print(cmd)
#     os.system(cmd)
#     from python_lib.pcap_helper import convert_pcap_to_rawip
#     convert_pcap_to_rawip(final_pcap_output_folder, file_name)
#     break

for cmd in cmd_list:
    print(cmd)
from python_lib.run_parallel_helper import run_cmd_list
run_cmd_list(cmd_list, 32)
