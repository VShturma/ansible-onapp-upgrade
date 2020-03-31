# ansible-onapp-upgrade

This is an Ansible playbook which can be used for upgrading Hypervisors and Backup Servers managed by [OnApp](https://onapp.com).
At the moment it only works with static KVM / XEN Hypervisors and Backup Servers.

## Installation

At the Control Panel server clone this repo or download its content to some working directory. 
Preferably under ```onapp``` user.

## Usage

1. In the working directory run ```generate_hosts.sh``` script in order to generate ```hosts``` file.
Currently, the inventory is populated with both static and cloudboot resources. However, only static resources are used in the playbooks.

```
./generate_hosts.sh
```

```
cat hosts

[static_kvm]
10.76.0.104
10.76.0.105
[static_xen]
10.76.0.106
10.76.0.107
[static_bs]
10.76.0.109
[cb_kvm]
10.76.0.100
10.76.0.101
[cb_xen]
10.76.0.102
10.76.0.103
[cb_bs]
10.76.0.108
```

2. Provide the target OnApp version at ``` roles/common/vars/main.yml```

```
cat roles/common/vars/main.yml 
# file: roles/common/vars/main.yml

---
onapp_version: 6.2
```

3. Run the playbooks.
You can upgrade the entire infrastrucure at once:

```
ansible-playbook -i hosts site.yml
```

or upgrade 1 group only. For example, KVM Hypervisors:

```
ansible-playbook -i hosts kvm.yml
```

## Contributing

Pull requests are welcome :)

