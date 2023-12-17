#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2023 John Unland

set -e

msg_info() {
  echo -e "\e[94m >>>> $1 \e[0m"
}

msg_fail() {
  echo -e "\e[31m >>>> $1 \e[0m"
  exit 1
}

[ "${EUID}" -eq "0" ] || msg_fail "$0: Script must be run via sudo or root user"

msg_info "Update GRUB..."

grub2-mkconfig -o /etc/grub2.cfg

msg_info "Update GRUB (UEFI)..."

grub2-mkconfig -o /etc/grub2-efi.cfg

for c in /boot/loader/entries/*.conf; do 
   echo "Processing $c entry file..";
   sed -i 's/^title Rocky Linux/title InfraOS/g' $c
done

msg_info "Rebranding complete..."
