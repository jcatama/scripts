#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") SOURCE_FILE COUNT [OUT_DIR]

Create COUNT duplicate files named 1..COUNT with the same extension as SOURCE_FILE
and place them into OUT_DIR (default: out/).

Examples:
  $(basename "$0") image.png 3333          # creates out/1.png ... out/3333.png
  $(basename "$0") ./photo.jpg 10 duped/   # creates duped/1.jpg ... duped/10.jpg
EOF
  exit 1
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage
fi

src="$1"
count="$2"
out_dir="${3:-out}"

if [ ! -f "$src" ]; then
  echo "Error: source file not found: $src" >&2
  exit 2
fi

if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -le 0 ]; then
  echo "Error: COUNT must be a positive integer" >&2
  exit 3
fi

mkdir -p "$out_dir"

base_name=$(basename -- "$src")

if [[ "$base_name" == *.* ]]; then
  ext="${base_name##*.}"
  dot="."
else
  ext=""
  dot=""
fi

for ((i=1; i<=count; i++)); do
  out_file="$out_dir/${i}${dot}${ext}"
  cp -- "$src" "$out_file" 2>/dev/null || cp "$src" "$out_file"
done

echo "Created $count files in '$out_dir' (named 1${dot}${ext} .. ${count}${dot}${ext})"
