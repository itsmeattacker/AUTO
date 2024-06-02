#!/bin/bash

# Define color codes
LIGHT_GREEN='\033[1;32m'
NC='\033[0m' # No Color

# Print "AUTO" in light green color using figlet with "lean" font style
echo -e "${LIGHT_GREEN}"
figlet -f lean -c "AUTO"
echo -e "${NC}"

# Function to display usage
usage() {
    echo "Usage: $0 -d target_domain -o output_directory"
    exit 1
}

# Parse arguments
while getopts ":d:o:" opt; do
    case ${opt} in
        d )
            TARGET_DOMAIN=$OPTARG
            ;;
        o )
            OUTPUT_DIR=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

# Check if arguments are provided
if [ -z "$TARGET_DOMAIN" ] || [ -z "$OUTPUT_DIR" ]; then
    usage
fi

# Create output directory based on target domain name
OUTPUT_DIR="$OUTPUT_DIR/$TARGET_DOMAIN"
mkdir -p "$OUTPUT_DIR"

# Run subfinder to collect subdomains
echo "[*] Running subfinder to collect subdomains..."
subfinder -d $TARGET_DOMAIN -o "$OUTPUT_DIR/subfinder.txt"

# Run sublist3r to collect subdomains
echo "[*] Running sublist3r to collect subdomains..."
sublist3r -d $TARGET_DOMAIN -o "$OUTPUT_DIR/sublist3r.txt"

# Run crt.sh to collect subdomains
echo "[*] Running crt.sh to collect subdomains..."
curl -s "https://crt.sh/?q=%.$TARGET_DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > "$OUTPUT_DIR/crtsh.txt"

# Merge and sort subdomains, removing duplicates
echo "[*] Merging and sorting subdomains..."
cat "$OUTPUT_DIR/subfinder.txt" "$OUTPUT_DIR/sublist3r.txt" "$OUTPUT_DIR/crtsh.txt" | sort -u > "$OUTPUT_DIR/all_subdomains.txt"

# Run httpx to check live subdomains
echo "[*] Running httpx to check live subdomains..."
httpx -l "$OUTPUT_DIR/all_subdomains.txt" -silent -o "$OUTPUT_DIR/live_subdomains.txt"

# Run waybackurls to get URLs from live subdomains
echo "[*] Running waybackurls to extract URLs from live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | waybackurls > "$OUTPUT_DIR/waybackurls.txt"

# Run XXEInjector to check for XXE vulnerabilities
echo "[*] Running XXEInjector to check for XXE vulnerabilities..."
ruby /root/tools/XXEinjector/XXEinjector.rb -i "$OUTPUT_DIR/waybackurls.txt" -o "$OUTPUT_DIR/xxeinjector.txt"

# Run SSRFDetector to check for SSRF vulnerabilities
echo "[*] Running SSRFDetector to check for SSRF vulnerabilities..."
ssrfdetector -i "$OUTPUT_DIR/waybackurls.txt" -o "$OUTPUT_DIR/ssrfdetector.txt"

# Run CORStest to check for CORS misconfigurations
echo "[*] Running CORStest to check for CORS misconfigurations..."
python3 /root/tools/CORStest/corstest.py -i "$OUTPUT_DIR/live_subdomains.txt" -o "$OUTPUT_DIR/corstest.txt"

# Run parameth to find hidden parameters
echo "[*] Running parameth to find hidden parameters..."
python3 /root/tools/parameth/parameth.py -u "$OUTPUT_DIR/waybackurls.txt" -o "$OUTPUT_DIR/parameth.txt"

# Run GetJS to extract JavaScript files from live subdomains
echo "[*] Running GetJS to extract JavaScript files from live subdomains..."
getJS --input "$OUTPUT_DIR/live_subdomains.txt" --complete --output "$OUTPUT_DIR/getjs.txt"

# Run nmap to scan live subdomains
echo "[*] Running nmap to scan live subdomains..."
nmap -iL "$OUTPUT_DIR/live_subdomains.txt" -sV -oN "$OUTPUT_DIR/nmap_results.txt"

# Run EyeWitness to scan live subdomains
echo "[*] Running EyeWitness to scan live subdomains..."
eyewitness -f "$OUTPUT_DIR/live_subdomains.txt" -d "$OUTPUT_DIR/eyewitness"

echo "Recon process completed. Results are saved in $OUTPUT_DIR directory."
