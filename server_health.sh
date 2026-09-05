#!/bin/bash

# ============================================================
# Linux Server Health Check
# Version: 2.0
# Purpose: Monitor system, resources, services, network,
#          processes, security and generate health logs.
# ============================================================

# -----------------------------
# Configuration
# -----------------------------

LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/health_check.log"

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOAD_THRESHOLD=80

# Services to monitor
SERVICES=("ssh" "sshd" "docker" "nginx")

# Create log directory
mkdir -p "$LOG_DIR"

# Timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')


# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'


# ============================================================
# Helper Functions
# ============================================================

print_header() {
    echo
    echo "============================================================"
    echo -e "${CYAN}$1${NC}"
    echo "============================================================"
}

log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

check_status() {
    if [ "$1" = "0" ]; then
        echo -e "${GREEN}[OK]${NC} $2"
        log "[OK] $2"
    else
        echo -e "${RED}[CRITICAL]${NC} $2"
        log "[CRITICAL] $2"
    fi
}


# ============================================================
# SYSTEM INFORMATION
# ============================================================

print_header "SYSTEM INFORMATION"

HOSTNAME=$(hostname)

echo "Hostname       : $HOSTNAME"
log "Hostname: $HOSTNAME"


# OS
if [ -f /etc/os-release ]; then
    OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
else
    OS="Unknown"
fi

echo "Operating System: $OS"
log "Operating System: $OS"


# Kernel
KERNEL=$(uname -r)

echo "Kernel Version  : $KERNEL"
log "Kernel: $KERNEL"


# IP Address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "IP Address      : $IP_ADDRESS"
log "IP Address: $IP_ADDRESS"


# Uptime
UPTIME=$(uptime -p)

echo "Uptime          : $UPTIME"
log "Uptime: $UPTIME"


# ============================================================
# RESOURCE MONITORING
# ============================================================

print_header "RESOURCE MONITORING"


# -----------------------------
# CPU
# -----------------------------

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
    awk '{print 100 - $1}')

CPU_USAGE_INT=${CPU_USAGE%.*}

echo "CPU Usage       : ${CPU_USAGE}%"

if [ "$CPU_USAGE_INT" -ge "$CPU_THRESHOLD" ]; then
    echo -e "${RED}[WARNING]${NC} CPU usage is high!"
    log "[WARNING] CPU usage: ${CPU_USAGE}%"
else
    echo -e "${GREEN}[OK]${NC} CPU usage is normal"
    log "[OK] CPU usage: ${CPU_USAGE}%"
fi


# -----------------------------
# Memory
# -----------------------------

MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

echo "Memory Usage    : ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
    echo -e "${RED}[WARNING]${NC} Memory usage is high!"
    log "[WARNING] Memory usage: ${MEMORY_USAGE}%"
else
    echo -e "${GREEN}[OK]${NC} Memory usage is normal"
    log "[OK] Memory usage: ${MEMORY_USAGE}%"
fi


# -----------------------------
# Disk
# -----------------------------

DISK_USAGE=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')

echo "Disk Usage      : ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    echo -e "${RED}[WARNING]${NC} Disk usage is high!"
    log "[WARNING] Disk usage: ${DISK_USAGE}%"
else
    echo -e "${GREEN}[OK]${NC} Disk usage is normal"
    log "[OK] Disk usage: ${DISK_USAGE}%"
fi


# -----------------------------
# Load Average
# -----------------------------

LOAD=$(awk '{print $1}' /proc/loadavg)

echo "Load Average    : $LOAD"

log "Load Average: $LOAD"


# -----------------------------
# Swap
# -----------------------------

SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

if [ "$SWAP_TOTAL" -eq 0 ]; then
    echo "Swap            : Not configured"
    log "Swap: Not configured"
else
    SWAP_PERCENT=$((SWAP_USED * 100 / SWAP_TOTAL))

    echo "Swap Usage      : ${SWAP_PERCENT}%"

    log "Swap Usage: ${SWAP_PERCENT}%"
fi


# ============================================================
# SERVICE MONITORING
# ============================================================

print_header "SERVICE MONITORING"

for SERVICE in "${SERVICES[@]}"
do

    # Check whether service exists
    if systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE}.service"; then

        if systemctl is-active --quiet "$SERVICE"; then
            echo -e "${GREEN}[RUNNING]${NC} $SERVICE"
            log "[RUNNING] Service: $SERVICE"
        else
            echo -e "${RED}[STOPPED]${NC} $SERVICE"
            log "[STOPPED] Service: $SERVICE"
        fi

    fi

