import os

import config

def download_pcap():
    # wget_format = "wget --user hnamkung@andrew.cmu.edu --password=88997744 %s"
    wget_format = "wget --user ccs100203.cs10@nycu.edu.tw --password=rF2JQL4KTFrUxy4 %s"
    unzip_format = "gunzip %s"

    data_list = config.load()

    time_start = 130900
    time_end = 131200

    # print(pcap_storage_path)

    for data_dict in data_list:
        name = data_dict["name"]
        pcap_url = data_dict["pcap_url"]
        date = data_dict["date"]
        pcap_gz_format = data_dict["pcap_gz_format"]
        # print(name)
        pcap_folder = os.path.join("caida", name)

        os.makedirs(os.path.join(pcap_folder, "60s"), exist_ok=True)
        for time in range(time_start, time_end, 100):

            pcap_gz_file = pcap_gz_format % (date, time)
            wget_cmd = wget_format % (pcap_url + pcap_gz_file)
            pcap_file = pcap_gz_file.split(".gz")[0]

            if os.path.isfile(os.path.join(pcap_folder, "60s", pcap_file)) == False:
                # wget
                print(wget_cmd)
                os.system(wget_cmd)

                # unzip
                unzip_cmd = unzip_format % pcap_gz_file
                print(unzip_cmd)
                os.system(unzip_cmd)

                # mv
                mv_cmd = "mv %s %s" % (pcap_file, os.path.join(pcap_folder, "60s"))
                print(mv_cmd)
                os.system(mv_cmd)

# download_pcap()

def download_pcap_specify_time():
    # wget_format = "wget --user hnamkung@andrew.cmu.edu --password=88997744 %s"
    wget_format = "wget --user ccs100203.cs10@nycu.edu.tw --password=rF2JQL4KTFrUxy4 %s"
    unzip_format = "gunzip %s"

    data_list = config.load()

    time_list = [130100, 130500, 131000, 133000, 140000]

    # print(pcap_storage_path)

    for data_dict in data_list:
        name = data_dict["name"]
        pcap_url = data_dict["pcap_url"]
        date = data_dict["date"]
        pcap_gz_format = data_dict["pcap_gz_format"]
        # print(name)
        pcap_folder = os.path.join("caida_specify_time", name)

        os.makedirs(os.path.join(pcap_folder, "60s"), exist_ok=True)
        for time in time_list:

            pcap_gz_file = pcap_gz_format % (date, time)
            wget_cmd = wget_format % (pcap_url + pcap_gz_file)
            pcap_file = pcap_gz_file.split(".gz")[0]

            if os.path.isfile(os.path.join(pcap_folder, "60s", pcap_file)) == False:
                # wget
                print(wget_cmd)
                os.system(wget_cmd)

                # unzip
                unzip_cmd = unzip_format % pcap_gz_file
                print(unzip_cmd)
                os.system(unzip_cmd)

                # mv
                mv_cmd = "mv %s %s" % (pcap_file, os.path.join(pcap_folder, "60s"))
                print(mv_cmd)
                os.system(mv_cmd)

download_pcap_specify_time()