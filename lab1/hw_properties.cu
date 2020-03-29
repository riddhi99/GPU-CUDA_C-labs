#include<stdio.h>
#include<cuda.h>

int main()

{

    int devCount;

    cudaGetDeviceCount(&devCount);

    printf("CUDA Device Query...\n");

    printf("There are %d CUDA devices.\n", devCount);

 
    for (int i = 0; i < devCount; ++i)
    {

        // Get device properties

        printf("\nCUDA Device #%d\n", i);

        cudaDeviceProp devProp;

        cudaGetDeviceProperties(&devProp, i);

        printf("Device Name: %s\n", devProp.name);
        printf("Total Global Memory: %d\n", devProp.totalGlobalMem);
	printf("Maximum Threads per Block: %d\n", devProp.maxThreadsPerBlock);
	printf("Maximum Threads Dimension in X-axis: %d\n", devProp.maxThreadsDim[0]);
	printf("Maximum Threads Dimension in Y-axis: %d\n", devProp.maxThreadsDim[1]);
	printf("Maximum Threads Dimension in Z-axis: %d\n", devProp.maxThreadsDim[2]);
	printf("Maximum Grid Size in X-axis: %d\n", devProp.maxGridSize[0]);
	printf("Maximum Grid Size in Y-axis: %d\n", devProp.maxGridSize[1]);
	printf("Maximum Grid Size in Z-axis: %d\n", devProp.maxGridSize[2]);
	printf("Warp Size: %d\n", devProp.warpSize);
	printf("Clock Rate: %d\n", devProp.clockRate);
	printf("Shared Memory Per Block: %d\n", devProp.sharedMemPerBlock);
	printf("Registers Per Block: %d\n", devProp.regsPerBlock);
	printf("Maximum pitch in bytes allowed by memory copies: %d\n", devProp.memPitch);
	printf("Total Constant Memory: %d\n", devProp.totalConstMem);
	printf("Major compute capability: %d\n", devProp.major);
	printf("Minor compute capability: %d\n", devProp.minor);
	printf("Alignment required for textures: %d\n", devProp.textureAlignment);
	printf("Device can concurrently copy memory and execute a kernel: %d\n", devProp.deviceOverlap);
	printf("Number of multiprocessors on device: %d\n", devProp.multiProcessorCount);
	printf("Specified whether there is a run time limit on kernels: %d\n", devProp.kernelExecTimeoutEnabled);
	printf("Device is integrated as opposed to discrete: %d\n", devProp.integrated);
	printf("Device can map host memory with cudaHostAlloc/cudaHostGetDevicePointer: %d\n", devProp.canMapHostMemory);
	printf("Compute mode: %d\n", devProp.computeMode);
	printf("Device can possibly execute multiple kernels concurrently: %d\n", devProp.concurrentKernels);
	printf("Device has ECC support enabled: %d\n", devProp.ECCEnabled);
	printf("PCI bus ID of the device: %d\n", devProp.pciBusID);
	printf("PCI device ID of the device: %d\n", devProp.pciDeviceID);
	printf("1 if device is a Tesla device using TCC driver, 0 otherwise: %d\n", devProp.tccDriver);
    }

    return 0;

}
