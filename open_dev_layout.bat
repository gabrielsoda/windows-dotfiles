@echo off
wt new-tab -p "PowerShell" --title "Localhost" ; split-pane -V -s 0.5 -p "SSH Server" --title "gsoda@servidor-casa" ; move-focus left ; split-pane -H -s 0.5 -p "Ubuntu" --title "Ubuntu@WSL"
