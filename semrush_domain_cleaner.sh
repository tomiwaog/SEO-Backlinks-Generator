#!/bin/bash

# Check if filename is provided
if [ -z "$1" ]
then
    echo "No filename provided. Usage: ./script.sh filename.csv"
    exit 1
fi

# Create output filename
output_filename="input/${1%.csv}_cleaned.csv"

# Extract the domain from each line of the CSV, exclude .edu and .gov domains, and write to output file
awk -F',' '{print $2}' "$1" | sed 's/^www\.//' | sort | uniq | \
awk -F. '{n=split($0,a,"."); if (n>1 && a[n-1] !~ /^[0-9]+$/) print (n>2?a[n-2]".":"")a[n-1]"."a[n]}' | \
grep -P '^[a-zA-Z0-9.-]+$' | grep -vP '\.edu$|\.gov$' > "$output_filename"

echo "file written to $output_filename"
