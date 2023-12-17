#!/bin/sh

set -e

NONROOT_USERNAME=admin

msg_info() {
  echo -e "\e[94m >>>> $1 \e[0m"
}

msg_fail() {
  echo -e "\e[31m >>>> $1 \e[0m"
  exit 1
}

[ `id -u` = 0 ] || msg_fail "$0: Script must be run via sudo or root user"

msg_info "Getting OS info..."

. /etc/os-release

msg_info "Running base system installation..."

msg_info "Update system..."

apk update

msg_info "Add needed packages..."

apk add git sudo bash

msg_info "Installing Wireguard..."

apk add wireguard-tools

mkdir -p /etc/wireguard

echo "wireguard" >> /etc/modules

msg_info "Create non-root user with sudo permissions..."

adduser -d "$NONROOT_USER" $NONROOT_USER

adduser $NONROOT_USER wheel

echo "$NONROOT_USER ALL=(ALL) ALL" > /etc/sudoers.d/$NONROOT_USER 

chmod 0440 /etc/sudoers.d/$NONROOT_USER

msg_info "Finished $0..."
