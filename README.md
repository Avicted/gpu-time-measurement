# Cuda Template for AMD GPUs on Linux

The template invokes an empty kernel and measures the amount of time it
takes for the kernel to start up, execute and end.

```bash
# Install the needed packages
sudo yay -S rocm-cmake rocm-core rocm-device-libs rocm-llvm hip-runtime-amd

# Add the ROCm compiler and scripts to the user path
# Typically inside of ~/.bashrc or ~/.zshrc
# source the config file (source ~/.zshrc) or start a new terminal session after
# the addition of the hip/bin path
export PATH="/opt/rocm/hip/bin:$PATH"
```

## Run

```bash
make
```

## Example output

```bash
Cleaning
rm -r build 2> /dev/null || true
rm -r code/*.o 2> /dev/null || true
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
      Device AMD Radeon RX 6900 XT                  device 0
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
         concurrentKernels            =       Using CUDA device 0

====================================================================
blocksInGrid:   {1, 1, 1} blocks.
threadsInBlock: 1024 threads.
number of threads: 1024
        Total memory allocated = 0.0 MB
        The program took 172707 microseconds
        The program took 172 milliseconds
        The program took 0.172707 seconds
        To execute the GPU kernel

The program has been built and runned successfully!
```
