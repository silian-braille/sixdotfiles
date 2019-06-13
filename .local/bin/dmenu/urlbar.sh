#!/bin/bash

url="$(echo "" | dmenu -t -h 40 -fn "monospace:14" -nb '#000b1e' -nf '#0abdc6' -sb '#000b1e' -sf '#000b1e')"

surf -F $url
