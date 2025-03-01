# Packer files for Building Windows 11 VM for Skill 09
This repository contains packer files to build a Windows 11 VM in VMX format (VMware) for the regional skill competition in Skill 09.

## Requirements
1. Install packer cli command on your machine
  * [Packer Install tutorial](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
2. Windows 11 ISO downloaded from [Microsoft Eval center](https://www.microsoft.com/de-de/evalcenter/evaluate-windows-10-enterprise)
3. Install VMware Workstation

## Build
1. Build base Windows 11 image
```
packer build -only=vmware-iso.base win11-base.pkr.hcl
```

2. Build Windows 11 image with Skill 09 flavor
```
packer build -only=vmware-vmx.skill09-vm win11-skill09.pkr.hcl
```

3. You can find the artifacts in the output folder. If you want, you can convert the ovf file to a ova file to just have a single image.
```
cd output/rm2025-win11-exam-<timestamp>
ovftool rm2025-win11-exam.ovf rm2025-win11-exam.ova
```

## Contained tools
All the tools are mainly installed over chocolately package manager.
* VMware tools
* git command line client 
* 7zip
* maven 
* intelliJ Community Edition 
* Visual Studio Community Edition 
* MySQL Community Edition 
* MySQL Workbench
* OpenJDK 
* JavaFX SDK 
* Gluon Scene Builder 
* Microsoft SQL Server Express 
* SQL Server Management Studio