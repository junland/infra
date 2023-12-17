# Ansible

This directory contains configurations using `Ansible`

## Roles

`base` - Common base configuration role.
`nas` - Role to configure the target as a NAS.
`services` - Various applications / services that I like to run.

## How to use.

1. Create inventory file

```
# inventory.yml
internal_servers:
  hosts:
    192.168.1.42:
      docker_enabled: true
      nfs_enabled: true 
      samba_enabled: true
      prometheus_exporter_enabled: true
      promtail_enabled: true
      prometheus_exporter_ver: "1.3.1"
      prometheus_exporter_bin_arch: "amd64"
      promtail_ver: "2.6.0"
      promtail_bin_arch: "amd64"
```

2. Edit the playbook file add roles as needed.

3. Make sure that dependencies are downloaded and installed from `requirments.yml` file.

```
ansible-galaxy collection install -v -r requirements.yml && ansible-galaxy role install -v -r requirements.yml
```

4. Execute against playbook and inventory file.

_Execute using the root username._

```

ansible-playbook -k -u root --inventory-file ./inventory.yml run.yml
```

_Execute using a non-root username with sudo access._

```
ansible-playbook -K -u john --inventory-file ./inventory.yml run.yml
```

## Software Included

* [Promtail](https://github.com/grafana/loki)
* [Loki](https://github.com/grafana/loki)
* [Grafana](https://github.com/grafana/grafana)
* [Prometheus](https://github.com/prometheus)
* [Homarr](https://github.com/ajnart/homarr)
* [Node Exporter](https://github.com/prometheus/node_exporter)