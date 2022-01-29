#!/usr/bin/env python3

import argparse
import os
import fnmatch
import datetime
import shutil
import sys
import glob
import subprocess
import codecs
from datetime import datetime

__TESTMODE=False

# see https://docs.python.org/3/library/argparse.html#the-add-argument-method
parser = argparse.ArgumentParser(description='Utilities that looks for *.mp4 files with mathcing descriptor file (.txt)')

parser.add_argument('--filter',
        required=False,
        default=".mp4",
        dest='filter',
        help="the filter to use, default to '.mp4'")

parser.add_argument('--dir',
        required=False,
        default=os.getcwd(),
        dest='dir',
        help="Directory where this will run. Default to current directory os.GetCwd()")

parser.add_argument("--testMode",
        required=False,
        dest="testMode",
        help="when specified, will not actually do sorting, just logs",
        action="store_true")

def ytdl_ffmpeg(osDirPath,filelistFilter):
    print("osDirPath=%s" % osDirPath)
    print("filelistFilter=%s" % filelistFilter)

    for glob_filename in glob.glob("*%s"%filelistFilter):
        filepath=os.path.join(osDirPath, glob_filename)
        filename=os.path.splitext(filepath)[0]
        fileext=os.path.splitext(filepath)[1]

        with open(filepath, 'r') as f: # open in readonly mode
            if fileext != ".mp4":
                print(" - ignoring: %s" % f)
            else:
                print(" - source video detected: %s" % f)
                mp3filepath="%s.mp3" % filepath

                cmd = "yes n | ffmpeg -i \"%s\" \"%s\"" % (filepath,mp3filepath)
                if __TESTMODE==False: subprocess.run(cmd,shell=True)
                else: print("(TEST) cmd = %s" % cmd)

                descriptorfilepath=os.path.join(osDirPath,"%s.txt" % filename)
                print(" - checking: %s" %(descriptorfilepath))

                if os.path.exists(descriptorfilepath):
                    ifx=0

                    for line in codecs.open(descriptorfilepath,encoding="utf-8"):
                        ifx=ifx+1
                        rec=line.strip().split("__")
                        print(">>>>>>> PARSING: %s"%rec)

                        FMT = '%H:%M:%S'
                        tdelta = datetime.strptime(rec[1], FMT) - datetime.strptime(rec[0], FMT)
                        rec_artist=rec[2]
                        rec_album=rec[3]
                        rec_title=rec[4]

                        cmd = "yes n | ffmpeg -i \"%s\" -ss %s -t %s \"%s__%s__%s__%s.mp3\" "% (
                                    mp3filepath,rec[0],tdelta,rec_artist,rec_album,ifx,rec_title
                                )
                        if __TESTMODE == False: subprocess.run(cmd,shell=True)
                        else: print("(TEST) cmd = %s" % cmd)

            if __TESTMODE == False:
                print("removing: %s" % mp3filepath)
                os.remove(mp3filepath)
            else:
                print("(TEST) removing: %s" % mp3filepath)

def main():

    args = parser.parse_args()
    print("### PARAM ###"                                 )
    print("filter    = %s" % args.filter                  )
    print("dir       = %s" % args.dir                     )

    if args.testMode:
        print("************ TEST MODE ****************")
        __TESTMODE=True

    ytdl_ffmpeg(args.dir,args.filter)

if __name__ == "__main__": main()
