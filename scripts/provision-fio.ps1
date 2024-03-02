# EBS Initilization
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$trigger = New-JobTrigger -AtStartup
$options = New-ScheduledJobOption -StartIfOnBattery  -RunElevated;
$psJobsPathInScheduler = "\";
Register-ScheduledJob -Name fio -Trigger $trigger -ScriptBlock {
  & C:\ProgramData\chocolatey\bin\fio.exe --filename=\\.\PHYSICALDRIVE0  --rw=read --bs=128k --iodepth=32 --direct=1 --name=volume-initialize
}
$psJobsPathInScheduler = "\Microsoft\Windows\PowerShell\ScheduledJobs";
$settings = New-ScheduledTaskSettingsSet
$settings.Priority = 4
Set-ScheduledTask -TaskPath $psJobsPathInScheduler -TaskName fio -Principal $principal -Settings $settings
