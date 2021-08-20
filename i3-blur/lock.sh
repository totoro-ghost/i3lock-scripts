#!/bin/bash

# Set the paused status of dunst
dunstctl set-paused true

# set this to the location where the script is
CUR_DIR="$HOME/Scripts/i3lock/i3-blur"

# this script will run slow at first time because it is generating a blurred image
# after that it will run fast because it save the blurred image

# Image you want to set as a background
# If you are using the script for first time or are using new image
# pass -gen to script
# or delete the blurred image generated by the script
image1="$CUR_DIR/wallpaper.png"

if [ ! -f "$image1" ]; then
    echo "Image $image1 do not exists..."
    exit 1
fi

# This will be the image produced after processing the image1
# this image will be saved for faster startup time
# because if we run blurr command everyting it will delay the 
# startup time
image="$CUR_DIR/blurred.png"

# INITIAL OPTIONS
font="VictorMono Nerd Font"
hue=(-level "0%,100%,0.6")
effect=(-filter Gaussian -resize 20% -define "filter:sigma=1.5" -resize 500.5%)
bw="white"
resol="1920x1080"
icon="$CUR_DIR/icons/lock.png"
font_color="#000000"

# choose the lock color
value="60" #brightness value to compare to
# take some part of image and process it to check it's contrast so that we can use either
# black lock or white lock
color=$(convert "$image1" -gravity center -crop 100x100+0+0 +repage -colorspace hsb \
    -resize 1x1 txt:- | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}')
if [[ $color -gt $value ]]; then #white background image and black text
    bw="black"
    icon="$CUR_DIR/icons/lockdark.png"
    param=("--insidecolor=0000001c" "--ringcolor=0000003e"
        "--linecolor=00000000" "--keyhlcolor=ffffff80" "--ringvercolor=ffffff00"
        "--separatorcolor=22222260" "--insidevercolor=ffffff1c"
        "--ringwrongcolor=ffffff55" "--insidewrongcolor=ffffff1c"
        "--verifcolor=ffffff00" "--wrongcolor=ff000000" "--timecolor=ffffff00"
        "--datecolor=ffffff00" "--layoutcolor=ffffff00")
    font_color="#000000"
else #black background image and white text
    bw="white"
    icon="$CUR_DIR/icons/lock.png"
    param=("--insidecolor=ffffff1c" "--ringcolor=ffffff3e"
        "--linecolor=ffffff00" "--keyhlcolor=00000080" "--ringvercolor=00000000"
        "--separatorcolor=22222260" "--insidevercolor=0000001c"
        "--ringwrongcolor=00000055" "--insidewrongcolor=0000001c"
        "--verifcolor=00000000" "--wrongcolor=ff000000" "--timecolor=00000000"
        "--datecolor=00000000" "--layoutcolor=00000000")
    font_color="#ffffff"
fi

if [ ! -f "$image" ] || [[ "$1" == "-gen" ]]; then
    echo "Generating the blurred image..."
    convert "$image1" -resize "$resol" "${hue[@]}" "${effect[@]}" -pointsize 26 -fill "$bw" -gravity center \
        "$icon" -gravity center -composite "$image"
fi

i3lock -i "$image" "${param[@]}" --ignore-empty-password \
    --clock \
    --timecolor=$font_color \
    --timestr="Type password to unlock" \
    --time-font="$font" \
    --timesize=30 \
    --timepos="953:700" \
    --verif-font="$font" \
    --verifsize=30 \
    --veriftext="Verifying..." \
    --verifpos="953:700" \
    --verifcolor=$font_color \
    --wrong-font="$font" \
    --wrongsize=30 \
    --wrongtext="Invalid Password" \
    --wrongpos="953:700" \
    --wrongcolor=$font_color \
    --no-modkeytext

# Set the paused status of dunst
dunstctl set-paused false