#!/bin/bash

# Define the cron jobs you want to add
CRON_JOBS=(
    "50 9 8 4 * /home/kali/GNS3/bruteforce_ftp.sh"
    "50 9 8 5 * /home/kali/GNS3/bruteforce_http.sh"
    "50 9 8 4 * /home/kali/GNS3/bruteforce_ssh.sh"
    "50 9 8 5 * /home/kali/GNS3/portscan_public.sh 205.174.165.68"
    "50 9 8 4 * /home/kali/GNS3/slowbody_attack.sh"
    "50 9 8 5 * /home/kali/GNS3/slowloris_attack.sh"
    "50 9 8 4 * /home/kali/GNS3/slowread_attack.sh"
    "50 9 8 4 * /home/kali/GNS3/Web_XSS.sh"
    "50 9 8 5 * /home/kali/GNS3/Web_SQL_injection.sh" 
)


#Minute: 50
#Hour: 9 (AM)
#Day: 8 (Of the month)
#Month: 4 
#* any day of the week

echo "[*] Adding the following cron jobs:"

# Read existing crontab into a temporary variable
CRONTAB_BACKUP=$(crontab -l 2>/dev/null)

# Loop through and add each job if it's not already present
for JOB in "${CRON_JOBS[@]}"; do
  if echo "$CRONTAB_BACKUP" | grep -Fxq "$JOB"; then
    echo "[!] Cron job already exists: $JOB"
  else
    echo "[+] Adding: $JOB"
    CRONTAB_BACKUP+=$'\n'"$JOB"
  fi
done

# Apply the updated crontab
echo "$CRONTAB_BACKUP" | crontab -

echo "[✅] Cron jobs updated."
