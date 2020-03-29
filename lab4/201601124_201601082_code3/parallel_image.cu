#include<stdio.h>
#include<stdlib.h>
#define CHANNELS 3
#define in_COMPONENT_COLOR 255
#define RGB_COMPONENT_COLOR 255
#define HALF_WIDTH 4

typedef struct {
     unsigned char red,green,blue;
} PPMPixel;

typedef struct {
     int x, y;
     PPMPixel *data;
} PPMImage;


__global__ void colCon(unsigned char * outImg, unsigned char *inImage, int width, int height, int pwidth, int sz) {
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;
  
  int n=sz*2+1;
//int sa=n*n;
  int r[51], g[51], b[51];
  //int *arr;
  if(x<width && y<height){
    int idxI = (y+sz) * pwidth + (x+sz);
    int filIdx=idxI;
    idxI=idxI-((pwidth)*(sz)+(sz));
    for(int i=0;i<n;i++){
      for(int j=0; j<n; j++){
        int idx=i*n+j;
//         arr[idx]=(int)(256*256*inImage[CHANNELS*idxI]+256*inImage[CHANNELS*idxI+1]+
// inImage[CHANNELS*idxI+2]);
        r[idx]=(int)inImage[CHANNELS*idxI];
        g[idx]=(int)inImage[CHANNELS*idxI+1];
        b[idx]=(int)inImage[CHANNELS*idxI+2];
        idxI++;
      }
      idxI+=pwidth-n-1;
    }

    for(int i=0;i<n*n-1;i++){
      for(int j=0;j<n*n-i-1;j++){
        // if(arr[j]>arr[j+1]){
        //   int temp=arr[j];
        //   arr[j]=arr[j+1];
        //   arr[j+1]=temp;
        if(r[j]>r[j+1]){
          int temp=r[j];
          r[j]=r[j+1];
          r[j+1]=temp;
        } 
        if(g[j]>g[j+1]){
          int temp=g[j];
          g[j]=g[j+1];
          g[j+1]=temp;
        } 
        if(b[j]>b[j+1]){
          int temp=b[j];
          b[j]=b[j+1];
          b[j+1]=temp;
        } 
      }
    }
    // int mid=(n*n)/2;
    // outImg[CHANNELS*filIdx+2]=arr[mid]%256;
    // arr[mid]=arr[mid]>>8;
    // outImg[CHANNELS*filIdx+1]=arr[mid]%256;
    // arr[mid]=arr[mid]>>8;
    // outImg[CHANNELS*filIdx]=arr[mid]%256;
    outImg[CHANNELS*filIdx]=(unsigned char)r[(n*n)/2];
    outImg[CHANNELS*filIdx+1]=(unsigned char)g[(n*n)/2];
    outImg[CHANNELS*filIdx+2]=(unsigned char)b[(n*n)/2];
    
  }
}

static PPMImage *readPPM(const char *filename)
{
  char buff[16];
  PPMImage *img;
  FILE *fp;
  int c, rgb_comp_color;
  //open PPM file for reading
  fp = fopen(filename, "rb");
  if (!fp) {
  fprintf(stderr, "Unable to open file '%s'\n", filename);
  exit(1);
  }
  //read image format
  if (!fgets(buff, sizeof(buff), fp)) {
  perror(filename);
  exit(1);
  }
  //check the image format
  if (buff[0] != 'P' || buff[1] != '6') {
  fprintf(stderr, "Invalid image format (must be 'P6')\n");
  exit(1);
  }
  //alloc memory form image
  img = (PPMImage *)malloc(sizeof(PPMImage));
  if (!img) {
  fprintf(stderr, "Unable to allocate memory\n");
  exit(1);
  }
  //check for comments9
  c = getc(fp);
  while (c == '#') {
  while (getc(fp) != '\n') ;
  c = getc(fp);
  }
  ungetc(c, fp);
  //read image size information
  if (fscanf(fp, "%d %d", &img->x, &img->y) != 2) {
  fprintf(stderr, "Invalid image size (error loading '%s')\n", filename);
  exit(1);
  }
  //read rgb component
  if (fscanf(fp, "%d", &rgb_comp_color) != 1) {
  fprintf(stderr, "Invalid rgb component (error loading '%s')\n", filename);
  exit(1);
  }
  //check rgb component depth
  if (rgb_comp_color!= RGB_COMPONENT_COLOR) {
  fprintf(stderr, "'%s' does not have 8-bits components\n", filename);
  exit(1);
  }
  while (fgetc(fp) != '\n') ;
  //memory allocation for pixel data
  img->data = (PPMPixel*)malloc(img->x * img->y * sizeof(PPMPixel));
  if (!img) {
  fprintf(stderr, "Unable to allocate memory\n");
  exit(1);
  }
  //read pixel data from file
  if (fread(img->data, 3 * img->x, img->y, fp) != img->y) {
  fprintf(stderr, "Error loading image '%s'\n", filename);
  exit(1);
  }
  fclose(fp);
  return img;
}

