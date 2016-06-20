CXX=/Users/anilanar/Downloads/emsdk_portable/emscripten/1.35.0/em++
CXXFLAGS=-std=c++11 -O3 -Wall
LFLAGS=-O3 -s ALLOW_MEMORY_GROWTH=1 --memory-init-file 0 -Wall
EXPORT=-s EXPORTED_FUNCTIONS="['_run']" # -s ASSERTIONS=1

DBC=lib/vector_dbc
BC=build/main.bc build/libVector_DBC.bc build/jsonxx.bc
OBJS=build/main.o

.PHONY: all clean $(DBC)/lib/libVector_DBC.dylib
all: dist/main.js

dist/main.js: $(BC)
				@mkdir -p dist
			  $(CXX) $(LFLAGS) $(EXPORT) -o $@ $^

build/libVector_DBC.bc: $(DBC)/lib/libVector_DBC.dylib
				cp $^ $@

$(DBC)/lib/libVector_DBC.dylib:
				@mkdir -p $(DBC)/build
				cmake -E chdir $(DBC)/build \
				cmake .. -DCMAKE_CXX_COMPILER=$(CXX) -DCMAKE_CXX_FLAGS=-std=c++11 -DCMAKE_CC_COMPILER=$(CC)
				make -C $(DBC)/build install DESTDIR=..

$(DBC)/include/DBC.h: $(DBC)/lib/libVector_DBC.dylib

build/jsonxx.bc: lib/jsonxx/jsonxx.cc
				@mkdir -p $(@D)
				$(CXX) $(CXXFLAGS) -o $@ $^

build/main.bc: $(OBJS) $(DBC)/include/DBC.h
				@mkdir -p build
				$(CXX) -I./$(DBC)/include -I./lib/jsonxx $(CXXFLAGS) $(EXPORT) -o $@ $(OBJS)

build/%.o: src/%.cpp $(DBC)/include/DBC.h
				@mkdir -p build
				$(CXX) -I./$(DBC)/include -I./lib/jsonxx $(CXXFLAGS) $(EXPORT) -o $@ $<

clean:
			  if [ -a $(DBC)/build/Makefile ]; then make -C $(DBC)/build clean; fi;
				rm -rf build
				rm -rf dist