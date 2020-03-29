default: serial_image block_CD block_parallel parallel_image

serial_image: serial_image.c
	gcc serial_image.c -o serial_image

block_CD: block_CD.cu
	nvcc block_CD.cu -o block_CD

block_parallel: block_parallel.cu
	nvcc block_parallel.cu -o block_parallel

parallel_image: parallel_image.cu
	nvcc parallel_image.cu -o parallel_image

clean:
	rm serial_image block_CD block_parallel parallel_image