void writePPM(const char *filename, PPMImage *img)
{
FILE *fp;
//open file for output
fp = fopen(filename, "wb");
if (!fp) {
fprintf(stderr, "Unable to open file '%s'\n", filename);
exit(1);
}
//write the header file
//image format
fprintf(fp, "P6\n");
//image size
fprintf(fp, "%d %d\n",img->x,img->y);
// rgb component depth
fprintf(fp, "%d\n",RGB_COMPONENT_COLOR);
// pixel data
fwrite(img->data, 3 * img->x, img->y, fp);
fclose(fp);
}

PPMImage  *padImage(PPMImage *img,int size){
  PPMImage *paddedImg = (PPMImage *)malloc(sizeof(PPMImage));
  int h = (img->y+2*size);
  int w = (img->x+2*size);
  printf("size: %d, h: %d, w: %d\n", size,h,w);
  paddedImg->data = (PPMPixel*)malloc(h * w * sizeof(PPMPixel));
  paddedImg->x = w;
  paddedImg->y = h;
  memset(paddedImg->data, 0, h * w * sizeof(unsigned char));
  printf("Image Initialized\n");
   for(int i=0; i<img->y; i++){
       for(int j=0; j<img->x; j++){
       int idxP=(i+size)*w+(j+size);
       int idx=i*img->x+j;
       //printf("i: %d, j: %d, idx: %d, idxP: %d\n",i,j,idx,idxP);
      paddedImg->data[idxP]= img->data[idx];
      //paddedImg->data[idxP].green = img->data[idx].green;
      //paddedImg->data[idxP].blue = img->data[idx].blue;
      }
   }
   for(int j=0;j<size;j++ ){
     for(int i=0;i<paddedImg->y;i++){
       int idxP=i*w+j;
       paddedImg->data[idxP]=paddedImg->data[i*w+size];
    }
   }

   for(int j=paddedImg->x-size ; j< paddedImg->x;j++){
     for(int i=0;i<paddedImg->y;i++){
       int idxP=i*w+j;
        paddedImg->data[idxP]=paddedImg->data[i*w-size-1];
    }
   }

   for(int i=0;i<size;i++){
     for(int j=0;j<paddedImg->x;j++){
       int idxP=i*w+j;
      paddedImg->data[idxP]=paddedImg->data[(size)*w+j];
    }
   }

   for(int i=(paddedImg->y-size);i<(paddedImg->y);i++){

     for(int j=0;j<paddedImg->x;j++){
       int idxP=i*w+j;
       paddedImg->data[idxP]=paddedImg->data[(paddedImg->y-size-1)*w+j];
     }
   }
   return paddedImg;
}

int main(int argc, char **argv){

    PPMImage *image,*filtered,*padedImg;
    unsigned char *in, *out;
    int bytes, sz, n;
    float elapsed;
    
    sz= atoi(argv[1]);
    printf("Size Initialized\n");
    n = 2*sz+1;

    image = readPPM(argv[2]);
    printf("Before padding: h: %d w: %d\n", image->y, image->x);
    padedImg=padImage(image,sz);
    bytes = padedImg->x * padedImg->y * 3;
    out = (unsigned char*)malloc(bytes * sizeof(unsigned char));
    printf("After padding: h: %d w: %d", padedImg->y, padedImg->x);

    cudaEvent_t start,stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    cudaMalloc(&in, bytes * sizeof(unsigned char));
    cudaMalloc(&out, bytes * sizeof(unsigned char));

    cudaMemcpy(in,padedImg->data,bytes,cudaMemcpyHostToDevice);

    dim3 gridSize((padedImg->x-1)/16+1,(padedImg->y-1)/16+1,1);
    dim3 blockSize(16,16,1);

    cudaEventRecord(start);
    colCon<<<gridSize,blockSize>>>(out,in,image->x,image->y,padedImg->x,sz);
    cudaEventRecord(stop);
    
    cudaDeviceSynchronize();
    cudaEventElapsedTime(&elapsed, start, stop);
    printf(",%f\n", elapsed);

    filtered = (PPMImage *)malloc(sizeof(PPMImage));
    filtered->x = padedImg->x;
    filtered->y = padedImg->y;
    filtered->data = (PPMPixel*)malloc(bytes * sizeof(PPMPixel));
    
    cudaMemcpy(filtered->data,out,bytes,cudaMemcpyDeviceToHost);

    writePPM("medianOutput.ppm",filtered);
    //printf("conversion complete");
    cudaFree(in);
    cudaFree(out);
    return 0;

  }





