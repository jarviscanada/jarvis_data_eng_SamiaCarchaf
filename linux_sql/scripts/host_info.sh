#!/bin/bash
# Setup and validate arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments
if [ $# -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Collect hardware Specs
hostname=$(hostname -f)
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{print $3,$4,$5,$6,$7}' | xargs)
cpu_mhz=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | xargs)
total_mem=$(cat /proc/meminfo | egrep "^MemTotal:" | awk '{print $2}' | xargs)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Construct INSERT statement
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) VALUES('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$total_mem', '$timestamp')"

# Set password and execute
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?