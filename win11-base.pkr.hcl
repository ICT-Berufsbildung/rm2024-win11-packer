packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-proxmox
    proxmox = {
      version = "1.1.6"
      source  = "github.com/hashicorp/proxmox"
    }
    # see https://github.com/rgl/packer-plugin-windows-update
    windows-update = {
      version = "0.15.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "iso_checksum" {
  type    = string
  default = "c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"
}

variable "iso_url" {
  type    = string
  default = "ISO:iso/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "iso_url_local" {
  type    = string
  default = "/data/thushjandan/ISOs/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "name" {
  type    = string
  default = "rm2025-win11-base"
}

variable "proxmox_node" {
  type    = string
  default = env("PROXMOX_NODE")
}

source "proxmox-iso" "base" {
  insecure_skip_tls_verify = true
  node              = var.proxmox_node
  template_name     = "${var.name}"
  machine           = "q35"
  cpu_type          = "host"
  cores             = "4"
  memory            = "8192"
  bios                     = "ovmf"
  efi_config {
    efi_storage_pool = "local-lvm"
  }
  vga {
    type   = "qxl"
    memory = 32
  }
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-single"
  disks {
    format        = "raw"
    type         = "scsi"
    io_thread    = true
    ssd          = true
    discard      = true
    disk_size    = "61440M"
    storage_pool = "local-lvm"
  }
  unmount_iso      = true
  additional_iso_files {
    device           = "ide0"
    unmount          = true
    iso_storage_pool = "local"
    cd_label         = "PROVISION"
    cd_files = [
      "./scripts/Autounattend.xml", 
      "drivers/NetKVM/w11/amd64/*.cat",
      "drivers/NetKVM/w11/amd64/*.inf",
      "drivers/NetKVM/w11/amd64/*.sys",
      "drivers/qxldod/w11/amd64/*.cat",
      "drivers/qxldod/w11/amd64/*.inf",
      "drivers/qxldod/w11/amd64/*.sys",
      "drivers/vioscsi/w11/amd64/*.cat",
      "drivers/vioscsi/w11/amd64/*.inf",
      "drivers/vioscsi/w11/amd64/*.sys",
      "drivers/vioserial/w11/amd64/*.cat",
      "drivers/vioserial/w11/amd64/*.inf",
      "drivers/vioserial/w11/amd64/*.sys",
      "drivers/viostor/w11/amd64/*.cat",
      "drivers/viostor/w11/amd64/*.inf",
      "drivers/viostor/w11/amd64/*.sys",
      "drivers/virtio-win-guest-tools.exe",
      "scripts/provision-autounattend.ps1",
      "scripts/provision-guest-tools-qemu-kvm.ps1",
      "scripts/provision-openssh.ps1",
      "scripts/provision-psremoting.ps1",
      "scripts/provision-pwsh.ps1",
      "scripts/provision-winrm.ps1",
    ]
  }
  os     = "win11"
  http_directory    = "httpdir"
  iso_checksum      = "${var.iso_checksum}"
  iso_file           = "${var.iso_url}"
  ssh_password = "Go4Regio25"
  ssh_timeout  = "1h"
  ssh_username = "regio"
  boot_wait         = "1s"
  boot_command   = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
}

source "vmware-iso" "base" {
  boot_wait         = "2m"
  communicator      = "ssh"
  cpus              = "4"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  disk_type_id      = "0"
  display_name      = "${var.name}"
  output_directory  = "./output/${var.name}"
  floppy_files      = [
      "./scripts/win-11-bios/Autounattend.xml",
      "scripts/provision-autounattend.ps1",
      "scripts/provision-openssh.ps1",
      "scripts/provision-psremoting.ps1",
      "scripts/provision-pwsh.ps1",
      "scripts/provision-winrm.ps1",
  ]
  guest_os_type     = "windows9-64"
  headless          = false
  http_directory    = "httpdir"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url_local}"
  memory            = "8192"
  network           = "nat"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  version           = 18
  vm_name           = "${var.name}"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max   = 5980
  vnc_port_min   = 5900
  ssh_password = "Go4Regio25"
  ssh_timeout  = "1h"
  ssh_username = "regio"
}

build {
  sources = ["source.proxmox-iso.base", "source.vmware-iso.base"]

  provisioner "powershell" {
    only = ["vmware-iso.base"]
    script = "./scripts/provision-vmware-tools.ps1"
  }
  provisioner "windows-restart" {
    only = ["vmware-iso.base"]
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/disable-windows-updates.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/disable-windows-defender.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/remove-one-drive.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/remove-apps.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/provision.ps1"
  }

  provisioner "windows-update" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "scripts/enable-remote-desktop.ps1"
  }

}