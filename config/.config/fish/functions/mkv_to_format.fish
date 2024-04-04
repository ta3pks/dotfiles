function mkv_to_format
set -l name (echo $argv[1] |  sed 's/.mkv//' | xargs -I{} echo -n {}.$argv[2])
ffmpeg -i $argv[1] -c:v h264_videotoolbox  $name
end
