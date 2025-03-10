#!/bin/bash

# Function to print usage and exit
print_usage_and_exit() {
    echo "Usage: $0 filename [column_number]"
    echo "  filename      - The CSV file to process"
    echo "  column_number - The column number where URLs are located (default: 2)"
    exit 1
}

# Check if filename is provided as an argument
if [ "$#" -lt 1 ]; then
    print_usage_and_exit
fi

# Check if file exists
if [ ! -f "$1" ]; then
    echo "File not found!"
    exit 1
fi

# Pass in RunType
run_type=$2
# Get the column number, default to 2 if not provided
column_number=${3:-2}

# Validate the column number is a positive integer
if ! [[ "$column_number" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid column number: $column_number"
    exit 1
fi

# Get the filename without the extension
filename=$(basename -- "$1")
extension="${filename##*.}"
filename="${filename%.*}"

# Create the output filename
output_filename="input/${filename}_cleanurls.csv"

# Check if $2 contains "wsj"
if [[ "$run_type" == *"sem"* ]]; then
    echo "Running SEM Rush version"
    # Extract the domain from each line of the CSV, exclude .edu and .gov domains, and write to output file
    # Split by column and fetches position this is only valid for semrush whereby the column is just domain name in column 2
    awk -F',' '{print $2}' "$1" | sed 's/^www\.//' | sort | uniq | \
    awk -F. '{n=split($0,a,"."); if (n>1 && a[n-1] !~ /^[0-9]+$/) print (n>2?a[n-2]".":"")a[n-1]"."a[n]}' | \
    grep -P '^[a-zA-Z0-9.-]+$' | grep -vP '\.edu$|\.gov.*$|\.ac.*$|\.mil.*$|\.jp$' | \
    awk -F '.' '{if ( NF == 3 || length($NF)!=2 ) print $N2}' | sort -u > "$output_filename"
else
    # Extract the domain from each line of the CSV, exclude .edu and .gov domains, and write to output file
    # Parses entire row and extract domain by splitting with '/'
    # usefull for full URL parsing
    echo "Running Generic version"
    awk -F'/' '{print $3}' "$1" | sed 's/^www\.//' | sort | uniq | \
    awk -F. '{n=split($0,a,"."); if (n>1 && a[n-1] !~ /^[0-9]+$/) print (n>2?a[n-2]".":"")a[n-1]"."a[n]}' | \
    grep -P '^[a-zA-Z0-9.-]+$' | grep -vP '\.edu$|\.gov.*$|\.ac.*$|\.mil.*$|\.jp$' | \
    awk -F '.' '{if ( NF == 3 || length($NF)!=2 ) print $N2}' | sort -u > "$output_filename"
fi

# For large Files - Remove Edu and Gov TLDs
# cat input/gov.uk_sem_cleanurls.csv | grep -vP ".org|.jp|.nhs|.edu|.mil" | awk -F '.' '{if (length($NF) <= 3) print $N}' | sort -u
# Further remove silly TLDS - cat gov.uk_sem_cleanest_available_domains\ -\ Copy\ \(2\).csv | awk -F '.' '{if ( NF == 3 || length($NF)!=2 ) print $N2}'

# Extract the domain from the specified column of the CSV, exclude .edu and .gov domains, and write to output file
# awk -F'' -v col="$column_number" \
# awk -F'/' '{print $3}' "$1" | sed 's/^www\.//' | sort | uniq | \
# #  '{print $col}' "$1" | sed 's/^www\.//' | sort | uniq | \
# awk -F. '{n=split($0,a,"."); if (n>1 && a[n-1] !~ /^[0-9]+$/) print (n>2?a[n-2]".":"")a[n-1]"."a[n]}' | \
# grep -P '^[a-zA-Z0-9.-]+$' | grep -vP '\.edu$|\.gov$' > "$output_filename"

echo "file written to $output_filename"
