packer {
  required_plugins {
    qemu = {
      version = "= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "25G"
}

variable "memory" {
  type    = string
  default = "2512"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type    = string
  default = "root"
}

variable "headless" {
  type    = bool
  default = false
}

source "qemu" "rocky" {
  accelerator = "kvm"
  boot_command = [
    "<up>e<wait><down><down><end><bs><bs><bs><bs><bs> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky-ks.cfg <leftCtrlOn>x<leftCtrlOff><wait>"
  ]
  boot_wait        = "10s"
  communicator     = "ssh"
  disk_interface   = "virtio-scsi"
  disk_size        = "${var.disk_size}"
  firmware         = "/usr/share/OVMF/OVMF_CODE.fd"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "http/rocky"
  iso_checksum     = "sha256:bae6eeda84ecdc32eb7113522e3cd619f7c8fc3504cb024707294e3c54e58b40"
  iso_url          = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-minimal.iso"
  memory           = "${var.memory}"
  net_device       = "virtio-net"
  output_directory = "rocky-output"
  qemuargs         = [["-smp", "cpus=${var.cpus}"]]
  shutdown_command = "poweroff"
  ssh_password     = "${var.ssh_password}"
  ssh_username     = "${var.ssh_username}"
  ssh_timeout      = "15m"
  vm_name          = "rocky-base.qcow2"
}

build {
  sources = ["source.qemu.rocky"]

  provisioner "file" {
    source      = "./files"
    destination = "/tmp/"
  }

  provisioner "shell" {
    environment_vars = ["SSH_USERNAME=${var.ssh_username}", "SSH_PASSWORD=${var.ssh_password}"]
    pause_before     = "10s"
    scripts          = ["steps/rocky/00-base.sh"]
  }
}
