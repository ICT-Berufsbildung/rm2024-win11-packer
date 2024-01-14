
variable "autounattend" {
  type    = string
  default = "./scripts/Autounattend.xml"
}

variable "disk_type_id" {
  type    = string
  default = "0"
}

variable "iso_checksum" {
  type    = string
  default = "36de5ecb7a0daa58dce68c03b9465a543ed0f5498aa8ae60ab45fb7c8c4ae402"
}

variable "iso_url" {
  type    = string
  default = "/data/thushjandan/ISOs/Win11_23H2_English_x64v2.iso"
}

variable "name" {
  type    = string
  default = "rm2024-win11-base"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

locals {
  output_directory = "rm2024-win-${legacy_isotime("20060102_1504")}"
}

source "vmware-iso" "autogenerated_1" {
  boot_wait         = "2m"
  communicator      = "winrm"
  cpus              = "4"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  disk_type_id      = "${var.disk_type_id}"
  display_name      = "${var.name}"
  floppy_files      = [
    "${var.autounattend}", 
    "./scripts/fixnetwork.ps1",
    "./scripts/disable-screensaver.ps1",
    "./scripts/disable-winrm.ps1",
    "./scripts/enable-winrm.ps1",
    "./scripts/microsoft-updates.bat",
    "./scripts/win-updates.ps1"
  ]
  guest_os_type     = "windows9-64"
  headless          = false
  http_directory    = "httpdir"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "8192"
  network           = "nat"
  output_directory  = "${local.output_directory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  version           = 18
  vm_name           = "${var.name}"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max   = 5980
  vnc_port_min   = 5900
  winrm_password = "Go4Regio24"
  winrm_timeout  = "1h"
  winrm_username = "vagrant"
}

build {
  sources = ["source.vmware-iso.autogenerated_1"]
}