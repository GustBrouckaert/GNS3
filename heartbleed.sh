#!/bin/bash

TARGET="205.174.165.68"
INTERFACE="eth0"
PCAP_FILE="heartbleed_$(date +%Y%m%d_%H%M%S).pcap"

echo "[*] Capturing Heartbleed scan..."
tcpdump -i "$INTERFACE" host "$TARGET" and port 443 -w "$PCAP_FILE" &
PID=$!

nmap -p 443 --script ssl-heartbleed "$TARGET"

kill "$PID"
echo "[✅] Heartbleed simulation complete: $PCAP_FILE"
