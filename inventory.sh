#! /bin/bash

DB_CONF="/onapp/interface/config/database.yml"
INVENTORY="inventory"

DB=$(awk '/database:/ {print $2; exit}' $DB_CONF)
DB_PASSWORD=$(awk '/password:/ {print$2; exit}' $DB_CONF)
DB_HOST=$(awk '/host:/ {print $2; exit}' $DB_CONF)
DB_PORT=$(awk '/port:/ {print $2; exit}' $DB_CONF)
DB_USERNAME=$(awk '/username:/ {print $2; exit}' $DB_CONF)

read -ra STATIC_KVM_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM hypervisors WHERE hypervisor_type = 'kvm' AND enabled = 1 AND mac IS NULL")

echo "[static_kvm]" > $INVENTORY
for ip in "${STATIC_KVM_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

read -ra STATIC_XEN_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM hypervisors WHERE hypervisor_type = 'xen' AND enabled = 1 AND mac IS NULL")

echo "[static_xen]" >> $INVENTORY
for ip in "${STATIC_XEN_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

read -ra STATIC_BK_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM backup_servers WHERE enabled = 1 AND ip_address NOT IN (SELECT ip_address FROM hypervisors)")

echo "[static_bs]" >> $INVENTORY
for ip in "${STATIC_BK_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

read -ra CB_KVM_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM hypervisors WHERE hypervisor_type = 'kvm' AND enabled = 1 AND mac IS NOT NULL AND backup = 0")

echo "[cb_kvm]" >> $INVENTORY
for ip in "${CB_KVM_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

read -ra CB_XEN_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM hypervisors WHERE hypervisor_type = 'xen' AND enabled = 1 AND mac IS NOT NULL AND backup = 0")

echo "[cb_xen]" >> $INVENTORY
for ip in "${CB_XEN_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

read -ra CB_BK_IPS -d '' <<<$(mysql -p${DB_PASSWORD} ${DB} -u ${DB_USERNAME} -h ${DB_HOST} --port=${DB_PORT} -se \
"SELECT ip_address FROM hypervisors WHERE enabled = 1 AND mac IS NOT NULL AND backup = 1")

echo "[cb_bs]" >> $INVENTORY
for ip in "${CB_BK_IPS[@]}"
do
  echo $ip  >> $INVENTORY
done

