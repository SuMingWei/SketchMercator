# sudo ./test 127.0.0.1 read_delay 0 small
# sudo ./test 127.0.0.1 read_delay 0 large
# sudo ./test 127.0.0.1 hw_behave 0 None
# sudo ./test 127.0.0.1 reset 0 None

# sudo ./sketch 127.0.0.1 mrb 0 None
# sudo ./sketch 127.0.0.1 mrb_opt 0 None
# sudo ./sketch 127.0.0.1 mrb_pingpong 0 None
# sudo ./sketch 127.0.0.1 cs 0 None
sudo ./sketch 127.0.0.1 cm baseline 1024
# sudo ./sketch 127.0.0.1 mrb baseline 16384
# sudo ./sketch 127.0.0.1 cs pingpong 1024
# sudo ./sketch 127.0.0.1 cs sol3
# sudo ./sketch 127.0.0.1 cs pingpong
# sudo ./sketch 127.0.0.1 cs noreset
# sudo ./sketch 127.0.0.1 cs sol3
# sudo ./sketch 127.0.0.1 univmon baseline
# sudo ./sketch 127.0.0.1 mrb baseline
# sudo ./sketch 127.0.0.1 hll baseline
# sudo ./sketch 127.0.0.1 cs baseline
# sudo ./sketch 127.0.0.1 cm baseline
# sudo ./sketch 127.0.0.1 univmon pingpong
