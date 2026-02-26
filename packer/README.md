# Homelab Packer

Contains various Packer configurations for my home VM / Dev infrastructure.

_Repo is based upon [stardata/packer-centos7-kvm-example](https://github.com/stardata/packer-centos7-kvm-example)_

## Configs

* `rocky-base.hcl` - Base Rocky 8 image with a 25 GB primary hard disk as default.
    * `docker-ce` pre-installed.
    * `git` pre-installed.
    * `epel` repository enabled.
    * Basic monitoring tools installed.

## Building

_To build a config you must have `packer` installed (Availiable through your package manager or you can get pre-built binaries on the packer.io website)._

To build, issue this command below with the config that you want to build.
```
packer build <hcl config file>
```

If you need to debug the build, issue this command.
```
PACKER_LOG=1 packer build <hcl config file>
```

## Note

To add upload capability, add the below code.

```
{
      "environment_vars": [
        "SSH_USERNAME={{user `ssh_username`}}",
        "SSH_PASSWORD={{user `ssh_password`}}",
      ],
      "pause_before": "10s",
      "inline": [
        "mkdir -p /home/{{ user `ssh_username` }}/packer-upload"
      ],
      "type": "shell"
    },
    {
      "type": "file",
      "source": "./packer-upload/",
      "destination": "/packer-upload"
    },
```

Also on `CentOS 8` you may need to change `qemu_binary`
```
{
  "variables": {
    "hostname": "yourfqdn",
    "qemu_path": "{{env `PWD`}}"
  },
  "builders":
  [
    {
      "type": "qemu",
      "accelerator": "kvm",
      "qemu_binary": "/usr/libexec/qemu-kvm",
      "qemuargs": [
         [ "-m", "4096" ],
         [ "-smp", "2,sockets=2,cores=1,threads=1" ]
      ],
   }
]
```


    "mount /dev/sda2 /mnt<enter><wait3s>",
    "echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter><wait3s>",
    "umount /mnt<enter><wait3s>",
    "reboot<enter><wait3s>",