#!/bin/bash

timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}')
cpu_idle=$(vmstat | tail -1 | awk '{print $15}')
cpu_kernel=$(vmstat | tail -1 | awk '{print $14}')
disk_io=$(vmstat -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | tr -d 'M' | xargs)

echo "timestamp: $timestamp"
echo "memory_free: $memory_free"
echo "cpu_idle: $cpu_idle"
echo "cpu_kernel: $cpu_kernel"
echo "disk_io: $disk_io"
echo "disk_available: $disk_available"