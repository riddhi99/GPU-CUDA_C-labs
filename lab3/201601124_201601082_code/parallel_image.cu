#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>

__global__ void image_conversion(unsigned char *colorImage, unsigned char *grayImage, long long imageWidth, long long imageHeight) 
{
  	int x = threadIdx.x + blockIdx.x * blockDim.x; 
  	
  	int y = threadIdx.y + blockIdx.y * blockDim.y; 

	int idx = x*blockDim.y + y;

	if(idx<imageWidth*imageHeight)
	{
		int r, g, b;
		r = colorImage[3*idx];
		g = colorImage[3*idx + 1];
		b = colorImage[3*idx + 2];
			
		grayImage[idx] = (unsigned char)((21*r + 71*g + 7*b)/100);
		//grayImage[idx] = (pixel);
		//grayImage[3*idx+1] = grayImage[3*idx+2] = grayImage[3*idx] = pixel;
	}
}

int main( int argc, char* argv[] )
{
	FILE *fptr = fopen("parallel_image_conversion.txt", "w");
	//fprintf(fptr, "imageHeight x imageWidth \t Time(milli) \n", );

	int i;

	for (i = 7; i < 28; i++)
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

		FILE *gray = fopen("gray.ppm", "wb");
		fprintf(gray, "P5\n%d %d\n255\n", imageWidth, imageHeight);
		fread(colorImage_cpu, sizeof(unsigned char), imageWidth*imageHeight*3, color);

		fclose(color);
		
		//for(int j=0; j<imageWidth*imageHeight*3; j++)
		//	printf("%d ", colorImage_cpu[j]);

		unsigned char *colorImage_gpu;
		unsigned char *grayImage_gpu;
		
		cudaMalloc(&colorImage_gpu, bytes*3);
		cudaMalloc(&grayImage_gpu, bytes);

		cudaEvent_t start, stop;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);

		cudaMemcpy(colorImage_gpu, colorImage_cpu, bytes*3, cudaMemcpyHostToDevice);
		cudaMemcpy(grayImage_gpu, grayImage_cpu, bytes, cudaMemcpyHostToDevice);

		dim3 blocksize(32, 32);
		dim3 gridsize((int)ceil((float)imageHeight/32.0),(int)ceil((float)imageWidth/32.0));

		//printf("%d %d\n",(int)ceil((float)imageHeight/32),(int)ceil((float)imageWidth/32));
		
		cudaEventRecord(start);
		image_conversion<<<gridsize, blocksize>>>(colorImage_gpu, grayImage_gpu, imageWidth, imageHeight);
		cudaEventRecord(stop);

		cudaEventSynchronize(stop);

		float milliseconds = 0;
		cudaEventElapsedTime(&milliseconds, start, stop);

		cudaMemcpy( grayImage_cpu, grayImage_gpu, bytes, cudaMemcpyDeviceToHost );
	 
	    	cudaFree(colorImage_gpu);
	    	cudaFree(grayImage_gpu);
	 
		fprintf(fptr, "%d %ldx%ld %lf\n", i, imageHeight, imageWidth, milliseconds);

		//for(int j=0; j<imageWidth*imageHeight; j++)
		//	printf("%hhu ", grayImage_cpu[j]);

		fwrite(grayImage_cpu, sizeof(unsigned char), imageWidth*imageHeight, gray); 
	 	fclose(gray);
		free(colorImage_cpu);
	    	free(grayImage_cpu);
	}

	fclose(fptr);

	return 0;
}
