#!/bin/bash

# Define the cron jobs you want to add
CRON_JOBS=(
    "11 21 8 5 * /home/kali/GNS3/slowloris_attack.sh"
    "58 0 9 5 * /home/kali/GNS3/bruteforce_ftp.sh"
    "23 5 9 5 * /home/kali/GNS3/slowloris_attack.sh"
    "44 8 9 5 * /home/kali/GNS3/bruteforce_http.sh"
    "35 15 9 5 * /home/kali/GNS3/slowbody_attack.sh"
    "3 20 9 5 * /home/kali/GNS3/bruteforce_ssh.sh"
    "11 2 30 5 * /home/kali/GNS3/bruteforce_ftp.sh"
    "22 23 9 5 * /home/kali/GNS3/bruteforce_ftp.sh"
    "46 2 10 5 * /home/kali/GNS3/slowread_attack.sh"
    "33 7 10 5 * /home/kali/GNS3/Web_SQL_injection.sh"
    "47 9 10 5 * /home/kali/GNS3/Web_XSS.sh"
    "5 15 10 5 * /home/kali/GNS3/slowread_attack.sh"
    "33 19 10 5 * /home/kali/GNS3/slowloris_attack.sh"
    "57 20 10 5 * /home/kali/GNS3/Web_XSS.sh"
    "23 22 10 5 * /home/kali/GNS3/bruteforce_ssh.sh"
    "1 0 11 5 * /home/kali/GNS3/Web_SQL_injection.sh"
    "22 2 11 5 * /home/kali/GNS3/bruteforce_http.sh"
    "17 5 11 5 * /home/kali/GNS3/Web_XSS.sh"
    "35 9 11 5 * /home/kali/GNS3/Web_SQL_injection.sh"
    "22 11 11 5 * /home/kali/GNS3/slowbody_attack.sh"
    "57 12 11 5 * /home/kali/GNS3/Web_SQL_injection.sh"
    "43 14 11 5 * /home/kali/GNS3/Web_XSS.sh"
    "53 15 11 5 * /home/kali/GNS3/bruteforce_ssh.sh"
    "40 16 11 5 * /home/kali/GNS3/Web_SQL_injection.sh"   
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