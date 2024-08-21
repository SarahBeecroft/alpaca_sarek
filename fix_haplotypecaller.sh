#!/bin/bash

filename=${PWD}/subworkflows/local/bam_variant_calling_germline_all/main.nf

# Create a temporary file
temp_file=$(mktemp)

# Use sed to replace lines 133 and 134
sed '133,134c\
            dbsnp.map{ it -> [[:], []] },\
            dbsnp_tbi.map{ it -> [[:], []] },' "$filename" > "$temp_file"

# Replace the original file with the modified content
mv "$temp_file" "$filename"

echo "Lines 133 and 134 have been replaced in $filename."
