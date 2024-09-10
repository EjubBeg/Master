#!/bin/bash

FILES_TO_MONITOR=(
    "/etc/crontab"
    "/etc/cron.d/"
)

for FILE in "${FILES_TO_MONITOR[@]}"; do
    CURRENT_STATE=$(sudo ls -lR "$FILE" | md5sum)
    FILE_SIZE=$(sudo du -sh "$FILE" | awk '{print $1}')
    LAST_MODIFIED=$(sudo stat -c %y "$FILE")
    USER=$(stat -c %U "$FILE")

    PREVIOUS_STATE_FILE="/var/log/$(basename "$FILE").md5"

    if [ -f "$PREVIOUS_STATE_FILE" ]; then
        PREVIOUS_STATE=$(cat "$PREVIOUS_STATE_FILE")
        if [ "$CURRENT_STATE" != "$PREVIOUS_STATE" ]; then

            if [ ! -f "$FILE" ]; then
                ACTION="deleted"
            elif [ -f "$PREVIOUS_STATE_FILE" ] && [ "$CURRENT_STATE" != "$PREVIOUS_STATE" ]; then
                ACTION="modified"
            else
                ACTION="created"
            fi

            DATE=$(date '+%Y-%m-%d %H:%M:%S')
            logger -p local1.notice "[$DATE] $ACTION detected in $FILE by user $USER. File size: $FILE_SIZE. Last modified: $LAST_MODIFIED."
        fi
    fi

    echo "$CURRENT_STATE" > "$PREVIOUS_STATE_FILE"
done

