#!/bin/bash

# Check for running Bash and Python scripts
ps -eo pid,comm,args | grep -E '\.sh|\.py' | grep -v grep | while read -r pid comm args; do
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
    USER=$(ps -o user= -p $pid)
    logger -p local1.notice "[$DATE] Script executed: PID=$pid, Command=$comm, User=$USER, Args=$args"
done

