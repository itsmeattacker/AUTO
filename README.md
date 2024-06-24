
## Overview

AUTO is an automated domain reconnaissance tool designed to streamline the process of gathering information about target domains. By integrating various tools, AUTO automates the collection of subdomains, checks for vulnerabilities, and gathers related information, storing results in a structured manner for further analysis.

## Features

- **Subdomain Enumeration**: Utilizes `subfinder`, `sublist3r`, and `crt.sh` to enumerate subdomains.
- **Live Subdomain Detection**: Uses `httpx` to identify live subdomains.
- **URL Extraction**: Uses `waybackurls` to extract URLs from live subdomains.
- **Vulnerability Assessment**:
  - Checks for XXE vulnerabilities with `XXEinjector`.
  - Identifies SSRF vulnerabilities with `ssrfdetector`.
  - Detects CORS misconfigurations with `CORStest`.
- **Parameter Analysis**: Uses `parameth` to discover hidden parameters.
- **JavaScript File Extraction**: Extracts JavaScript files from live subdomains using `GetJS`.
- **Port Scanning**: Conducts port scanning on live subdomains with `naabu`.
- **Screenshot Capture**: Captures screenshots of live subdomains using `EyeWitness`.

## Requirements

Ensure the following tools are installed and available in your system PATH:

- `figlet`
- `subfinder`
- `sublist3r`
- `jq`
- `curl`
- `httpx`
- `waybackurls`
- `ruby`
- `ssrfdetector`
- `python3`
- `getJS`
- `naabu`
- `eyewitness`

## Usage

### Command

```bash
./auto.sh -d target_domain -o output_directory

```
### Arguments
`-d target_domain:` The target domain for reconnaissance.
`-o output_directory:` The directory where results will be saved.

### Example

```bash
./auto.sh -d example.com -o /path/to/output

```
