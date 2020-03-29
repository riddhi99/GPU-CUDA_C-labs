import matplotlib.pyplot as plt
import math

f = open("program.txt","r")

s = []
tp = []

for i in f:
	#print(i)
	t=i.split()
	s.append(int(t[0]))
	if (t[1]=="inf"):
		tmp = float("inf")
		tp.append(tmp)	
	else:
		tp.append(float(t[1]))

plt.plot(s,tp)
plt.xlabel('Size (Bytes)')
plt.ylabel('Throughput (Bytes/sec)')
plt.savefig('resulted_plot.png')
plt.show()


