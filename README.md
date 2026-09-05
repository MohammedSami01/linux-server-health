# Linux Server Health Check

A Bash-based Linux server health monitoring script that automates basic system health checks, resource monitoring, service monitoring, network checks, process monitoring, security checks, and health logging.

## Overview

The `server_health.sh` script provides a quick health assessment of a Linux system by collecting important system information and checking key server resources and services.

The script generates a readable terminal report and stores health-check information in a log file.

## Features

- System information
  - Hostname
  - Operating system
  - Kernel version
  - IP address
  - System uptime

- Resource monitoring
  - CPU usage
  - Memory usage
  - Disk usage
  - Load average
  - Swap usage

- Service monitoring
  - SSH
  - Docker
  - Nginx
  - Custom services

- Network monitoring
  - Internet connectivity
  - Network interfaces
  - Listening ports

- Process monitoring
  - Top CPU-consuming processes
  - Top memory-consuming processes

- Security checks
  - Failed SSH login attempts
  - SSH root-login configuration
  - Firewall availability

- Logging
  - Health-check results are written to `logs/health_check.log`

- Health status
  - Reports the overall server status as `HEALTHY` or `WARNING`

- Exit codes
  - `0` → Healthy
  - `1` → Warning

## Technologies

- Bash
- Linux
- systemd / systemctl
- proc filesystem
- `top`
- `free`
- `df`
- `ps`
- `ip`
- `ss`
- `ping`
- `journalctl`
- Git

## Project Structure

```text
linux-server-health/
├── server_health.sh
├── README.md
├── .gitignore
└── logs/
    └── health_check.log    # Generated log file, ignored by Git

Tested Environment
Ubuntu 24.04.1 LTS
WSL2

The script can also be used on other Linux distributions with the required utilities available.

Usage
1. Clone the Repository
git clone https://github.com/YOUR_USERNAME/linux-server-health.git
cd linux-server-health
2. Make the Script Executable
chmod +x server_health.sh
3. Run the Health Check
./server_health.sh

The script performs the configured checks and displays the health report
directly in the terminal.

Purpose

This project demonstrates practical Linux administration and Bash automation skills, including:

Linux system monitoring
Bash scripting
Resource monitoring
Service management
Network troubleshooting
Process monitoring
Basic security monitoring
Log management
Command-line automation
Exit-code based automation
