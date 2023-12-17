packer {
  required_plugins {
    qemu = {
      version = "= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "cpus" {
  description = "Number of CPUs for the VM"
  type        = string
  default     = "2"
}

variable "disk_size" {
  description = "Disk size for the VM"
  type        = string
  default     = "25G"
}

variable "memory" {
  description = "Memory size for the VM"
  type        = string
  default     = "2512"
}

variable "ssh_username" {
  description = "SSH username to login into the VM"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH password to login into the VM"
  type        = string
  default     = "alpine"
}

variable "root_password" {
  description = "Root password for the VM"
  type        = string
  default     = "alpine"
}

variable "headless" {
  description = "Run the VM in headless mode"
  type        = bool
  default     = false
}

variable "upload_other_files_destination" {
  description = "Destination directory for other files to be uploaded to the VM"
  type        = string
  default     = "/opt/upload"
}

# Step 1 build stage (source).
source "qemu" "alpine-step1" {
  accelerator = "kvm"
  boot_steps = [
    ["root<enter><wait3s>", "Login as root"],
    ["clear<enter><wait3s>", "Clear screen"],
    ["setup-interfaces -ar<enter><wait10s>", "Setup interfaces"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/alpine.cfg -q<enter><wait3s>", "Download alpine.cfg"],
    ["ERASE_DISKS=/dev/sda setup-alpine -e -f alpine.cfg<enter><wait3s>", "Setup system"],
    ["<wait30>", "Wait for setup to finish (1/4)"],
    ["<wait30>", "Wait for setup to finish (2/4)"],
    ["<wait30>", "Wait for setup to finish (3/4)"],
    ["<wait30>", "Wait for setup to finish (4/4)"],
    ["clear<enter><wait3>", "Clear the screen"],
    ["mount /dev/sda2 /mnt<enter><wait3>", "Mount root partition"],
    ["echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter><wait>", "Enable root login"],
    ["umount /mnt<enter><wait3>", "Unmount root partition"],
    ["poweroff<enter><wait30>", "Power off"]
  ]
  boot_wait        = "60s"
  communicator     = "none"
  disk_interface   = "virtio-scsi"
  disk_size        = "${var.disk_size}"
  firmware         = "/usr/share/OVMF/OVMF_CODE.fd"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "http/alpine"
  iso_checksum     = "sha256:d4924fbcc912f1cea909c20c72fe0cce65308b8ee80db3f11fc9e25d77972f78"
  iso_url          = "https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-extended-3.17.3-x86_64.iso"
  memory           = "${var.memory}"
  net_device       = "virtio-net"
  output_directory = "alpine-output-step1"
  qemuargs         = [["-smp", "cpus=${var.cpus}"]]
  shutdown_command = "poweroff"
  ssh_password     = "${var.ssh_password}"
  ssh_username     = "${var.ssh_username}"
  ssh_timeout      = "15m"
  vm_name          = "alpine-base-step1.qcow2"
}

# Step 1 build stage (post-processor).
build {
  sources = ["source.qemu.alpine-step1"]
}

# Step 2 build stage (source).
source "qemu" "alpine-step2" {
  accelerator = "kvm"
  boot_steps = [
    ["root<enter><wait3s>", "Login as root"],
    ["clear<enter><wait3s>", "Clear screen"],
    ["passwd<enter><wait3s>", "Initiate password change"],
    ["${var.root_password}<enter><wait3s>", "Enter new password"],
    ["${var.root_password}<enter><wait3s>", "Confirm new password"],
    ["clear<enter><wait3s>", "Clear screen"]
  ]
  boot_wait        = "60s"
  communicator     = "ssh"
  disk_image       = true
  disk_interface   = "virtio-scsi"
  disk_size        = "${var.disk_size}"
  firmware         = "/usr/share/OVMF/OVMF_CODE.fd"
  format           = "qcow2"
  headless         = "${var.headless}"
  http_directory   = "http/alpine"
  iso_checksum     = "none"
  iso_url          = "./alpine-output-step1/alpine-base-step1.qcow2"
  memory           = "${var.memory}"
  net_device       = "virtio-net"
  output_directory = "alpine-output-step2"
  qemuargs         = [["-smp", "cpus=${var.cpus}"], ["-boot", "once=c"]]
  shutdown_command = ""
  ssh_password     = "${var.ssh_password}"
  ssh_username     = "${var.ssh_username}"
  ssh_timeout      = "15m"
  vm_name          = "alpine-base-step2.qcow2"
}

# Step 2 build stage (post-processor).
build {
  sources = ["source.qemu.alpine-step2"]

  provisioner "shell" {
    environment_vars = ["SSH_USERNAME=${var.ssh_username}"]
    inline = [
      "apk update",
      "apk upgrade",
      "apk add bash bash-completion curl wget nano htop blkid git tree",
      "apk add linux-firmware-isci",
      "rm -vf /etc/motd /etc/issue /etc/issue.net",
      "rm -rvf /sbin/setup-*"
    ]
  }

  # Copy files/motd to /etc/motd.
  provisioner "file" {
    destination = "/etc/motd"
    source      = "files/motd"
  }

  # Copy files/issue to /etc/issue.
  provisioner "file" {
    destination = "/etc/issue"
    source      = "files/issue"
  }

  # Copy files/issue to /etc/issue.net.
  provisioner "file" {
    destination = "/etc/issue.net"
    source      = "files/issue"
  }

  # Copy files/sshd.conf.alpine to /etc/ssh/sshd_config.
  provisioner "file" {
    destination = "/etc/ssh/sshd_config"
    source      = "files/sshd.conf.alpine"
  }

  # Copy files/limits.conf to /etc/security/limits.conf.
  provisioner "file" {
    destination = "/etc/security/limits.conf"
    source      = "files/limits.conf"
  }

  # Copy sysctl-optimized.conf to /etc/sysctl.d/99-sysctl-optimized.conf.
  provisioner "file" {
    destination = "/etc/sysctl.d/99-sysctl-optimized.conf"
    source      = "files/sysctl-optimized.conf"
  }

  # Create directory specified in var.upload_other_files_destination.
  provisioner "shell" {
    environment_vars = ["SSH_USERNAME=${var.ssh_username}"]
    inline = ["mkdir -p ${var.upload_other_files_destination}"]
  }

  # Upload files if var.upload_files is set to true.
  provisioner "file" {
    destination = "${var.upload_other_files_destination}"
    source      = "files/upload/"
  }

  # List files in the uploaded other files destination directory.
  provisioner "shell" {
    environment_vars = ["SSH_USERNAME=${var.ssh_username}"]
    inline = ["ls -la ${var.upload_other_files_destination}"]
  }

  # Poweroff the VM.
  provisioner "shell" {
    environment_vars = ["SSH_USERNAME=${var.ssh_username}"]
    inline           = ["poweroff"]
  }
}
