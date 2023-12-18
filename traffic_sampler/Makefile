CC=g++ -std=c++11
PROFILER= -pg
LINK = -lpcap

CFLAGS = -I$(traffic_sampler)

CPP_LIB_PATH = ${sketch_home}/cpp_lib
INC = -I${CPP_LIB_PATH}
cpp_lib = $(patsubst %.cpp, %.o, $(wildcard ${CPP_LIB_PATH}/*/*.cpp))


all: $(cpp_lib) pcap_parser pcap_generator verify

%.o: %.cpp %.h
	$(CC) $(CFLAGS) $(INC) -c -Wall $< -o $@
#       @echo $@ # .o
#       @echo $< # .cpp
#       @echo $^ # .cpp .h

pcap_parser: pcap_parser.cpp $(cpp_lib)
	$(CC) $(CFLAGS) -o pcap_parser pcap_parser.cpp $(cpp_lib) $(LINK) $(INC)

pcap_generator: pcap_generator.cpp $(cpp_lib)
	$(CC) $(CFLAGS) -o pcap_generator pcap_generator.cpp $(cpp_lib) $(LINK) $(INC)

verify: verify.cpp $(cpp_lib)
	$(CC) $(CFLAGS) -o verify verify.cpp $(cpp_lib) $(LINK) $(INC)

clean:
	rm -f pcap_parser
	rm -f pcap_generator
	rm -f verify
	rm -f ./*.txt
	rm -f ${sketch_home}/cpp_lib/*/*.o