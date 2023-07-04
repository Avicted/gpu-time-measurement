# Build all cpp and hpp files in the code directory
# Output the executable into the build directory

# print arbitrary variables with $ make print-<name>
print-%  : ; @echo $* = $($*)

# define any compile-time flags
CPPFLAGS = -O3 # -g -Wall -Wextra -Wpedantic -Wno-unused-parameter
# CPPFLAGS += -I/usr/include

# define library paths in addition to /usr/lib
#   if I wanted to include libraries not in /usr/lib I'd specify
#   their path using -Lpath, something like:
#LDFLAGS 	 	:= -lm
#LDLIBS   		:= -L /usr/lib


SRC_DIR 	:= ./code
OBJ_DIR 	:= ./build
SRC_FILES   := $(shell find . -name '*.cpp')


# define the executable file 
TARGET = gpu_signal_processing

#
# The following part of the makefile is generic; it can be used to 
# build any executable just by changing the definitions above and by
# deleting dependencies appended to the file from 'make depend'
#

.PHONY: clean


all: clean dirs hipify $(TARGET)
	@echo
	@echo        The program has been built and runned successfully!

hipify:
	@echo
	@echo        Hipifying the Cuda C++ code to HIP C++ code
	hipify-perl $(SRC_FILES) -o $(SRC_FILES).hip.cu

$(TARGET):
	@echo
	@echo        Building the program
	hipcc $(CPPFLAGS) $(SRC_FILES).hip.cu -o ./build/$(TARGET).out

	@echo
	@echo        Running the executable
	./build/$(TARGET).out

dirs:
	@echo
	@echo        Creating directories
	mkdir -p build

clean:
	@echo
	@echo        Cleaning
	rm -r build 2> /dev/null || true
	rm -r code/*.cu 2> /dev/null || true

run:
	@echo
	@echo        Running the executable
	./build/$(TARGET).out
