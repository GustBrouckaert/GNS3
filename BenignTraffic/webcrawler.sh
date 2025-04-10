#!/bin/bash

agents=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  "Mozilla/5.0 (iPhone; CPU iPhone OS 15_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
  "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0"
)

start_url="http://205.174.165.3"
cache_folder="traffic_cache"
delay=300

cache_path="$(realpath "$cache_folder")"
cron_job="*/1 * * * * rm -rf \"$cache_path\"/*"

(crontab -l 2>/dev/null | grep -F "$cron_job") >/dev/null
if [ $? -ne 0 ]; then
  echo "[$(date)] Adding cron job to clean $cache_path every 5 minutes."
  (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
else
  echo "[$(date)] Cron job already exists. Skipping."
fi

while true; do
  rand_agent=${agents[$RANDOM % ${#agents[@]}]}
  echo "[$(date)] Starting crawl with User-Agent: $rand_agent"

  wget --recursive \
       --level=inf \
       --wait=2 \
       --random-wait \
       --adjust-extension \
       --page-requisites \
       --span-hosts \
       --user-agent="$rand_agent" \
       --directory-prefix="$cache_folder" \
       --no-verbose \
       "$start_url"

  echo "[$(date)] Crawl completed."
  echo "[$(date)] Cleaning up downloaded data..."

  rm -rf "$cache_folder"

  echo "[$(date)] Sleeping for $delay seconds..."
  sleep $delay
done
