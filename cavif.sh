#!/bin/bash

# Req: cavif

INPUT_DIR="./input"
OUTPUT_DIR="./output"
TARGET_SIZE=45000
MIN_QUALITY=10

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.png; do
  filename=$(basename "$file" .png)
  quality=80
  output_file="$OUTPUT_DIR/$filename.avif"

  while true; do
    cavif -Q $quality "$file" -o "$output_file" --overwrite
    
    if [ ! -f "$output_file" ]; then
      echo "Error: Failed to create $output_file"
      break
    fi
    
    actual_size=$(stat -f%z "$output_file")
    echo "Trying $filename: quality=$quality, size=$actual_size bytes"

    if [ $actual_size -le $TARGET_SIZE ] || [ $quality -le $MIN_QUALITY ]; then
      echo "Saved $filename.avif (size=$actual_size, quality=$quality)"
      break
    fi

    quality=$((quality - 5))
  done
done
