sudo -E python2 $sketch_home/tofino_control_plane/python/SketchMD/tofino_main.py \
  --workload_name $1 \
  --program_name $2 \
  --before_after $3 \
  --pcap_name $4 \
  --date $5 \
  --caida_date $6 \
  --digest
