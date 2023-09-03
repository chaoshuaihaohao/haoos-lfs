#!/bin/bash  
  
missing_files=0

while IFS=" " read -r url md5; do  
    file_name=$(basename "$url")  
  
    if [[ -f "$file_name" ]]; then  
        computed_md5=$(md5sum "$file_name" | awk '{print $1}')  
  
        if [[ "$computed_md5" == "$md5" ]]; then  
            #echo "File $file_name exists and MD5 check passed."
            continue  
        else  
            echo "MD5 check failed for file $file_name . computed: $computed_md5, expected: $md5"  
        fi  
    else  
        echo "File $file_name is missing. Please downloads it."  
	missing_files=1
	wget $url &
    fi  
done < urls.lst

if [ $missing_files -eq 0 ]; then
    echo "All packets have downloaded."
fi

