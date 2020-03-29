#include<stdio.h>
//#include <math.h>
#include <time.h>
#include <sys/time.h>

#define int long long
#define ll long long
#define N 100000000

struct timeval start, stop;

void vector_addition(double *a, double *b, double *c)
{
	int i;
	for(i=0; i<N; i++)
	{
		c[i] = a[i] + b[i];
	}
}

int main()
{
	ll minSize = pow(2,8);
	ll maxSize = pow(2,28);
	int cnt = 0;
	
	int n = 20;
	
	ll size = minSize;
	double throughput[n];
	
	FILE *fptr;
   	fptr = fopen("program.txt", "w");
	
	for (size = minSize; size<maxSize; size*=2)
	{
		int * a=(int*)malloc(N*sizeof(int));
		int * b=(int*)malloc(N*sizeof(int));
		int * c=(int*)malloc(N*sizeof(int));
		int i;
		for(i=0; i<N; i++)
		{
			a[i] = i; b[i] = 4+i;
		}

		double end_time;

		gettimeofday(&start,NULL);
		double start_t = stop.tv_sec*1000000 + start.tv_usec;
	
		vector_addition(a, b, c);
	
		gettimeofday(&stop,NULL);
		double stop_t = stop.tv_sec*1000000+stop.tv_usec;
		end_time = stop_t - start_t;	
	
	
		throughput[cnt] = (sizeof(int) * 4 * size)/end_time;

		fprintf(fptr,"%ld %lf\n",size,throughput[cnt]);
		cnt++;	
	}
	fclose(fptr);	
	return 0;
}
