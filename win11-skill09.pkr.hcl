packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-proxmox
    proxmox = {
      version = "1.1.6"
      source  = "github.com/hashicorp/proxmox"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "name" {
  type    = string
  default = "rm2025-win11-exam"
}

variable "proxmox_node" {
  type    = string
  default = env("PROXMOX_NODE")
}

locals {
  output_directory = "output/rm2025-win11-exam-${legacy_isotime("20060102")}"
}

source "proxmox-clone" "skill09-vm" {
  insecure_skip_tls_verify = true
  node              = var.proxmox_node
  clone_vm          = "rm2025-win11-base"
  machine           = "q35"
  cpu_type          = "host"
  cores             = "4"
  memory            = "8192"
  os     = "win11"
  scsi_controller = "virtio-scsi-single"
  http_directory    = "httpdir"
  ssh_password = "Go4Regio25"
  ssh_timeout  = "1h"
  ssh_username = "regio"
}


source "vmware-vmx" "skill09-vm" {
  source_path       = "output/rm2025-win11-base/rm2025-win11-base.vmx"
  format            = "ovf"
  communicator      = "ssh"
  display_name      = "${var.name}"
  output_directory  = "${local.output_directory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  vm_name           = "${var.name}"

  http_directory    = "httpdir"
  ssh_password = "Go4Regio25"
  ssh_timeout  = "1h"
  ssh_username = "regio"
}

build {
  sources = ["source.proxmox-clone.skill09-vm", "source.vmware-vmx.skill09-vm"]

  provisioner "powershell" {
    use_pwsh = true
    script = "./scripts/provision-chocolatey.ps1"
  }

  provisioner "windows-restart" {
  }
  
  provisioner "powershell" {
    scripts = ["./scripts/provision-skill09-tools.ps1"]
  }

  provisioner "powershell" {
    only = ["proxmox-clone.skill09-vm"]
    script = "./scripts/provision-fio.ps1"
  }

  provisioner "powershell" {
    scripts = [
      "./scripts/eject-media.ps1",
      "./scripts/optimize.ps1"
    ]
  }

  provisioner "powershell" {
    only = ["vmware-vmx.skill09-vm"]
    script = "scripts/vmware-shrink-disk.ps1"
  }

  post-processors {
    post-processor "checksum" {
      only = ["vmware-vmx.skill09-vm"]
      checksum_types  = ["sha256"]
      output          = "${local.output_directory}/${var.name}_{{.ChecksumType}}.checksum"
    }
  }
}