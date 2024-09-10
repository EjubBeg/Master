#!/bin/bash

log_file="/opt/plcnext/logs/system_logs.txt"

get_memory_stats() {
    mem_info=$(free -m)
    total_mem=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
    used_mem=$(echo "$mem_info" | awk '/Mem:/ {print $3}')
    free_mem=$(echo "$mem_info" | awk '/Mem:/ {print $4}')
    echo "Memory - Total: ${total_mem}MB, Used: ${used_mem}MB, Free: ${free_mem}MB"
}

get_cpu_usage() {
    load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "CPU Load - 1 min: $(echo $load_avg | awk '{print $1}'), 5 min: $(echo $load_avg | awk '{print $2}'), 15 min: $(echo $load_avg | awk '{print $3}')"
}

get_disk_usage() {
    disk_info=$(df -h /)
    total_disk=$(echo "$disk_info" | awk 'NR==2 {print $2}')
    used_disk=$(echo "$disk_info" | awk 'NR==2 {print $3}')
    available_disk=$(echo "$disk_info" | awk 'NR==2 {print $4}')
    percent_used=$(echo "$disk_info" | awk 'NR==2 {print $5}')
    echo "Disk Space - Total: $total_disk, Used: $used_disk, Available: $available_disk, Usage: $percent_used"
}

get_network_usage() {
    ip_address=$(ifconfig eth0 | awk '/inet / {print $2}')
    tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes)
    rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes)
    tx_mb=$((tx_bytes / 1024 / 1024))
    rx_mb=$((rx_bytes / 1024 / 1024))
    echo "Network - IP Address: $ip_address, TX: ${tx_mb}MB, RX: ${rx_mb}MB"
}

get_open_ports() {
    open_ports=$(netstat -tuln | awk '/LISTEN/ {print $4}' | awk -F ':' '{print $NF}' | paste -sd ", ")
    if [ -n "$open_ports" ]; then
        echo "Open Ports: $open_ports"
    else
        echo "No open ports"
    fi
}

check_all_connections() {
    netstat -tunp | grep -E 'ESTABLISHED|SYN_SENT'
}

log_system_status() {
    timestamp=$(date -u '+[UTC %Y-%m-%d %H:%M:%S]')
    user=$(whoami)
    hostname=$(hostname)

    memory_stats=$(get_memory_stats)
    cpu_usage=$(get_cpu_usage)
    disk_usage=$(get_disk_usage)
    network_usage=$(get_network_usage)
    open_ports=$(get_open_ports)

    echo "$timestamp $user@$hostname Memory Stats: $memory_stats" >> "$log_file"
    echo "$timestamp $user@$hostname CPU Usage: $cpu_usage" >> "$log_file"
    echo "$timestamp $user@$hostname Disk Usage: $disk_usage" >> "$log_file"
    echo "$timestamp $user@$hostname Network Usage: $network_usage" >> "$log_file"
    echo "$timestamp $user@$hostname $open_ports" >> "$log_file"

    active_connections=$(check_all_connections)
    if [ -n "$active_connections" ]; then
        echo "$active_connections" | while read -r conn; do
            echo "$timestamp $user@$hostname Active Connection: $conn" >> "$log_file"
        done
    fi
}

while true; do
    log_system_status
    sleep 10  # Logs every 10 seconds
done

