#!/bin/bash

# Define the cron jobs you want to add
CRON_JOBS=(
    "43 22 27 4 * /home/kali/GNS3/bruteforce_http.sh"
    "20 5 28 4 * /home/kali/GNS3/slowloris_attack.sh"
    "32 9 28 4 * /home/kali/GNS3/portscan_public.sh 205.174.165.68"
    "20 14 28 4 * /home/kali/GNS3/bruteforce_ftp.sh"
    "56 3 29 4 * /home/kali/GNS3/bruteforce_ssh.sh"
    "8 12 29 4 * /home/kali/GNS3/slowbody_attack.sh"
    "11 2 30 4 * /home/kali/GNS3/bruteforce_ftp.sh"
    "32 10 30 4 * /home/kali/GNS3/slowread_attack.sh"
    "53 13 30 4 * /home/kali/GNS3/Web_SQL_injection.sh"
    "43 15 30 4 * /home/kali/GNS3/Web_XSS.sh"
    "3 17 30 4 * /home/kali/GNS3/Web_XSS.sh"
    "1 5 1 5 * /home/kali/GNS3/slowloris_attack.sh"
    "21 9 1 5 * /home/kali/GNS3/bruteforce_http.sh"
    "43 11 1 5 * /home/kali/GNS3/bruteforce_ssh.sh"
    "3 12 1 5 * /home/kali/GNS3/slowbody_attack.sh"
    "32 14 1 5 * /home/kali/GNS3/Web_SQL_injection.sh" 
    "32 22 1 5 * /home/kali/GNS3/Web_XSS.sh"
    "47 1 1 5 * /home/kali/GNS3/slowread_attack.sh"
    "17 4 2 5 * /home/kali/GNS3/bruteforce_ssh.sh"
    "49 7 2 5 * /home/kali/GNS3/Web_SQL_injection.sh"    
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