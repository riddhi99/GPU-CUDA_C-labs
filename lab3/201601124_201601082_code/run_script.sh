#!bin/bash

./serial_image

./block_CD

./block_parallel

./parallel_image

python block_plot.py

python CD_plot.py

python time_plot.py

python speedup_plot.py