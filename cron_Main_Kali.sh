#!/bin/bash

# Define the cron jobs you want to add
CRON_JOBS=(
    "43 7 21 4 * /home/kali/GNS3/bruteforce_http.sh"
    "20 13 21 4 * /home/kali/GNS3/slowloris_attack.sh"
    "32 12 21 4 * /home/kali/GNS3/portscan_public.sh 205.174.165.68"
    "20 18 21 4 * /home/kali/GNS3/bruteforce_ftp.sh"
    "56 8 22 4 * /home/kali/GNS3/bruteforce_ssh.sh"
    "8 12 22 4 * /home/kali/GNS3/slowbody_attack.sh"
    "11 2 23 4 * /home/kali/GNS3/bruteforce_ftp.sh"
    "32 10 23 4 * /home/kali/GNS3/slowread_attack.sh"
    "53 13 23 4 * /home/kali/GNS3/Web_SQL_injection.sh"
    "43 17 23 4 * /home/kali/GNS3/Web_XSS.sh"
    "32 5 24 4 * /home/kali/GNS3/Web_XSS.sh"
    "1 7 24 4 * /home/kali/GNS3/slowloris_attack.sh"
    "21 11 24 4 * /home/kali/GNS3/bruteforce_http.sh"
    "43 13 24 4 * /home/kali/GNS3/bruteforce_ssh.sh"
    "32 16 24 4 * /home/kali/GNS3/Web_SQL_injection.sh" 
    "32 0 25 4 * /home/kali/GNS3/Web_XSS.sh"
    "47 3 25 4 * /home/kali/GNS3/slowread_attack.sh"
    "17 11 25 4 * /home/kali/GNS3/bruteforce_ssh.sh"
    "49 9 25 4 * /home/kali/GNS3/Web_SQL_injection.sh" 
    "3 14 24 4 * /home/kali/GNS3/slowbody_attack.sh"    
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
