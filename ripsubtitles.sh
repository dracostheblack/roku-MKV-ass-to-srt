#!/bin/bash
# Extract subtitles from each MKV file in the given directory

# If no directory is given, work in local dir
if [ "$1" = "" ]; then
  DIR="."
else
  DIR="$1"
fi

# Get all the MKV files in this dir and its subdirs
find "$DIR" -type f -name '*.mkv' | while read filename
do
  # Find out which tracks contain the subtitles
  mkvmerge -i "$filename" | grep 'subtitles' | while read subline
  do
	echo $filename 
        # Grep the number of the subtitle track
	tracknumber=`echo $subline | egrep -o "[0-9]{1,2}" | head -1`

	# Get base name for subtitle
	subtitlename=${filename%.*}
	# Extract the track to a .tmp file
	`mkvextract tracks "$filename" $tracknumber:"$subtitlename.ass" > /dev/null 2>&1`
	`ffmpeg -i "$subtitlename.ass" "$subtitlename.srt"`
	`rm -rf "$subtitlename.ass"`
	`chmod g+rw "$subtitlename.srt"`
	`mkvmerge -o "merge/$filename" --default-track 0 --language 0:eng "$subtitlename.srt" "$filename"`	
  done
done
