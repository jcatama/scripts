#!/bin/bash

echo "=== TWO-PHASE SAFE RENAMING PROCESS ==="

files=()
for file in *; do
    if [ -f "$file" ] && [ "$file" != "numeral.sh" ]; then
        files+=("$file")
    fi
done

IFS=$'\n' sorted_files=($(printf '%s\n' "${files[@]}" | sort -t. -k1,1n))
unset IFS

echo "Found ${#sorted_files[@]} files to process"

echo ""
echo "=== PHASE 1: Renaming to temporary names ==="
temp_files=()
counter=1

for file in "${sorted_files[@]}"; do
 
    if [ ! -f "$file" ]; then
        continue
    fi
    
    extension="${file##*.}"
    
    temp_name="temp_$(printf "%04d" $counter).${extension}"
    
    mv "$file" "$temp_name"
    temp_files+=("$temp_name")
    echo "Phase 1: $file -> $temp_name"
    
    ((counter++))
done

echo ""
echo "Phase 1 complete. All files renamed to temporary names."

echo ""
echo "=== PHASE 2: Renaming to sequential numbers ==="
count=1

for temp_file in "${temp_files[@]}"; do
    if [ ! -f "$temp_file" ]; then
        continue
    fi
    
    extension="${temp_file##*.}"
    
    new_name="$count.$extension"
    
    mv "$temp_file" "$new_name"
    echo "Phase 2: $temp_file -> $new_name"
    
    ((count++))
done

echo ""
echo "=== RENAMING COMPLETE ==="
echo "Total files processed: $((count-1))"
echo "Files are now numbered 1.$extension through $((count-1)).$extension"
