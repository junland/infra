# Infrastructure

Monorepo for all my self-hosting infrastructure needs. Covers OS image building, server configuration, containerized services, cloud DNS management, and system maintenance scripts.

> [!NOTE]
> For active experiments and in-progress work related to this repository, head over to [infra-sandbox](https://github.com/junland/infra-sandbox)

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| [`packer/`](packer/) | Builds base VM images for Rocky Linux and Alpine Linux |
| [`ansible/`](ansible/) | Configures servers, deploys k3s, and manages containerized services |
| [`terraform/`](terraform/) | Manages Cloudflare DNS zones and records |
| [`services/`](services/) | Docker/Podman Compose stacks for self-hosted applications |
| [`scripts/`](scripts/) | Utility scripts for backups, ZFS, certificates, and media |
| [`docs/`](docs/) | Manual setup steps and hardware-specific notes |

## Components

### Packer — Image Building

Builds QEMU/KVM base images using automated installation (kickstart for Rocky, setup-alpine for Alpine). Each image is provisioned with Docker/Podman, Git, ZFS utilities, and hardened SSH configuration. Provisioning steps live under `packer/steps/`.

### Ansible — Configuration Management

Applies roles across inventory groups to configure servers end-to-end:

- **`base-server`** — OS hardening, package updates, common tooling.
- **`k3s`** — Deploys a lightweight Kubernetes cluster.
- **`services`** — Deploys containerized application stacks.

Notable services deployed via Ansible: Homarr, Transmission, MinIO, Nextcloud, Node-RED, Grafana, Loki, and Prometheus.

### Terraform — DNS & Cloud Resources

Manages Cloudflare DNS using the Cloudflare v5 provider. Creates A records for primary hosts, per-service DNS entries, and optional wildcard records. Variables are defined in `terraform/_vars.tf` and values are supplied via `1local.auto.tfvars`.

### Services — Compose Stacks

Self-contained Docker/Podman Compose stacks. All services share the `proxy-net` network for HAProxy reverse-proxy integration.

| Service | Purpose |
|---------|---------|
| `adguard` | DNS filtering and ad-blocking |
| `gitd` | Git hosting (Forgejo) with a built-in CI/CD runner |
| `gluetun` | VPN client gateway for other containers |
| `haproxy` | Reverse proxy and TLS termination |
| `hass` | Home Assistant with MQTT broker (Mosquitto) |
| `jellyfin` | Media server with NVIDIA GPU support |
| `libvirt` | KVM/QEMU virtualization daemon |
| `ollama` | Local LLM inference engine |

### Scripts — Maintenance Utilities

Bash scripts covering:

- **Backups:** container volumes, ZFS snapshots, remote and external backup targets.
- **Certificates:** issuance and renewal via lego, OCSP stapling generation.
- **ZFS:** snapshot creation, pruning, and pool scrubbing.
- **Containers:** image pulls, system cleanup.
- **Media:** stream and video ingestion/organization.

### Docs — Documentation & Notes

[`docs/DIY.md`](docs/DIY.md) covers manual bootstrapping steps not yet automated, including SSL setup with acme.sh, RAID controller driver configuration, and ZFS ACL/Samba permission setup.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
