set daemon  60              # check services at 1-minute intervals
set logfile syslog facility log_daemon

set httpd port 2812 and
    use address 127.0.0.1  # only allow localhost to connect to Monit
    allow 127.0.0.1        # allow localhost to connect

check directory path_plcnext with path /opt/plcnext/
    if changed timestamp then alert

check directory path_php with path /opt/plcnext/php_appl/
    if changed timestamp then alert

check process tcpdump with matching "tcpdump"
    mode passive

check file ssh_config with path /etc/ssh/sshd_config
    if changed checksum then alert
    if changed timestamp then alert

check file sudoers with path /etc/sudoers.d/axcf2152-sudoers
    if changed checksum then alert
    if failed permission 0440 then alert
    if changed timestamp then alert

# Monitor CPU usage for high spikes
check system localhost
    if loadavg (1min) > 4.7 then alert

check file gpio1985_direction with path /sys/class/gpio/gpio1985/direction
    if changed timestamp then alert

check file gpio1984_direction with path /sys/class/gpio/gpio1984/direction
    if changed timestamp then alert

check file gpio1980_direction with path /sys/class/gpio/gpio1980/direction
    if changed timestamp then alert

check file gpio1978_direction with path /sys/class/gpio/gpio1978/direction
    if changed timestamp then alert

check file gpio1977_direction with path /sys/class/gpio/gpio1977/direction
    if changed timestamp then alert

check file gpio1953_direction with path /sys/class/gpio/gpio1953/direction
    if changed timestamp then alert

check file gpio1952_direction with path /sys/class/gpio/gpio1952/direction
    if changed timestamp then alert

check file gpio1979_direction with path /sys/class/gpio/gpio1979/direction
    if changed timestamp then alert
