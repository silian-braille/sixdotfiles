#!/bin/bash
#Bash script to run lemonbar

#Configurable Variables:
FOREGROUND="#0abdc6"
BACKGROUND="#000b1e"
UNDERLINE="#711c91"
UNDERLINE_SELECTED="#d300c4"

MAIN_FONT="-misc-tamsyn-medium-r-normal--20-145-100-100-c-100-iso8859-1"
BACKUP_FONT="Fira Mono"
ICON_FONT="FontAwesome"

#Module functions
battery(){
	batC="$(cat /sys/class/power_supply/BAT0/capacity)"
	batS="$(cat /sys/class/power_supply/BAT0/status)"

	if [ $batC -ge 80 ]; then
		batSym=""
	elif [ $batC -ge 60 ]; then
		batSym=""
	elif [ $batC -ge 40 ]; then
		batSym=""
	elif [ $batC -ge 20 ]; then
		batSym=""
	elif [ $batC -ge 5]; then
		batSym=""
	fi

	test "$batS" = "Charging" && isCharging="+" || isCharging=""
	printf "battery%s\n" "$batSym $batC$isCharging"
}

brightness(){
	level=$(cat /sys/class/backlight/nvidia_0/actual_brightness)
	printf "%s\n" "brightness $level"
}

clock(){
	clocktime=$(date "+%m-%d-%Y %H:%M")
	printf "%s\n" "clock $clocktime"
}

media(){
	printf "%s\n" "media%{F$UNDERLINE_SELECTED}$(mpc current -f '[[%artist% - ]%title%] ([%album%])')%{F-}                    "
}

network(){
	curNet="$(iwconfig wlp2s0 | grep -o "ESSID:.*" | sed "s/ESSID:\"//" | sed "s/\"//")"
	printf "%s\n" "network $curNet"
}

pacheck(){
	yay -Syy
	packageCheck="$(yay -Qu | wc -l)"
	printf "%s\n" "pacheck $packageCheck"
}

power(){
	printf "%s\n" "power  "
}

volume(){
	curVol=$(amixer get Master | sed -n 's/^.*\[\([0-9]\+\)%.*$/\1/p'| uniq)
	printf "%s\n" "vol $curVol"
}

workspaces(){
	spaces=($(xprop -root _NET_DESKTOP_NAMES | awk '{$1=$2=""; print $0}' | sed -e 's/,//g' -e 's/\"//g' -e 's/^[[:space:]]*//'))
	current=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
	for ((i=0;i<${#spaces[*]};i++)) do
		if [ "$i" = "$current" ]; then
			spaces[$i]="%{+u}%{U$UNDERLINE_SELECTED}%{B$FOREGROUND}%{F$BACKGROUND} ${spaces[$i]} %{B-}%{F-}%{U-}%{-u}"
		else
			spaces[$i]="%{+u}%{U$UNDERLINE} ${spaces[$i]} %{U-}%{-u}"
		fi
	done

	monitors=$(sed -e 's/\(}\).?\(%\)/\1\2/' <<< "${spaces[*]}")

	#Substitute monitor names with FontAwesome icons
	monitors=$(sed -e 's/Term//g' \
			-e 's/Firefox//g'\
			-e 's/Dev//g'\
			-e 's/Games//g'\
			-e 's/Music//g'\
			-e 's/Free//g' <<< "$monitors")

	printf "%s\n" "workspaces${monitors}"
}

#Quick check for manual updates
if [ "$1" = "b" ]; then
	echo "$(brightness)" > "/tmp/panel_fifo" &
	exit 0
elif [ "$1" = "v" ]; then
	echo "$(volume)" > "/tmp/panel_fifo" &
	exit 0
elif [ "$1" = "w" ]; then
	echo "$(workspaces)" > "/tmp/panel_fifo" &
	exit 0
fi

#Checks to see if lemonbar is already running
if [ $(pgrep -cx lemonbar) -gt 0 ]; then
	exit 1
fi

#Creates the named pipe that will handle
#all the updates
fifo="/tmp/panel_fifo"
[ -e "$fifo" ] && rm "$fifo"
mkfifo "$fifo"
chmod a+w "$fifo"

#Run modules on intervals
while :; do clock; sleep 1m; done > "$fifo" &
while :; do battery; sleep 5m; done > "$fifo" &
while :; do network; sleep 10s; done > "$fifo" &
while :; do media; mpc idle player; done > "$fifo" &
while :; do pacheck; sleep 180m; done > "$fifo" &
#initialize manually updated/fixed modules
echo "$(workspaces)" > "$fifo" &
echo "$(brightness)" > "$fifo" &
echo "$(volume)" > "$fifo" &
echo "$(power)" > "$fifo" &
#Build the bar using fifo output
musicSpacing="                                             "
while read -r line ; do
	case $line in
		clock*)
			clock="  ${line:5}"
			;;
		brightness*)
			brightness="  ${line:10}"
			;;
		vol*)
			volume="  ${line:3}"
			;;
		battery*)
			battery="  ${line:7}"
			;;
		network*)
			network="  ${line:7}"
			;;
		workspaces*)
			workspaces="${line:10}"
			;;
		power*)
			power="  ${line:5} "
			;;
		pacheck*)
			pacheck="  ${line:7}"
			;;
		media*)
			media="${line:5}"
			;;
	esac
	printf "%s\n" "%{l}$workspaces%{c}$media$musicSpacing%{r}$volume$brightness$pacheck$network$battery$clock$power"
done < "$fifo" | lemonbar \
	-g "1920x40+0+0" \
	-f "$MAIN_FONT" \
	-f "$BACKUP_FONT" \
       	-f "$ICON_FONT" \
	-F "$FOREGROUND" \
	-B "$BACKGROUND" \
	-u 3 \
