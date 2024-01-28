packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-proxmox
    proxmox = {
      version = "1.1.6"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "name" {
  type    = string
  default = "rm2024-win11-exam"
}

variable "proxmox_node" {
  type    = string
  default = env("PROXMOX_NODE")
}

source "proxmox-clone" "skill09-vm" {
  insecure_skip_tls_verify = true
  node              = var.proxmox_node
  clone_vm          = "rm2024-win11-base"
  machine           = "q35"
  cpu_type          = "host"
  cores             = "4"
  memory            = "8192"
  os     = "win11"
  scsi_controller = "virtio-scsi-single"
  http_directory    = "httpdir"
  ssh_password = "Go4Regio24"
  ssh_timeout  = "1h"
  ssh_username = "vagrant"
}

build {
  sources = ["source.proxmox-clone.skill09-vm"]

  provisioner "powershell" {
    scripts = ["./scripts/provision-chocolatey.ps1"]
  }

  provisioner "windows-restart" {
  }
  
  provisioner "powershell" {
    scripts = ["./scripts/provision-skill09-tools.ps1"]
  }
}