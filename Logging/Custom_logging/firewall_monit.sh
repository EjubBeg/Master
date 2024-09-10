#!/bin/bash

CURRENT_FILE="/var/log/nftables_current.log"
PREVIOUS_FILE="/var/log/nftables_previous.log"

NFT_COMMAND="/usr/sbin/nft"

$NFT_COMMAND list ruleset > "$CURRENT_FILE"

if [ -f "$PREVIOUS_FILE" ]; then

    DIFF=$(diff "$PREVIOUS_FILE" "$CURRENT_FILE")

    if [ "$DIFF" ]; then

        FIREWALL_STATUS=$($NFT_COMMAND list ruleset | grep -q 'policy drop'; echo $?)

        if [ "$FIREWALL_STATUS" -eq 0 ]; then
            STATUS="ON"
        else
            STATUS="OFF"
        fi


        
        DATE=$(date '+%Y-%m-%d %H:%M:%S')


        logger -p local1.notice "[$DATE] Firewall settings have changed. Firewall status: $STATUS"
    fi
fi


cp "$CURRENT_FILE" "$PREVIOUS_FILE"