done


# ============================================================
# CUSTOM SERVICE CHECK
# ============================================================

print_header "CUSTOM SERVICE CHECK"

echo "You can add your own services to the SERVICES array."
echo "Example:"
echo 'SERVICES=("ssh" "docker" "nginx" "myapp")'

log "Custom service monitoring completed"


# ============================================================
# NETWORK MONITORING
# ============================================================

print_header "NETWORK MONITORING"


# -----------------------------
# Internet Connectivity
# -----------------------------

if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Internet connectivity"
    log "[OK] Internet connectivity"
else
    echo -e "${RED}[CRITICAL]${NC} Internet connectivity failed"
    log "[CRITICAL] Internet connectivity failed"
fi


# -----------------------------
# Network Interfaces
# -----------------------------

echo
echo "Network Interfaces:"

ip -br addr 2>/dev/null

log "Network interfaces checked"


# -----------------------------
# Open Ports
# -----------------------------

echo
echo "Listening Ports:"

if command -v ss >/dev/null 2>&1; then
    ss -tuln
    log "Listening ports checked using ss"
else
    echo "ss command not available"
    log "ss command not available"
fi


# ============================================================
# PROCESS MONITORING
# ============================================================

print_header "PROCESS MONITORING"


# -----------------------------
# Top CPU Processes
# -----------------------------

echo "Top 5 CPU-consuming processes:"
echo

ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 6

log "Top CPU processes checked"


# -----------------------------
# Top Memory Processes
# -----------------------------

echo
echo "Top 5 Memory-consuming processes:"
echo

ps -eo pid,ppid,comm,%cpu,%mem --sort=-%mem | head -n 6

log "Top memory processes checked"


# ============================================================
# SECURITY CHECKS
# ============================================================

print_header "SECURITY CHECKS"


# -----------------------------
# Failed SSH Logins
# -----------------------------

echo "Failed SSH Login Attempts:"

if command -v journalctl >/dev/null 2>&1; then

    FAILED_SSH=$(journalctl --no-pager 2>/dev/null | \
        grep -Ei "Failed password|authentication failure" | wc -l)

    echo "$FAILED_SSH failed login attempts"

    log "Failed SSH login attempts: $FAILED_SSH"

else

    echo "journalctl not available"

fi


# -----------------------------
# Root Login
# -----------------------------

echo
echo "Root Login Configuration:"

if [ -f /etc/ssh/sshd_config ]; then

    ROOT_LOGIN=$(grep -Ei "^[[:space:]]*PermitRootLogin" \
        /etc/ssh/sshd_config | tail -n 1)

    if [ -z "$ROOT_LOGIN" ]; then
        echo "PermitRootLogin: default configuration"
        log "Root login: default configuration"
    else
        echo "$ROOT_LOGIN"
        log "Root login configuration: $ROOT_LOGIN"
    fi

else

    echo "SSH configuration file not found"

fi


# -----------------------------
# Firewall
# -----------------------------

echo
echo "Firewall Status:"

if command -v ufw >/dev/null 2>&1; then

    ufw status

elif command -v firewall-cmd >/dev/null 2>&1; then

    firewall-cmd --state

elif command -v iptables >/dev/null 2>&1; then

    echo "iptables is installed"
    iptables -L -n | head -n 10

else

    echo "No supported firewall tool detected"

fi


# ============================================================
# SYSTEM HEALTH SUMMARY
# ============================================================

print_header "SYSTEM HEALTH SUMMARY"

HEALTH_STATUS=0


# CPU
if [ "$CPU_USAGE_INT" -ge "$CPU_THRESHOLD" ]; then
    HEALTH_STATUS=1
fi


# Memory
if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
    HEALTH_STATUS=1
fi


# Disk
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    HEALTH_STATUS=1
fi


# Final status
if [ "$HEALTH_STATUS" -eq 0 ]; then

    echo -e "${GREEN}"
    echo "             SERVER HEALTH: HEALTHY"
    echo -e "${NC}"

    log "OVERALL STATUS: HEALTHY"

else

    echo -e "${RED}"
    echo "             SERVER HEALTH: WARNING"
    echo -e "${NC}"

    log "OVERALL STATUS: WARNING"

fi


# ============================================================
# LOG INFORMATION
# ============================================================

echo
echo "Health check completed."
echo "Log file: $LOG_FILE"
echo "Timestamp: $TIMESTAMP"

log "Health check completed"
log "------------------------------------------------------------"


# ============================================================
# EXIT CODE
# ============================================================

exit "$HEALTH_STATUS"
