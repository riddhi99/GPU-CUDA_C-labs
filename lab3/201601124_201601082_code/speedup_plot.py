import matplotlib.pyplot as plt
import math

#Speedup curve for different block sizes

f = open("block_parallel_image_conversion.txt", "r")
fs = open("serial_image_conversion.txt", "r")

size_problem = []
p5 = []
p6 = []
p7 = []
p8 = []
p9 = []
p10 = []
ps = []

for i in fs:
	ts = i.split()
	ps.append(float(ts[2]))

cnt = 0

for i in f:
	t = i.split()

	if(int(t[1])==5):
		size_problem.append(float(t[0]))
		p5.append(ps[cnt]/float(t[4]))
	elif(int(t[1])==6):	
		p6.append(ps[cnt]/float(t[4]))
	elif(int(t[1])==7):
		p7.append(ps[cnt]/float(t[4]))
	elif(int(t[1])==8):
		p8.append(ps[cnt]/float(t[4]))
	elif(int(t[1])==9):
		p9.append(ps[cnt]/float(t[4]))
	else:
		p10.append(ps[cnt]/float(t[4]))
		cnt+=1
	
plt.plot(size_problem[1:], p5[1:], marker='h', label="4x8")
plt.plot(size_problem[1:], p6[1:], marker='*', label="8x8")
plt.plot(size_problem[1:], p7[1:], marker='o', label="8x16")
plt.plot(size_problem[1:], p8[1:], marker='^', label="16x16")
plt.plot(size_problem[1:], p9[1:], marker='|', label="16x32")
plt.plot(size_problem[1:], p10[1:], marker='p', label="32x32")

plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3, ncol=3, mode="expand", borderaxespad=0.)
plt.ylabel('Speedup')
plt.xlabel('Size (2^n Bytes)')
plt.savefig('speedup_analysis_blocks.png')
plt.show()
