#! /bin/bash

DB_CONF="/onapp/interface/config/database.yml"
HOSTS_FILE="hosts"

DB=$(awk '/database:/ {print $2; exit}' $DB_CONF)
DB_PASSWORD=$(awk '/password:/ {print$2; exit}' $DB_CONF)
DB_HOST=$(awk '/host:/ {print $2; exit}' $DB_CONF)
DB_PORT=$(awk '/port:/ {print $2; exit}' $DB_CONF)
DB_USERNAME=$(awk '/username:/ {print $2; exit}' $DB_CONF)

MYSQL_CONNECTION="mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se"

hosts_generator ()
{
    local group_name=$1
    local resource_type=$2
    local condition=$3

    read -ra arr -d '' <<<$( ${MYSQL_CONNECTION} "SELECT ip_address FROM ${resource_type} WHERE ${condition}")

    echo "[$group_name]" >> $HOSTS_FILE
    for ip in "${arr[@]}"
      do
        echo $ip  >> $HOSTS_FILE
      done
}

####################################################
# Initialize hosts file
####################################################

echo "" > $HOSTS_FILE

####################################################
# Generate inventory of static KVM Hypervisors
####################################################

hosts_generator static_kvm hypervisors "hypervisor_type = 'kvm' AND enabled = 1 AND mac IS NULL"

####################################################
# Generate inventory of static XEN Hypervisors
####################################################

hosts_generator static_xen hypervisors "hypervisor_type = 'xen' AND enabled = 1 AND mac IS NULL"

####################################################
# Generate inventory of static Backup Servers
####################################################

hosts_generator static_bs backup_servers "enabled = 1 AND ip_address NOT IN (SELECT ip_address FROM hypervisors)"

####################################################
# Generate inventory of cloudboot KVM Hypervisors
####################################################

hosts_generator cb_kvm hypervisors "hypervisor_type = 'kvm' AND enabled = 1 AND mac IS NOT NULL AND backup = 0"

####################################################
# Generate inventory of cloudboot XEN Hypervisors
####################################################

hosts_generator cb_xen hypervisors "hypervisor_type = 'xen' AND enabled = 1 AND mac IS NOT NULL AND backup = 0"

####################################################
# Generate inventory of cloudboot Backup Servers
####################################################

hosts_generator cb_bs hypervisors "enabled = 1 AND mac IS NOT NULL AND backup = 1"

