#include<stdio.h>

#define int long long
#define ll long long
#define N 10000000

void square_set_no(double *a, double *c)
{
	int i;
	for(i=0; i<N; i++)
	{
		c[i] = a[i]*a[i];
	}
}

int main()
{
	int * a=(int*)malloc(N*sizeof(int));
	//int * b=(int*)malloc(N*sizeof(int));
	int * c=(int*)malloc(N*sizeof(int));
	int i;
	for(i=0; i<N; i++)
	{
		a[i] = 2+i;
	}

	square_set_no(a, c);
		
	return 0;
}
