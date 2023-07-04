# Cuda Template for AMD GPUs on Linux

The template invokes an empty kernel and measures the amount of time it
takes for the kernel to start up, execute and end.

```bash
# Install the needed packages
sudo pacman -S opencl-amd opencl-amd-dev

# Add the ROCm compiler and scripts and executable to the user path
# Typically inside of ~/.bashrc or ~/.zshrc
# source the config file (source ~/.zshrc) or start a new terminal session after
export PATH="/opt/rocm-5.5.0/bin:$PATH" # <--- change version to the installed
```

## Run

```bash
make
```

## Example output

```bash
Cleaning
rm -r build 2> /dev/null || true
rm -r code/*.cu 2> /dev/null || true

Creating directories
mkdir -p build

Hipifying the Cuda C++ code to HIP C++ code
hipify-perl ./code/main.cpp -o ./code/main.cpp.hip.cu

Building the program
hipcc -O3  ./code/main.cpp.hip.cu -o ./build/gpu_signal_processing.out

Running the executable
./build/gpu_signal_processing.out
        Starting the program
   Found 1 CUDA devices
         Device AMD Radeon RX 6900 XT                    = device 0
         compute capability           =         10.3
         totalGlobalMemory            =        17.16 GB
         l2CacheSize                  =     4194304 B
         regsPerBlock                 =       65536
         multiProcessorCount          =          40
         maxThreadsPerMultiprocessor  =        2048
         sharedMemPerBlock            =       65536 B
         warpSize                     =          32
         clockRate                    =     2660.00 MHz
         maxThreadsPerBlock           =        1024
         maxGridSize                  =    2147483647 x 2147483647 x 2147483647
         maxThreadsDim                =    1024 x 1024 x 1024
   Using CUDA device 0

====================================================================
blocksInGrid:	{1, 1, 1} blocks.
threadsInBlock:	1024 threads.
number of threads: 1024
        The program took 164043 microseconds
        The program took 164 milliseconds
        The program took 0.164043 seconds
        To execute the GPU kernel

The program has been built and runned successfully!

```
