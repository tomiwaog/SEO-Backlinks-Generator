#!/bin/bash

split_string() {
    IFS='.' read -ra string_array <<< "$1"
    
    if [[ ${#string_array[@]} -lt 3 ]] || [[ ${#string_array[1]} -le 3 ]]; then
        echo "$1"
    else
        echo "${string_array[1]}.${string_array[2]}"
    fi
}

check_domain_availability() {
    local domain="$1"
    local filename="$2"

    domain=$(split_string "$domain")
    echo "processing $domain"
    # Use whois and grep to check if the domain is available
    if whois -nobanner "$domain" | grep -Eq 'Name Server|Name Servers:|Registrar|Expiry Date|connection attempt failed'; then
        echo "$domain" >> "unavailable/${filename}_unavailable_domains.csv"
    else
        # Use nslookup to check if the domain is available
        if nslookup "$domain" | grep -Eq 'Addresses:|Name:'; then
            echo "$domain" >> "unavailable/${filename}_unavailable_domains.csv"
        else
            echo "$domain is available for Registration"
        echo "$domain" >> "available/${filename}_available_domains.csv"
        fi
    fi
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 filename [suffix]"
    exit 1
fi

# Get the filename without the extension
filename=$(basename "$1" .csv)
found=0
search_word="${2:-}"
# Read the file line by line
while read -r domain; do
    if [[ $found -eq 1 ]]; then
        check_domain_availability "$domain" "$filename"
    elif [[ $domain == *"$search_word"* ]]; then
        found=1
        check_domain_availability "$domain" "$filename"
    fi
done < "$1"

echo "Files written to ${filename}_available_domains.csv and ${filename}_unavailable_domains.csv"
