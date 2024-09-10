#!/bin/bash

SUSPICIOUS_PORTS="535 4444 8080 9001 5345 9001 22 443 2812 "

# Get the current date and time
DATE=$(date '+%Y-%m-%d %H:%M:%S')

netstat -antp | grep -E "($SUSPICIOUS_PORTS)" | while read -r line; do
    logger -p local1.notice "[$DATE] Suspicious network connection detected: $line"
done
