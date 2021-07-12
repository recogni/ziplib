# Installation Config
PREFIX		?= /usr

# Final names of binaries
LIB_NAME	= zip
EXECUTABLE	= Bin/zipsample
SO_LIBRARY	= Bin/lib$(LIB_NAME).so
STATIC_LIB	= Bin/lib$(LIB_NAME).a

# C & C++ compiler
CC        ?= clang
CXX       ?= clang++
CFLAGS    ?= -fPIC -Wno-enum-conversion -O3
CXXFLAGS  ?= -fPIC -std=c++17 -O3

# Linker flags
LDFLAGS   = -pthread

# Sources of external libraries
SRC_ZLIB  = $(wildcard Source/ZipLib/extlibs/zlib/*.c)
SRC_LZMA  = $(wildcard Source/ZipLib/extlibs/lzma/unix/*.c)
SRC_BZIP2 = $(wildcard Source/ZipLib/extlibs/bzip2/*.c)

# ZipLib sources
SRC = \
		$(wildcard Source/ZipLib/*.cpp)        \
		$(wildcard Source/ZipLib/detail/*.cpp)

# Object files			
OBJS = \
		$(SRC:.cpp=.o)	   \
		$(SRC_ZLIB:.c=.o)  \
		$(SRC_LZMA:.c=.o)  \
		$(SRC_BZIP2:.c=.o)

# Rules
all: $(EXECUTABLE) $(STATIC_LIB) $(SO_LIBRARY)
.PHONY: all

shared-lib: $(SO_LIBRARY)
.PHONY: shared-lib

static-lib: $(STATIC_LIB)
.PHONY: static-lib

sample: $(EXECUTABLE)
.PHONY: sample

bindir:
	mkdir -p Bin

$(EXECUTABLE): $(OBJS) | bindir
	$(CXX) $(CXXFLAGS) $(LDFLAGS) Source/Sample/Main.cpp -o $@ $^
	cp -n Source/Sample/in1.jpg Source/Sample/in2.png Source/Sample/in3.txt Bin/

$(STATIC_LIB): $(OBJS) | bindir
	ar rcs $@ $^

$(SO_LIBRARY): $(OBJS) | bindir
	$(CXX) $(LDFLAGS) -shared -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf `find Source -name '*.o'` ziplib.tar.gz Bin/* $(EXECUTABLE) $(SO_LIBRARY) $(STATIC_LIB)
.PHONY: clean

tell-libs:
	@echo -l$(LIB_NAME)

install:
	cp $(SO_LIBRARY) $(STATIC_LIB) $(PREFIX)/lib 2> /dev/null || true
	cp $(EXECUTABLE) $(PREFIX)/bin 2> /dev/null || true
	cd Source/ZipLib && find . -name '*.h' -exec cp --parents {} $(PREFIX)/include \;
