#!/usr/bin/env bash
# Any Video Convertor for macOS / Linux - same settings as compress-video.ps1 (x264 CRF 12 slow, AAC 320k, colour tags kept).
# Usage: bash compress-video.sh [file|folder]...   (no arguments = pick videos in a window)   bash compress-video.sh --self-test
set -u
VIDEO_EXT="mov mp4 mkv avi webm m4v"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

target_pix_fmt() {
  case "$1" in
    *444*) echo yuv444p10le ;;    # full colour detail (ProRes 4444 etc.)
    *p1[0-6]*) echo yuv420p10le ;; # keep 10/12-bit depth
    *) echo yuv420p ;;            # ordinary 8-bit video stays playable everywhere
  esac
}

if [ "${1:-}" = "--self-test" ]; then
  fail=0
  for pair in yuv444p12le:yuv444p10le yuva444p12le:yuv444p10le yuv420p10le:yuv420p10le yuv422p10le:yuv420p10le yuv420p:yuv420p yuvj420p:yuv420p; do
    got=$(target_pix_fmt "${pair%%:*}")
    [ "$got" = "${pair#*:}" ] || { echo "SelfTest failed: ${pair%%:*} -> $got, expected ${pair#*:}"; fail=1; }
  done
  [ $fail = 0 ] && echo "SelfTest passed"
  exit $fail
fi

# Finder-launched shells miss Homebrew's PATH; bin/ next to the script is the fully offline option.
PATH="$SCRIPT_DIR/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
have_ffmpeg() { command -v ffmpeg >/dev/null 2>&1 && command -v ffprobe >/dev/null 2>&1; }
if ! have_ffmpeg; then
  echo "ffmpeg is missing - installing it now (one time, needs internet)..."
  if [ "$(uname)" = Darwin ]; then
    if command -v brew >/dev/null 2>&1; then brew install ffmpeg
    else echo "Homebrew not found. Install it from https://brew.sh (one command), then run this again."; exit 1; fi
  elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y ffmpeg
  elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y ffmpeg
  elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm ffmpeg
  elif command -v zypper >/dev/null 2>&1; then sudo zypper install -y ffmpeg
  else echo "Install ffmpeg with your package manager, then run this again."; exit 1; fi
  have_ffmpeg || { echo "ffmpeg still not found after install."; exit 1; }
fi
ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libx264 || {
  echo "This ffmpeg has no H.264 encoder (libx264). On Fedora: enable RPM Fusion, then 'sudo dnf swap ffmpeg-free ffmpeg --allowerasing'."; exit 1; }

pick_files() {
  if [ "$(uname)" = Darwin ]; then
    osascript -e 'set f to choose file with prompt "Select videos to compress" with multiple selections allowed' \
      -e 'set out to ""' -e 'repeat with i in f' -e 'set out to out & POSIX path of i & linefeed' -e 'end repeat' -e 'return out' 2>/dev/null
  elif command -v zenity >/dev/null 2>&1; then zenity --file-selection --multiple --separator=$'\n' --title="Select videos to compress" 2>/dev/null
  elif command -v kdialog >/dev/null 2>&1; then kdialog --multiple --separate-output --title "Select videos to compress" --getopenfilename . 2>/dev/null
  else read -r -p "Video file or folder path: " p; echo "$p"
  fi
}

inputs=()
if [ $# -gt 0 ]; then inputs=("$@")
else
  while IFS= read -r line; do [ -n "$line" ] && inputs+=("$line"); done <<EOF
$(pick_files)
EOF
fi
[ ${#inputs[@]} -gt 0 ] || { echo "No video selected."; exit 0; }

is_video() { ext=$(echo "${1##*.}" | tr 'A-Z' 'a-z'); case " $VIDEO_EXT " in *" $ext "*) return 0 ;; esac; return 1; }
size_of() { wc -c < "$1" | tr -d ' '; }

failed=0
convert() {
  f=$1; base=$(basename "$f"); name=${base%.*}
  case "$name" in *_small) return ;; esac   # don't re-compress our own output when a folder is dropped
  out="$(dirname "$f")/${name}_small.mp4"
  [ -e "$out" ] && { echo "Skip (already exists): $out"; return; }

  pix=$(target_pix_fmt "$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$f")")
  in_size=$(size_of "$f")
  echo; echo "$base  ($((in_size / 1048576)) MB, $pix)"
  if ! ffmpeg -hide_banner -loglevel error -stats -n -i "$f" -map 0:v:0 -map '0:a?' -c:v libx264 -preset slow -crf 12 -pix_fmt "$pix" \
       -tune film -c:a aac -b:a 320k -movflags +faststart "$out" </dev/null; then
    echo "FAILED: $base"; rm -f "$out"; failed=$((failed + 1)); return
  fi
  new_size=$(size_of "$out")
  if [ "$new_size" -ge "$in_size" ]; then rm -f "$out"; echo "Source is already smaller than the result - kept the original only."; return; fi
  echo "Done: ${name}_small.mp4  $((in_size / 1048576)) MB -> $((new_size / 1048576)) MB ($(awk "BEGIN{printf \"%.1f\", $in_size/$new_size}")x smaller)"
}

for p in "${inputs[@]}"; do
  if [ -d "$p" ]; then for f in "$p"/*; do [ -f "$f" ] && is_video "$f" && convert "$f"; done
  elif [ -f "$p" ]; then convert "$p"
  else echo "Not found: $p"; fi
done
exit $failed
