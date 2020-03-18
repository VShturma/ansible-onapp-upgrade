#! /bin/bash

DB_CONF="/onapp/interface/config/database.yml"
INVENTORY="inventory"

DB=$(awk '/database:/ {print $2; exit}' $DB_CONF)
DB_PASSWORD=$(awk '/password:/ {print$2; exit}' $DB_CONF)
DB_HOST=$(awk '/host:/ {print $2; exit}' $DB_CONF)
DB_PORT=$(awk '/port:/ {print $2; exit}' $DB_CONF)
DB_USERNAME=$(awk '/username:/ {print $2; exit}' $DB_CONF)

read -ra KVM_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se "SELECT ip_address FROM hypervisors WHERE hypervisor_type = 'kvm' AND enabled = 1")
echo "[kvm]" >> $INVENTORY
for ip in "${KVM_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

