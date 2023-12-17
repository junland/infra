#!/bin/bash

set -e

NONROOT_USERNAME=admin
PACKER_UPLOAD_DIR=/tmp/files
BASIC_PACKAGES="nano vim sshpass curl wget htop nmon git qemu-img bridge-utils python3-dnf-plugin-post-transaction-actions"
EXTRA_PACKAGES="kmod-mpt3sas"

msg_info() {
  echo -e "\e[94m >>>> $1 \e[0m"
}

msg_fail() {
  echo -e "\e[31m >>>> $1 \e[0m"
  exit 1
}

[ "${EUID}" -eq "0" ] || msg_fail "$0: Script must be run via sudo or root user"

msg_info "Getting OS info..."

. /etc/os-release

msg_info "Running base system installation..."

msg_info "Configuring dnf..."

grep -q '^max_parallel_downloads' /etc/dnf/dnf.conf && sed -i 's/^max_parallel_downloads.*/max_parallel_downloads=10/' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf

grep -q '^fastestmirror' /etc/dnf/dnf.conf && sed -i 's/^fastestmirror.*/fastestmirror=1/' /etc/dnf/dnf.conf || echo 'fastestmirror=1' >> /etc/dnf/dnf.conf

grep -q '^install_weak_deps' /etc/dnf/dnf.conf && sed -i 's/^install_weak_deps.*/install_weak_deps=False/' /etc/dnf/dnf.conf || echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf

# Enable deltarpm
# grep -q '^deltarpm' /etc/dnf/dnf.conf && sed -i 's/^deltarpm.*/deltarpm=True/' /etc/dnf/dnf.conf || echo 'deltarpm=True' >> /etc/dnf/dnf.conf

msg_info "Update system..."

dnf update -y

msg_info "Installing epel-release, elrepo-release and yum utilities..."

dnf install -y epel-release elrepo-release dnf-plugins-core && dnf update -y

msg_info "Installing basic packages and plugins..."

dnf install -y ${BASIC_PACKAGES} ${EXTRA_PACKAGES}

msg_info "Removing comments and whitespace from dnf / yum config file..."

sed -i -e '/^[ \t]*#/d' /etc/yum.conf

sed -i '/^$/d' /etc/yum.conf

msg_info "Installing sysctl tuning config file..."

cat ${PACKER_UPLOAD_DIR}/tune-sysctl.conf > /etc/sysctl.d/01-tune.conf

msg_info "Installing limits config file..."

cat ${PACKER_UPLOAD_DIR}/limits.conf > /etc/security/limits.d/limits.conf

msg_info "Installing sshd config file..."

cat ${PACKER_UPLOAD_DIR}/sshd.conf.rocky > /etc/ssh/sshd_config

msg_info "Installing issue file..."

cat ${PACKER_UPLOAD_DIR}/issue > /etc/issue

cat ${PACKER_UPLOAD_DIR}/issue.net > /etc/issue.net

msg_info "Installing Wireguard..."

mkdir -p /etc/wireguard

dnf install wireguard-tools -y

msg_info "Changing GRUB distributor name..."

sed -i 's/^GRUB_DISTRIBUTOR=.*$/GRUB_DISTRIBUTOR=\"InfrastructureOS\"/' /etc/default/grub

msg_info "Update GRUB..."

grub2-mkconfig -o /etc/grub2.cfg

msg_info "Update GRUB (UEFI)..."

grub2-mkconfig -o /etc/grub2-efi.cfg

msg_info "Rebranding GRUB entries..."

for c in /boot/loader/entries/*.conf; do
   echo "Processing $c entry file..";
   sed -i 's/^title Rocky Linux/title InfraOS/g' $c
done

msg_info "Add dnf post-transaction configuration..."

cat <<EOT >> /etc/dnf/plugins/post-transaction-actions.d/branding.action
*grub2*:in:reconf-grub-branding
*linux-kernel*:in:reconf-grub-branding
*linux*:in:reconf-grub-branding
EOT

cat ${PACKER_UPLOAD_DIR}/scripts/reconf-grub-branding.sh > /usr/local/bin/reconf-grub-branding

chmod +x /usr/local/bin/reconf-grub-branding

msg_info "Disabling swap..."

sed -i '/swap/d' /etc/fstab

msg_info "Adding hostnamectl changes..."

hostnamectl set-chassis server

hostnamectl set-deployment production

hostnamectl set-icon-name network-server

msg_info "Adding ports for ssh..."

firewall-cmd --zone=public --add-service=ssh --permanent

msg_info "Rename default eth0 connection name..."

nmcli connection modify "$(nmcli -g GENERAL.CONNECTION device show eth0)" connection.id eth0 || true

msg_info "Clean up everything..."

dnf clean all -y

dnf autoremove -y

msg_info "Finished $0..."
