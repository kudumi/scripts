#!/bin/sh

IFS=$'\n'
folder=converted_videos
mkdir $1/$folder

for i in $(ls -1 $1 | grep -i *.mp4) ; do

  /Applications/Utilities/HandBrakeCLI -i $i -o $1/$folder/${i##/} -C 1 -e x264 -q 20.0 -a 1 -E faac -B 128 -6 dpl2 -R Auto -D 0.0 -f mp4 -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subme=6:8x8dct=0:trellis=0
  rm $i

done

for suffix in wmv mkv avi mov flv divx xvid mov ; do

  for i in $(ls -1 $1 | grep -i *.$suffix) ; do

    /Applications/Utilities/HandBrakeCLI -i $1/$i -o $1/$folder/${i%.$suffix}.mp4 -C 1 -e x264 -q 20.0 -a 1 -E faac -B 128 -6 dpl2 -R Auto -D 0.0 -f mp4 -X 480 -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subme=6:8x8dct=0:trellis=0
  rm $i

  done

done
