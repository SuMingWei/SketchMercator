CC=g++ -std=c++11
PROFILER= -pg
LINK = -lpcap

hash_module = $(patsubst %.cpp, %.o, $(wildcard ../cpp/*.cpp))
library_objects = $(patsubst %.cpp, %.o, $(wildcard ../../library/*.cpp))

all: $(hash_module) $(library_objects) main

%.o: %.cpp %.h
	$(CC) -c -Wall $< -o $@
#	@echo $@ # .o
#	@echo $< # .cpp
#	@echo $^ # .cpp .h

main:  main.cpp $(hash_module) $(library_objects)
	$(CC) -o main main.cpp $(hash_module) $(library_objects) $(LINK)

clean:
	rm -f main
	rm -f ../cpp/*.o
	rm -f ../../library*.o
