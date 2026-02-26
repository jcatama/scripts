#!/bin/bash

# Req: cwebp

TARGET_KB=30

mkdir -p compressed

for f in *.webp *.jpg *.jpeg; do

    [ -e "$f" ] || continue
    quality=90   
    step=5      

    base_name="$(basename "$f" | sed 's/\.[^.]*$//')"
    output="compressed/${base_name}.webp"

    while : ; do
        cwebp -q $quality "$f" -o "$output" >/dev/null 2>&1
        size_kb=$(du -k "$output" | cut -f1)

        if [ "$size_kb" -le "$TARGET_KB" ] || [ $quality -le 10 ]; then
            echo "$f compressed to $size_kb KB at quality $quality"
            break
        fi

        quality=$((quality - step))
    done
done
