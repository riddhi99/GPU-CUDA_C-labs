#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <cuda.h>

__global__ void image_conversion(unsigned char *colorImage, unsigned char *grayImage, int imageWidth, int imageHeight) 
{
	
  	int x = threadIdx.x + blockIdx.x * blockDim.x; 
  	
  	int y = threadIdx.y + blockIdx.y * blockDim.y; 

	int idx = x*blockDim.y + y;

	if(idx<imageWidth*imageHeight)
	{
	  	int r,g,b;
		r = colorImage[3*idx];
		g = colorImage[3*idx+1];
		b = colorImage[3*idx+2];
	  	
		grayImage[idx] = (unsigned char)((21*r + 71*g + 7*b)/100);
	}
}

int main( int argc, char* argv[] )
{
	FILE *fptr = fopen("block_parallel_image_conversion.txt", "w");
	//fprintf(fptr, "imageHeight x imageWidth \t Time(milli) \n", );

	int i, j;

	for (i = 7; i < 28; i++)
	{	

		for(j=5; j<11; j++)
		{

			unsigned char *colorImage_cpu;
			unsigned char *grayImage_cpu;

			char header[100];
			long long imageWidth, imageHeight, ccv;

			char filename[50];
			snprintf(filename, sizeof(filename), "Lenna_%d.ppm", i); 

			FILE *color = fopen(filename, "rb");

			fscanf(color, "%s\n%lld %lld\n%lld\n", header, &imageWidth, &imageHeight, &ccv);

			size_t bytes = imageWidth*imageHeight*sizeof(unsigned char);

			colorImage_cpu = (unsigned char*)malloc(bytes*3);
			grayImage_cpu = (unsigned char*)malloc(bytes);

			fread(colorImage_cpu, sizeof(unsigned char), imageWidth*imageHeight*3, color);

			fclose(color);

			unsigned char *colorImage_gpu;
			unsigned char *grayImage_gpu;
			
			cudaMalloc(&colorImage_gpu, bytes*3);
			cudaMalloc(&grayImage_gpu, bytes);

			cudaEvent_t start, stop;
			cudaEventCreate(&start);
			cudaEventCreate(&stop);

			cudaMemcpy(colorImage_gpu, colorImage_cpu, bytes*3, cudaMemcpyHostToDevice);
			cudaMemcpy(grayImage_gpu, grayImage_cpu, bytes, cudaMemcpyHostToDevice);

			int x, y;
			x = pow(2, floor((float)j/2.0));
			y = pow(2, ceil((float)j/2.0));
			dim3 blocksize(x, y);
			dim3 gridsize((int)ceil((float)imageHeight/(float)x),(int)ceil((float)imageWidth/(float)y));

			//blocksize = 1024;
			//gridsize = (int)ceil((float)(imageWidth*imageHeight)/blocksize);

			//printf("here\n");

			cudaEventRecord(start);
			image_conversion<<<gridsize, blocksize>>>(colorImage_gpu, grayImage_gpu, imageWidth, imageHeight);
			cudaEventRecord(stop);

			cudaEventSynchronize(stop);

			float milliseconds = 0;
			cudaEventElapsedTime(&milliseconds, start, stop);

			cudaMemcpy( grayImage_cpu, grayImage_gpu, bytes, cudaMemcpyDeviceToHost );
		 
		    	cudaFree(colorImage_gpu);
		    	cudaFree(grayImage_gpu);
		 
			fprintf(fptr, "%d %d %dx%d %ldx%ld %lf\n", i, j, x, y, imageWidth, imageHeight, milliseconds);
		     
		 	free(colorImage_cpu);
		    	free(grayImage_cpu);
		}
	}

	fclose(fptr);

	return 0;
}
