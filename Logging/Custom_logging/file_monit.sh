#!/bin/bash

FILES_TO_MONITOR=(
    "/opt/plcnext/master/.private_file.txt.swp" 
    "/opt/plcnext/projects/Default/System/Um/.Users.config.swp"
)

while true; do
    for FILE in "${FILES_TO_MONITOR[@]}"; do

        ACCESS_INFO=$(lsof "$FILE" 2>/dev/null)

        if [ ! -z "$ACCESS_INFO" ]; then

            while IFS= read -r line; do
                PID=$(echo "$line" | awk '{print $2}')
                USER=$(echo "$line" | awk '{print $3}')
                COMMAND=$(echo "$line" | awk '{print $1}')
                DATE=$(date '+%Y-%m-%d %H:%M:%S')


                logger -p local1.notice "[$DATE] File $FILE was accessed by user $USER (PID: $PID, Command: $COMMAND)"
            done <<< "$ACCESS_INFO"
        fi
    done

    sleep 60
done

