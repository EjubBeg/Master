#!/bin/bash

# Crucial Directories to monitor
DIRECTORIES_TO_MONITOR=("/opt/etc" "/etc/plcnext" "/opt/plcnext/master/php_app" "/opt/plcnext/config/Services")

for DIRECTORY_TO_MONITOR in "${DIRECTORIES_TO_MONITOR[@]}"; do
    # Find Bash and Python files accessed or modified in the last minute
    find "$DIRECTORY_TO_MONITOR" -name '*.sh' -o -name '*.py' -amin -1 -o -mmin -1 | while read -r file; do
        DATE=$(date '+%Y-%m-%d %H:%M:%S')
        
        FILE_OWNER=$(stat -c '%U' "$file")
        FILE_GROUP=$(stat -c '%G' "$file")
        FILE_SIZE=$(stat -c '%s' "$file")
        LAST_MODIFIED=$(stat -c '%y' "$file")
        
        if [ "$(find "$file" -amin -1)" ]; then
            ACTION="Accessed"
        elif [ "$(find "$file" -mmin -1)" ]; then
            ACTION="Modified"
        fi
        
        logger -p local1.notice "[$DATE] Script $ACTION: $file | Owner: $FILE_OWNER | Group: $FILE_GROUP | Size: $FILE_SIZE bytes | Last Modified: $LAST_MODIFIED"
    done
done

