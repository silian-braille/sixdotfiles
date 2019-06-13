#!/bin/bash

arg="$(echo -e "Lock\nLogout\nSleep\nReboot\nShutdown" | dmenu -h 40 -fn "monospace:14" -nb '#000b1e' -nf '#0abdc6' -sb '#711c91' -sf '#000b1e')"

if [ $arg = "Lock" ]; then
	i3lock
elif [ $arg = "Logout"]; then
	bspc quit
elif [ $arg = "Sleep" ]; then
	systemctl suspend
elif [ $arg = "Reboot" ]; then
	reboot
elif [ $arg = "Shutdown" ]; then
	shutdown now
fi
