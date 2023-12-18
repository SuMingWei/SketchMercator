ifndef SDE_INSTALL
$(error SDE_INSTALL is not set)
endif

ARCH = tofino
PROFILE := test
DEBUGLEVEL = 1
ifeq ($(profile), debug)
	CXXFLAGS += -DDEBUGLEVEL=$(DEBUGLEVEL)
endif

CC = gcc

CFLAGS  = -DSDE_INSTALL=\"$(SDE_INSTALL)\"              \
          -I$(SDE_INSTALL)/include                      \
          -I$(SDE_INSTALL)/include/$(ARCH)/pdfixed \
          -I$(tofino_cp)/cpp/SketchMD/src

BF_LIBS  = -lbf_switchd_lib        \
           -lbfutils               \
           -lpi                    \
           -lpi_dummy              \
           -lpifeproto             \
           -ltofinopdfixed_thrift  \
           -lavago                 \
           -ldriver                \
           -lbfutils               \
           -lbfsys                 \
           -lpython3.4m

LDFLAGS  = -Wl,-rpath,$(SDE_INSTALL)/lib
LDLIBS   = -L$(SDE_INSTALL)/lib
LDLIBS  += -Wl,--start-group $(BF_LIBS) -Wl,--end-group
LDLIBS  += -lm -pthread -lpcap -lstdc++ -ldl -levent -lthrift

common_objects = $(patsubst %.cpp, %.o, $(wildcard src/common/*.cpp))
bf_lib_objects = $(patsubst %.cpp, %.o, $(wildcard src/bf_library/*.cpp))
library_objects = $(patsubst %.cpp, %.o, $(wildcard src/library/*.cpp))
sketch_objects = $(patsubst %.cpp, %.o, $(wildcard src/sketch/*/*.cpp))

all: $(common_objects) $(bf_lib_objects) $(library_objects) $(sketch_objects) sketch
	@echo $(common_objects)
	@echo $(library_objects)
	@echo $(sketch_objects)
	@echo 'Successfully finished building.'

%.o: %.cpp %.h
	$(CC) $(CFLAGS) $< -c -o $@ $(LDLIBS) $(LDFLAGS)

sketch: $(common_objects) $(bf_lib_objects) $(library_objects) $(sketch_objects) sketch_main.cpp
	$(CC) $(CFLAGS) sketch_main.cpp -o sketch $(common_objects) $(bf_lib_objects) $(library_objects) $(sketch_objects) $(LDLIBS) $(LDFLAGS)

clean:
	rm -f sketch
	rm -f $(common_objects)
	rm -f $(bf_lib_objects)
	rm -f $(library_objects)
	rm -f $(sketch_objects)
