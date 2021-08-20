# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# format_disk.ps1
#
# Purpose: Takes care of attaching disk to instance

Write-Host "Getting parameters of the execution"
$partitionstyle=$args[0]
$filesystem=$args[1]
$newfilesystemlabel=$args[2]
$newdriveletter=$args[3]
$iqn=$args[4]

Write-Host "Checking if partition $newdriveletter exists"
$exists = (Test-Path "${newdriveletter}:")
if(-Not $exists){

   Write-Host "Getting disk information to format"
   $device = (Get-WmiObject -namespace ROOT\WMI -class MSiSCSIInitiator_SessionClass -Filter "TargetName='$iqn'").Devices | Select -last 1
   $disknumber = $device.DeviceNumber
   Write-Host "Disk number found =  $disknumber"

   Write-Host "Formatting disk..."
   Get-Disk -Number $disknumber | Initialize-Disk -PartitionStyle $partitionstyle -PassThru | New-Partition -AssignDriveLetter:$False -UseMaximumSize | Format-Volume -Confirm:$False -FileSystem $filesystem -NewFileSystemLabel $newfilesystemlabel -Force

   Write-Host "Resseting disk letter..."
   Get-Partition -DiskNumber $disknumber | Set-Partition -NewDriveLetter $newdriveletter

} else {

   Write-host "Drive ${newdriveletter} checked and located. Skipping format disk..."

}

Write-Host "Done!"
