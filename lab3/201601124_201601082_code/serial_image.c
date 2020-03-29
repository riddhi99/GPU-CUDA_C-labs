#include<stdio.h>
#include<stdlib.h>
#include <sys/time.h>
#include <time.h>

struct timeval start, stop;

int main()
{
	int i;

	FILE *fptr = fopen("serial_image_conversion.txt", "w");
	//fprintf(fptr, "imageHeight x imageWidth \t Time(milli) \n");

	for(i=7; i<28; i++)
	{
		long long imageWidth, imageHeight, ccv; 
		long long imageChannels=3;
		
		char filename[50];
		snprintf(filename, sizeof(filename), "Lenna_%d.ppm", i);
		//printf("%s\n", filename);		

		FILE *fp = fopen(filename, "rb");
		
		char header[100];
		
		fscanf(fp,"%s\n%lld %lld\n%lld\n", header, &imageWidth, &imageHeight, &ccv);
		
		//unsigned char colorImage[imageWidth*imageHeight*3];
		//unsigned char grayImage[imageWidth*imageHeight];

		// If the above lines give seg fault uncomment these 2 lines and comment those 2
		unsigned char* colorImage = (unsigned char*)malloc(imageWidth*imageHeight*3*sizeof(unsigned char));
		unsigned char* grayImage = (unsigned char*)malloc(imageWidth*imageHeight*sizeof(unsigned char));
		
		int ii, jj, idx;
		
		fread(colorImage, sizeof(unsigned char), imageWidth*imageHeight*3, fp);
		
		//FILE *gray = fopen("gray.ppm", "wb");
	        //fprintf(gray, "P5\n%d %d\n255\n", imageWidth, imageHeight);
		
	    double end_time;
		gettimeofday(&start,NULL);
		double start_t = stop.tv_sec*1000000 + start.tv_usec;

		for(idx=0; idx<imageHeight*imageWidth; idx++)
		{
			unsigned char r, g, b;
			r = colorImage[3*idx];
			g = colorImage[3*idx + 1];
			b = colorImage[3*idx + 2];
							
			grayImage[idx] = ((21*r + 71*g + 7*b)/100);	
		}
		
		gettimeofday(&stop,NULL);
		double stop_t = stop.tv_sec*1000000+stop.tv_usec;
		end_time = (stop_t - start_t)/1000;

		fprintf(fptr, "%d %ldx%ld %lf\n", i, imageHeight, imageWidth, end_time);

		//fwrite(grayImage, sizeof(unsigned char), imageWidth*imageHeight, gray);
		//fclose(gray);
		fclose(fp);
		free(colorImage);
	        free(grayImage);
	}
	
	fclose(fptr);
	return 0;
}
