import matplotlib.pyplot as plt
import math

fp = open("parallel_vector_add.txt", "r")
f = open("serial_vector_add.txt", "r")

n = []
b = [128, 256, 512, 1024]
speed0 = []
speed1 = []
speed2 = []
speed3 = []
#speed4 = []
cnt = 0

ser = []

for j in f:
	t = j.split()
	ser.append(float(t[1]))

for i in fp:
	t = i.split()
	#print(t[0])
	#n.append(math.log(long(t[0]), 2))
	tmp = float(t[2])
	if((long(t[1])) == 256):
		speed0.append(tmp)
		n.append(math.log(long(t[0]), 2))
	elif((long(t[1])) == 512):
		speed1.append(tmp)
	elif((long(t[1])) == 1024):
                speed2.append(tmp)
		cnt+=1
	elif((long(t[1])) == 128):
                speed3.append(tmp)
#	else:
#		speed4.append(tmp)
plt.plot(n, speed0, marker='h', label="256")
plt.plot(n, speed1, marker='*', label="512")
plt.plot(n, speed2, marker='o', label="1024")
plt.plot(n, speed3, marker='^', label="128")
#plt.plot(n, speed4, marker='|', label="4096")
#plt.ylabel('Speedup')
#plt.xlabel('Size (Bytes)')
'''
fp = open("parallel_square.txt", "r")
f = open("serial_square.txt", "r")

s = []
sup = []

for i, j in zip(f, fp):
        t = i.split()
        tp = j.split()
        #print(t[0])
        s.append(math.log(long(t[0]), 2))
	#print(s)
        if(tp[1] == "inf"):
                tmp = 0
                sup.append(tmp)
        elif(t[1] == "inf"):
                tmp = float("inf")
                sup.append(tmp)
        else:
                tmp = float(t[1])/float(tp[1])
                sup.append(tmp)
'''
#plt.plot(s, p, marker='o', label="parallel")
plt.legend(bbox_to_anchor=(0., 1., 1., .1), loc=3, ncol=2, mode="expand", borderaxespad=0.)
plt.ylabel('Time (milliseconds)')
plt.xlabel('Problem Size (2^n Bytes)')
plt.savefig('correct_time_vector.png')
#plt.show()
