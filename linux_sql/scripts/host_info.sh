#!/bin/bash

hostname=$(hostname -f)
lscpu_out=$(lscpu)

# Extract each value
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{print $3,$4,$5,$6,$7}' | xargs)
cpu_mhz=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | xargs)
total_mem=$(cat /proc/meminfo | egrep "^MemTotal:" | awk '{print $2}' | xargs)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Print to verify
echo "hostname: $hostname"
echo "cpu_number: $cpu_number"
echo "cpu_architecture: $cpu_architecture"
echo "cpu_model: $cpu_model"
echo "cpu_mhz: $cpu_mhz"
echo "l2_cache: $l2_cache"
echo "total_mem: $total_mem"
echo "timestamp: $timestamp"
