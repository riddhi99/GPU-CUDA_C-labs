import matplotlib.pyplot as plt
import math

#block time plot comparison between different block sizes

f = open("block_CD_parallel_image_conversion.txt", "r")

size_problem = []
p4 = []
p5 = []
p6 = []
p7 = []
p8 = []
p9 = []
p10 = []

for i in f:
	t = i.split()
	
        if(int(t[1])==4):
                p4.append(int(t[0]))
	elif(int(t[1])==5):
		size_problem.append(int(t[0]))
		p5.append(float(t[4]))
	elif(int(t[1])==6):	
		p6.append(float(t[4]))
	elif(int(t[1])==7):
		p7.append(float(t[4]))
	elif(int(t[1])==8):
		p8.append(float(t[4]))
	elif(int(t[1])==9):
		p9.append(float(t[4]))
	else:
		p10.append(float(t[4]))
	
plt.plot(size_problem, p4, marker='s', label="4x4")        
plt.plot(size_problem, p5, marker='h', label="4x8")
plt.plot(size_problem, p6, marker='*', label="8x8")
plt.plot(size_problem, p7, marker='o', label="8x16")
plt.plot(size_problem, p8, marker='^', label="16x16")
plt.plot(size_problem, p9, marker='|', label="16x32")
plt.plot(size_problem, p10, marker='p', label="32x32")

plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3, ncol=3, mode="expand", borderaxespad=0.)
plt.ylabel('Time (milliseconds)')
plt.xlabel('Size (2^n Bytes)')
plt.savefig('time_CD_analysis_blocks.png')
plt.show()
