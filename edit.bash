#!/usr/bin/env bash

# flip the video so you look more handsome
ffmpeg -i cam*.mkv -vf "hflip" -an cam.mkv

# add a boarder
ffmpeg -i vid*.mkv -vf "drawbox=x=2071-10:y=1074-10:w=484+10:h=361+10:color=black@1.0:t=fill" box.mkv

# concatinate all the videos
ffmpeg -i box.mkv -i cam.mkv -i audio*.wav -filter_complex "[0:v]format=yuv420p[bg];[1:v]format=yuv420p[fg];[fg]scale=484:361[ovrl];[bg][ovrl]overlay=W-w-10:H-h-10[final]" -map "[final]" -map 2:a -c:v libx264 -crf 23 -preset veryfast -shortest final.mkv

rm cam.mkv box.mkv

notify-send "Finished editing"
