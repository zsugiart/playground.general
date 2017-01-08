import argparse
import os
import fnmatch
import datetime
import shutil
import sys

# see https://docs.python.org/3/library/argparse.html#the-add-argument-method
parser = argparse.ArgumentParser(description='Utilities to sort files into year and month folder. Scans [inputFolder] for file and sort them into year & months, folders created in [outputFolder]. When scanning, multiple [excludeFolder] can be added. if [testMode] is specified, it will not perform the actual sorting, only print the indexing result.')

parser.add_argument('--inputFolder', 
		required=True,
		dest='inputFolder', 
		help="input folder to sort")

parser.add_argument("--excludeFolder",
		required=False,
		action="append",
		dest="inputFolderExclude",
		help="list of folders to exclude, eg. --excludeFolder='bobcat' will exclude all folder containing the word 'bobcat'. can specify in multiple, eg. --excludeFolder='bob' --excludeFolder='cat'")

parser.add_argument("--outputFolder", 
		required=True,
		dest="outputFolder", 
		help="where output will be sorted to")

parser.add_argument("--testMode",
		required=False,
		dest="testMode",
		help="when specified, will not actually do sorting, just logs",
		action="store_true")

# Global variable to indicate if 
__TESTMODE=False

def idxYearMonth(inputDir, excludeList):
	print "# Indexing "+inputDir
	print "  exclude list: %s" % excludeList
	idx={}
	for root, dir, files in os.walk(inputDir):
		print "root   : "+root
		isExclude=False
		for exclude in excludeList:
			if exclude in root:
				isExclude=True
		if isExclude: continue
		for items in fnmatch.filter(files, "*"):
			fpath=os.path.join(root,items)

			# for files named "YYYYMMDD_*" parse from filename
			try: 
				ftime = datetime.datetime.strptime(items[:8], '%Y%m%d')
				ftime.strftime("%Y") # check and test if time is valid or not
			except: ftime = None
			
			# if doesn't work, try to parse from filename as ms from epoch
			# eg 1442968856129 but only take first 10 digit
			if ftime is None: 
				try:
					ftime = datetime.datetime.fromtimestamp(int(items[:10]))
					ftime.strftime("%Y")
				except: 
					print ("ERROR",sys.exc_info()[0])
					ftime = None

			# last resort, pick from OS last mod time, as this can change
			# easily from the way file is moved around
			if ftime is None:
				try: ftime=datetime.datetime.fromtimestamp(os.path.getmtime(fpath))
				except: print "!! ERROR parsing "+fpath

			ftimeYear = ftime.strftime("%Y")
			ftimeMonth= ftime.strftime("%m.%b")

			if ftimeYear not in idx: idx[ftimeYear]={}
			if ftimeMonth not in idx[ftimeYear]: idx[ftimeYear][ftimeMonth]=[]
			idx[ftimeYear][ftimeMonth].append(fpath)

			#print "%s\t%s" % ( fpath, ftimeYear+"/"+ftimeMonth )
	return idx

def __makeDir(path):
	global __TESTMODE
	if not __TESTMODE and not os.path.exists(path): os.makedirs(path)

def __copy2(f,destDir):
	global __TESTMODE
	if not __TESTMODE: shutil.copy2(f,destDir)

def main():
	global __TESTMODE
	args = parser.parse_args()
	print args.inputFolder
	print args.inputFolderExclude
	print args.outputFolder

	if args.testMode:
		print " ### TEST MODE ###"
		__TESTMODE=True

	idx = idxYearMonth(args.inputFolder, args.inputFolderExclude)

	__makeDir(args.outputFolder)

	for year in idx:
		print "## %s" % year
		ypath=os.path.join(args.outputFolder,year)
		__makeDir(ypath)

		for month in idx[year]:
			print " %s ---------------" % month
			mpath=os.path.join(ypath,month)
			__makeDir(mpath)
			for f in idx[year][month]:
				print "%s/%s > %s" % (year,month,f)
				__copy2(f,mpath)

				

if __name__ == "__main__": main()
