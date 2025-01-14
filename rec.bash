#!/usr/bin/env bash

record() {
  # create unique output dir
  file_name="$(date '+%Y_%m_%d_%H_%M')"
  output_dir="$HOME/Videos/$file_name"
  mkdir "$output_dir"

  # start video 
  nohup ffmpeg -s "$(xdpyinfo | awk '/dimensions/{print $2}')" -f x11grab -r 30 -i "$DISPLAY" -c:v h264 -qp 0 "$output_dir/video_$file_name.mkv" > /dev/null 2>&1 & 
  echo $! > /tmp/vidpid

  # start audio
  nohup ffmpeg -f alsa -i default -af "afftdn=nf=-75" "$output_dir/audio_$file_name.wav" > /dev/null 2>&1 &
  echo $! > /tmp/audpid

  # start camera video
  nohup ffmpeg -f v4l2 -input_format mjpeg -framerate 30 -i /dev/video0 -c:v h264 -qp 0 "$output_dir/camera_$file_name.mkv" > /dev/null 2>&1 &
  echo $! > /tmp/campid

  notify-send -t 500 "Recording in progress"
}

# end recording
end() {
  # kill all pids
  kill "$(cat /tmp/vidpid)" "$(cat /tmp/audpid)" "$(cat /tmp/campid)"

  wait "$(cat /tmp/vidpid)"
  video_exit_status=$?
  wait "$(cat /tmp/audpid)"
  audio_exit_status=$?
  wait "$(cat /tmp/campid)"
  camera_exit_status=$?

  rm -f /tmp/vidpid /tmp/audpid /tmp/campid

  notify-send -t 10000 "Recording ended"
}
