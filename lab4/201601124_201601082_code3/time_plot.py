import matplotlib.pyplot as plt
import math

#time plot comparison between serial and parallel image converson for 32x32 block size

fs = open("serial_image_conversion.txt", "r")
fp = open("parallel_image_conversion.txt", "r")

size = []
p = []
ser = []

for i, j in zip(fs, fp):
	ts = i.split()
	tp = j.split()
	
	size.append(int(ts[0]))
	p.append(float(tp[2]))
	ser.append(float(ts[2]))
	
plt.plot(size[3:], ser[3:], marker='^', label="serial")
plt.plot(size[3:], p[3:], marker='o', label="parallel")
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3, ncol=2, mode="expand", borderaxespad=0.)
plt.ylabel('Time (milliseconds)')
plt.xlabel('Size (2^n Bytes)')
plt.savefig('time_analysis_32x32_block.png')
plt.show()
