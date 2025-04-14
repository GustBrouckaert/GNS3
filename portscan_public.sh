#!/bin/bash

TARGET="205.174.165.68"
INTERFACE="eth0"
PORTS="1-1000"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PCAP_FILE="pcap/nmap_all_scans_${TIMESTAMP}.pcap"

echo "[*] Starting full port scan sequence..."
echo "[*] Target: $TARGET"
echo "[*] Capturing all packets to: $PCAP_FILE"

sudo tcpdump -i "$INTERFACE" host "$TARGET" -w "$PCAP_FILE" &
TCPDUMP_PID=$!

nmap -sS -T3 -p "$PORTS" "$TARGET"
nmap -sT -T3 -p "$PORTS" "$TARGET"
nmap -sF -T3 -p "$PORTS" "$TARGET"
nmap -sX -T3 -p "$PORTS" "$TARGET"
nmap -sN -T3 -p "$PORTS" "$TARGET"
nmap -sn "$TARGET"
nmap -sV -T3 -p "$PORTS" "$TARGET"
sudo nmap -sU -T3 -p "$PORTS" "$TARGET"
sudo nmap -sO "$TARGET"
nmap -sA -T3 -p "$PORTS" "$TARGET"
nmap -sW -T3 -p "$PORTS" "$TARGET"
nmap -sR -T3 -p "$PORTS" "$TARGET"
nmap -sL -p "$PORTS" "$TARGET"

echo "[*] Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "[✅] All scans complete. PCAP saved to: $PCAP_FILE"
