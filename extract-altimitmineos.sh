#!/bin/bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
iso="$CURRENT_DIR/altimitmineos.iso"
temp="$CURRENT_DIR/contents/"

# shellcheck source=./script-dialog.sh
pushd "$CURRENT_DIR" || exit
source "./script-dialog/script-dialog.sh" #folder local version

relaunch-if-not-visible

# shellcheck disable=SC2034  # APP_NAME is used by script-dialog.sh functions
APP_NAME=".hack ALTIMIT OS Extractor"

if [ ! -f "$CURRENT_DIR"/altimitmineos.iso ] ; then
  ACTIVITY="Disc Not Found"
  message-error "please download the ALTIMITOS disc from Archive.org"
  exit 1
fi

# shellcheck disable=SC2034  # APP_NAME is used by script-dialog.sh functions
ACTIVITY="Extracting..."
{
  progressbar_update 1

  if [ -e "$temp" ]; then
    rm -r "$temp"
  fi

  progressbar_update 10

  mkdir "$temp"

  progressbar_update 20

  out="$(udisksctl loop-setup --file "$iso")"
  loopdev="$(awk '/Mapped file/ {print $NF}' <<<"$out")"
  loopdev="${loopdev%.}"   # remove a trailing "."

  progressbar_update 30

  mountpoint="$(findmnt -n -o TARGET "$loopdev")"

  progressbar_update 40

  7z x "$mountpoint"/accesory.exe -o"$temp" -y -bb0 > /dev/null 2>&1

  progressbar_update 50

  shopt -s nullglob
  for f in "$temp"/icon/*.ico; do
    base="$(basename "${f%.ico}")"
    convert "$f" "$temp/icon/${base}.png" > /dev/null 2>&1
    rm "$f" > /dev/null 2>&1
  done

  progressbar_update 60

  # move the wallpaper out of the icons folder
  mv "$temp"/icon/wall.jpg "$temp"/wallpaper_original.jpg > /dev/null 2>&1

  progressbar_update 65

  # Make an upscaled 16x9 version using a blur version as pill-box fill
  # blur
  magick "$temp"/wallpaper_original.jpg -filter Lanczos -resize 1920x1080^ -gravity center -extent 1920x1080 -gravity center -set option:distort:viewport 1920x1080 -distort SRT 0,-240,0 -blur 0x25 "$temp"/bg.png > /dev/null 2>&1
  # sharp
  magick "$temp"/wallpaper_original.jpg -filter Lanczos -resize 1920x1080 -gravity center -background none -extent 1920x1080 "$temp"/sharp.png  > /dev/null 2>&1
  # final image
  magick "$temp"/bg.png "$temp"/sharp.png -gravity center -compose over -composite \
  -unsharp 0x0.8+0.8+0 -colorspace sRGB "$temp"/wallpaper.jpg > /dev/null 2>&1
  # cleanup
  rm "$temp"/bg.png "$temp"/sharp.png > /dev/null 2>&1

  progressbar_update 70

  for f in "$temp"/Se/*.wav; do
    ffmpeg -y -i "$f" "${f%.wav}.ogg" -loglevel quiet
    rm "$f" > /dev/null 2>&1
  done

  # remove the spreadsheet
  rm "$temp"/Se/*.xls > /dev/null 2>&1

  progressbar_update 80

  # Un-Mount disc
  udisksctl unmount -b "$loopdev"  >/dev/null 2>&1

  progressbar_update 90

  # Remove the loopback device
  udisksctl loop-delete -b "$loopdev"  >/dev/null 2>&1

  progressbar_update 100
  sleep 0.2
  progressbar_finish
} | progressbar

message-info "Finished building."
