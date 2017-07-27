
import subprocess

p = subprocess.Popen("df -h".split(), stdout=subprocess.PIPE)

for line in p.stdout:
     rec=line.strip().split()	# parse the line into a rec
     if "/dev/" in rec[0]:
     	diskFree=rec[4]
     	diskName=rec[8]
     	print "<tr><td class='label'>%s</td><td class='value'>%s</td></tr>" % (diskName,diskFree)



