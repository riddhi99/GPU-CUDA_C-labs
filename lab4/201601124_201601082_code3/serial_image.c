#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <math.h>

struct timeval start, stop;

#define PGMHeaderSize 0x40
#define RGB_COMPONENT_COLOR 255
#define LEN(arr) ((int) (sizeof (arr) / sizeof (arr)[0]))
#define CREATOR "Kirtana_anery"
int comp (const void * a, const void * b) {
   return ( *(int*)a - *(int*)b );
}

typedef struct {
     unsigned unsigned char red,green,blue;
} PPMPixel;

typedef struct {
     int x, y;
     PPMPixel *data;
} PPMImage;

typedef struct {
  unsigned char pix;
} PGMPixel;

typedef struct {
  int x, y;
  PGMPixel *data;
} PGMImage;

static PPMImage *readPPM(const unsigned char *filename)
{
         unsigned char buff[16];
         PPMImage *img;
         FILE *fp;
         int c, max_value;
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

    //check for comments
    c = getc(fp);
    while (c == '#') {
    while (getc(fp) != '\n')
    ;
         c = getc(fp);
    }

    ungetc(c, fp);
    //read image size information
    if (fscanf(fp, "%d %d", &img->x, &img->y) != 2) {
         fprintf(stderr, "Invalid image size (error loading '%s')\n", filename);
         exit(1);
    }

    //read rgb component
    if (fscanf(fp, "%d", &max_value) != 1) {
         fprintf(stderr, "Invalid rgb component (error loading '%s')\n", filename);
         exit(1);
    }

    //check rgb component depth
    if (max_value!= RGB_COMPONENT_COLOR) {
         fprintf(stderr, "'%s' does not have 8-bits components\n", filename);
         exit(1);
    }

    while (fgetc(fp) != '\n')
    ;
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
PPMImage  *padImage(PPMImage *img,int size){
  PPMImage *paddedImg = (PPMImage *)malloc(sizeof(PPMImage));
  int h = (img->y+2*size);
  int w = (img->x+2*size);
  printf("size: %d, h: %d, w: %d\n", size,h,w);
  paddedImg->data = (PPMPixel*)malloc(h * w * sizeof(PPMPixel));
  paddedImg->x = w;
  paddedImg->y = h;
  memset(paddedImg->data, 0, h * w * sizeof(PPMPixel));
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

PGMImage *convertGrayscale(PPMImage *img)
{
  int i;
  if(img){
    PGMImage *grs = (PGMImage*) (malloc(sizeof(PGMImage)));
    grs->x = img->x;
    grs->y = img->y;
    grs->data = (PGMPixel*) (malloc(grs->x * grs->y * sizeof(PGMPixel)));
    for(i=0; i<img->x*img->y; i++){
      grs->data[i].pix = (char) (0.21*img->data[i].red + 0.71*img->data[i].green +
    0.07*img->data[i].blue);
    }
    return grs;
    }
}

PPMImage *medianFilter(PPMImage *img, int sz){
  int i;
  int len=pow((2*sz+1),2);
    printf("HERE\n");
  PPMImage *filtered = (PPMImage*)(malloc(sizeof(PPMImage)));
  filtered->x = img->x;
  filtered->y = img->y;
  filtered->data = (PPMPixel*)(malloc(img->x * img->y * sizeof(PPMPixel)));
  if(img){
      printf("THEREEE\n");
    for(int k=sz;k<(img->y-sz);k++){
      for(int m=sz;m<(img->x-sz);m++){
        int * r=(int*)malloc(len*sizeof(int));
        int * g=(int*)malloc(len*sizeof(int));
        int * b=(int*)malloc(len*sizeof(int));
        int idxI=k*img->x+m;
        int filIdx=idxI;
        idxI=idxI-((img->x)*(sz) +(sz));
        for(int i=0;i<(2*sz+1);i++){
          for(int j=0; j<(2*sz+1); j++){
            int idx=i* (2*sz+1) +j;
            r[idx]=(int)img->data[idxI].red;
            g[idx]=(int)img->data[idxI].green;
            b[idx]=(int)img->data[idxI].blue;
            idxI++;
          }
          idxI+=img->x-(2*sz+1)-1;
        }
        qsort (r,len, sizeof(int),comp);
        qsort (g,len, sizeof(int),comp);
        qsort (b,len, sizeof(int),comp);
        filtered->data[filIdx].red=(unsigned char)r[(len)/2];
        filtered->data[filIdx].green=(unsigned char)g[(len)/2];
        filtered->data[filIdx].blue=(unsigned char)b[(len)/2];
      }

    }
  }
  printf("*******%d*****\n*******%d*****\n",filtered->x ,filtered->y);
    return filtered;
}

void writePGM(const char *filename, PGMImage *img)
{
    FILE *fp;
    //open file for output
    fp = fopen(filename, "wb");
    printf("HI in write");
    if (!fp) {
        fprintf(stderr, "Unable to open file '%s'\n", filename);
        exit(1);
    }
    //write the header file
    //image format
    fprintf(fp, "P5\n");
    //image size
    fprintf(fp, "%d %d\n",img->x,img->y);
    // rgb component depth
    fprintf(fp, "%d\n",RGB_COMPONENT_COLOR);
    // pixel data
    fwrite(img->data, img->x, img->y, fp);
    fclose(fp);
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
    fwrite(img->data, 3*img->x, img->y, fp);
    fclose(fp);
}

int main(){
    PPMImage *image;
    image = readPPM("img3.pbm");
    printf("reading successful\n");
    //double end_time;
    //gettimeofday(&start,NULL);
    //double start_t = start.tv_sec*1000000 + start.tv_usec;
    //printf("Start %lf\n",start_t);
    int sz=3;
    printf("Size Initialized\n");
    PPMImage *padedImg=padImage(image,sz);
    //writePPM("paddedImg.ppm",padedImg);
    //printf("%d %d\n",padedImg->x,padedImg->y);
    //PGMImage *grs = convertGrayscale(padedImg);
    //writePGM("gray1.ppm",grs);
    PPMImage *fil=medianFilter(padedImg,sz);

    printf("Calculated!");
    writePPM("median_out.ppm",fil);
    /*gettimeofday(&stop,NULL);
    double stop_t = stop.tv_sec*1000000 + stop.tv_usec;
    printf("Stop %lf\n",stop_t);
    end_time = (stop_t - start_t)/1000;
    printf("%lf\n", end_time);
    */
    return 0;
}
