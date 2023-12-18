PCAP_NAME=equinix-chicago.dirA.20160121-130000.UTC.anon.pcap
PCAP_PATH=$pcap_storage/caida/20160121/60s/$PCAP_NAME

RESULT_GT=$result_gt
RESULT_SW_DP=$result_sw_dp

# # run gt
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_GT -z "20160121-130000" -r "gt" -p 1 -k "srcIP" -e 1
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_GT -z "20160121-130000" -r "gt" -p 1 -k "srcIP" -e 3
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_GT -z "20160121-130000" -r "gt" -p 1 -k "srcIP" -e 5
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_GT -z "20160121-130000" -r "gt" -p 1 -k "srcIP" -e 10

# # run hll
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "hll" -p 1 -k "srcIP" -w 2048 -d 1 -l 1 -c -e 1
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "hll" -p 1 -k "srcIP" -w 2048 -d 1 -l 1 -c -e 1 -a 100

# # run cs
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "cs" -p 1 -k "srcIP" -w 4096 -d 3 -l 1 -c -e 1
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "cs" -p 1 -k "srcIP" -w 4096 -d 5 -l 1 -c -e 1
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "cs" -p 1 -k "srcIP" -w 4096 -d 5 -l 1 -c -e 1 -a 100

# run hll sketch_aug mode
# ./main -f $PCAP_PATH -n $PCAP_NAME -o $RESULT_SW_DP -z "20160121-130000" -r "hll" -p 1 -k "srcIP" -w 2048 -d 1 -l 1 -c -e 1
