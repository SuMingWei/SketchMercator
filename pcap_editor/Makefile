CC=g++ -std=c++11
#GADGETLIB=GadgetReader
#IFLAG= -I $(GADGETLIB)
#LFLAG= $(GADGETLIB)/gadgetreader.o
PROFILER= -pg
LINK = -lpcap
SKETCH_HOME_PATH = ${sketch_home}
CPP_LIB_PATH = ${sketch_home}/cpp_lib
INC = -I${CPP_LIB_PATH}

cpp_lib = $(patsubst %.cpp, %.o, $(wildcard ${CPP_LIB_PATH}/*/*.cpp))

all: bin/split bin/split2 bin/sampling bin/counter bin/extension bin/filter bin/convert bin/maxflow $(cpp_lib)

%.o: %.cpp %.h
	$(CC) $(CFLAGS) -c -Wall $< -o $@ $(LINK)

bin/split: src/split.cpp
	$(CC) -o bin/split src/split.cpp $(LINK) $(INC)

bin/split2: src/split2.cpp
	$(CC) -o bin/split2 src/split2.cpp $(LINK) $(INC)

bin/sampling: src/sampling.cpp
	$(CC) -o bin/sampling src/sampling.cpp $(LINK) $(INC)

bin/counter: src/counter.cpp
	$(CC) -o bin/counter src/counter.cpp $(LINK) $(INC)

bin/extension: src/extension.cpp
	$(CC) -o bin/extension src/extension.cpp $(LINK) $(INC)

bin/filter: src/filter.cpp $(cpp_lib)
	$(CC) -o bin/filter src/filter.cpp $(cpp_lib) $(LINK) $(INC)

bin/convert: src/convert.cpp $(cpp_lib)
	$(CC) -o bin/convert src/convert.cpp $(cpp_lib) $(LINK) $(INC)

bin/maxflow: src/maxflow.cpp $(cpp_lib)
	$(CC) -o bin/maxflow src/maxflow.cpp $(cpp_lib) $(LINK) $(INC)

clean:
	rm -f bin/*
	rm -f $(cpp_lib)
