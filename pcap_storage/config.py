# date_list_2014 = [20140320, 20140619]
date_list_2014 = [20140320, 20140619]
pcap_url_format_2014 = "https://data.caida.org/datasets/passive-2014/equinix-sanjose/%d-130000.UTC/"
pcap_gz_format_2014 = "equinix-sanjose.dirA.%d-%d.UTC.anon.pcap.gz"
name_2014 = "%d"

# date_list_2016 = [20160121, 20160218, 20160317, 20160406]
date_list_2016 = [20160121]
pcap_url_format_2016 = "https://data.caida.org/datasets/passive-2016/equinix-chicago/%d-130000.UTC/"
pcap_gz_format_2016 = "equinix-chicago.dirA.%d-%d.UTC.anon.pcap.gz"
name_2016 = "%d"

# date_list_2018 = [20180315, 20180419, 20180517, 20180621, 20180719, 20180816, 20180921, 20181018, 20181115, 20181220]
date_list_2018 = [20180517, 20180621, 20180816, ]
# date_list_2018 = [20181018, 20181115, 20181220, ]
# date_list_2018 = [20180517, 20180621, 20180816, 20181018, 20181115, 20181220, ]
pcap_url_format_2018 = "https://data.caida.org/datasets/passive-2018/equinix-nyc/%d-130000.UTC/"
pcap_gz_format_2018 = "equinix-nyc.dirA.%d-%d.UTC.anon.pcap.gz"
name_2018 = "%d"


def load():
    data_list = []

#    a_dict = {}
#    di = date_list_2014[0]
#    a_dict["name"] = name_2014 % di
#    a_dict["pcap_url"] = pcap_url_format_2014 % di
#    a_dict["date"] = di
#    a_dict["pcap_gz_format"] = pcap_gz_format_2014
#    data_list.append(a_dict)

    # a_dict = {}
    # di = date_list_2014[1]
    # a_dict["name"] = name_2014 % di
    # a_dict["pcap_url"] = pcap_url_format_2014 % di
    # a_dict["date"] = di
    # a_dict["pcap_gz_format"] = pcap_gz_format_2014
    # data_list.append(a_dict)

    # a_dict = {}
    # di = date_list_2016[0]
    # a_dict["name"] = name_2016 % di
    # a_dict["pcap_url"] = pcap_url_format_2016 % di
    # a_dict["date"] = di
    # a_dict["pcap_gz_format"] = pcap_gz_format_2016
    # data_list.append(a_dict)

    for di in date_list_2018:
        a_dict = {}
        a_dict["name"] = name_2018 % di
        a_dict["pcap_url"] = pcap_url_format_2018 % di
        a_dict["date"] = di
        a_dict["pcap_gz_format"] = pcap_gz_format_2018
        data_list.append(a_dict)

    return data_list
