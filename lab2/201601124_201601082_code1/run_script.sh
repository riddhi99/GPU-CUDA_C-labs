#!/bin/bash

./hw_properties > hw_properties.txt

./square_parallel

./vec_parallel

./square_serial

gprof square_serial gmon.out > square_serial_analysis.txt

rm gmon.out

./vector_add_serial

gprof vector_add_serial gmon.out > vector_serial_analysis.txt

rm gmon.out

python speedup_both.py

python throughput_plot.py

python square_plot.py

python vector_plot.py

./vec_parallel_blocks

python througput_blocks.py

python time_blocks.py

python speed_blocks.py
