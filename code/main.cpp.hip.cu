#include "hip/hip_runtime.h"
// Inspiration and code snippets borrowed from my lecturer Doctor Jan Westerholm at AAU.
// Victor Anderssén 2022 Fall

#include <hip/hip_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include <inttypes.h>

// Cpp spec does shenanigans with the usage of <static>, let's be explicit in what
// we mean with 'static'
#define internal static
#define local_persist static
#define global_variable static

#define gpuErrchk(ans)                        \
    {                                         \
        gpuAssert((ans), __FILE__, __LINE__); \
    }
inline void gpuAssert(hipError_t code, const char *file, int line, bool abort = true)
{
    if (code != hipSuccess)
    {
        fprintf(stderr, "GPUassert: %s %s %d\n", hipGetErrorString(code), file, line);
        if (abort)
            exit(code);
    }
}

/* @Note(Victor):
 * All thread/kernel receives these four params as the dim3 type
 *
 * gridDim : gridDim.x, gridDim.y, gridDim.z
 * blockIdx : blockIdx.x, blockIdx.y, blockIdx.z
 * blockDim : blockDim.x, blockDim.y, blockDim.z
 * threadIdx: threadIdx.x, threadIdx.y, threadIdx.z */
__global__ void measure_kernel_memory_transfer_overhead_kernel()
{
}

internal int
get_device()
{
    int deviceCount;
    hipGetDeviceCount(&deviceCount);
    printf("   Found %d CUDA devices\n", deviceCount);

    if (deviceCount < 0 || deviceCount > 128)
    {
        return (-1);
    }

    int device;
    for (device = 0; device < deviceCount; ++device)
    {
        hipDeviceProp_t deviceProp;
        hipGetDeviceProperties(&deviceProp, device);
        printf("         Device %s                    = device %d\n", deviceProp.name, device);
        printf("         compute capability           =         %d.%d\n", deviceProp.major, deviceProp.minor);
        printf("         totalGlobalMemory            =        %.2lf GB\n", deviceProp.totalGlobalMem / 1000000000.0);
        printf("         l2CacheSize                  =    %8d B\n", deviceProp.l2CacheSize);
        printf("         regsPerBlock                 =    %8d\n", deviceProp.regsPerBlock);
        printf("         multiProcessorCount          =    %8d\n", deviceProp.multiProcessorCount);
        printf("         maxThreadsPerMultiprocessor  =    %8d\n", deviceProp.maxThreadsPerMultiProcessor);
        printf("         sharedMemPerBlock            =    %8d B\n", (int)deviceProp.sharedMemPerBlock);
        printf("         warpSize                     =    %8d\n", deviceProp.warpSize);
        printf("         clockRate                    =    %8.2lf MHz\n", deviceProp.clockRate / 1000.0);
        printf("         maxThreadsPerBlock           =    %8d\n", deviceProp.maxThreadsPerBlock);
        printf("         maxGridSize                  =    %d x %d x %d\n",
               deviceProp.maxGridSize[0], deviceProp.maxGridSize[1], deviceProp.maxGridSize[2]);
        printf("         maxThreadsDim                =    %d x %d x %d\n",
               deviceProp.maxThreadsDim[0], deviceProp.maxThreadsDim[1], deviceProp.maxThreadsDim[2]);
    }

    hipSetDevice(0);
    hipGetDevice(&device);

    if (device != 0)
    {
        printf("   Unable to set device 0, using %d instead", device);
    }
    else
    {
        printf("   Using CUDA device %d\n\n", device);
    }

    return (0);
}

int main(int argc, char *argv[])
{
    printf("        Starting the program\n");

    get_device();

    struct timeval st, et;
    struct timezone _tzone;
    const unsigned long N = 1L;
    gettimeofday(&st, &_tzone);

    // Main body
    dim3 threadsInBlock(32, 32);
    dim3 blocksInGrid = dim3(
        ceil((N + threadsInBlock.x - 1) / threadsInBlock.x),
        ceil((N + threadsInBlock.y - 1) / threadsInBlock.y));

    printf("====================================================================\n");
    printf("blocksInGrid:\t{%d, %d, %d} blocks.\nthreadsInBlock:\t%d threads.\n",
           blocksInGrid.x, blocksInGrid.y, blocksInGrid.z, threadsInBlock.x * threadsInBlock.y * threadsInBlock.z);

    const long int number_of_threads = (long int)(threadsInBlock.x * ((long)(threadsInBlock.y)) * threadsInBlock.z * ((blocksInGrid.x * blocksInGrid.y) * blocksInGrid.z));

    printf("number of threads: %ld\n", number_of_threads);

    // Call the GPU kernel(s)
    measure_kernel_memory_transfer_overhead_kernel<<<blocksInGrid, threadsInBlock>>>();

    gpuErrchk(hipGetLastError());
    gpuErrchk(hipDeviceSynchronize());
    // Main body end

    gettimeofday(&et, &_tzone);

    int elapsed = ((et.tv_sec - st.tv_sec) * 1000000) + (et.tv_usec - st.tv_usec);
    printf("        The program took %d microseconds\n", elapsed);
    printf("        The program took %d milliseconds\n", elapsed / 1000);
    printf("        The program took %f seconds\n", double((double)elapsed / 1000000.0));
    printf("        To execute the GPU kernel\n");

    return (0);
}
