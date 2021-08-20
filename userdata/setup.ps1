$ipv4='${Disk_volume_ipv4}'
$iqn='${Disk_volume_iqn}'
$isWin2008 = '${iswin2008}'
$disk_letter = '${disk_letter}'
$disk_number = '${disk_number}'+1
$disk_number_offset = '${disk_number}'+3
$disk_label = '${disk_label}'


Write-Output 'Configuring ISCSI for Block Volumes'

if($isWin2008 -eq 1){
#Set-Item -Path WSMan:localhostClientTrustedHosts -Value nanoIPv4address
Write-Output 'Attaching Disk in Windows 2008 via ISCSICLI'
Set-Service -Name msiscsi -StartupType Automatic
Start-Service msiscsi
iscsicli.exe QAddTargetPortal $ipv4
iscsicli.exe QLoginTarget $iqn
iscsicli.exe PersistentLoginTarget $iqn * $ipv4 3260 * * * * * * * * * * * * * *

Write-Output 'Disk Attachment via ISCSICLI Completed Successfully!'

Write-Output 'Partitioning and mounting disk with DISKPART'

Write-Output 'Building diskpart Script'

echo 'select disk 1' >> C:\part.txt
echo 'clean' >> C:\part.txt
echo 'create partition primary' >> C:\part.txt
echo 'format fs=ntfs quick label="$disk_label"' >> C:\part.txt
echo 'assign letter=$disk_letter' >> C:\part.txt

Get-Content -Path "C:\part.txt" | Out-File -FilePath "C:\mountdisk.txt" -Encoding ascii

diskpart.exe /s C:\mountdisk.txt > C:\mountdiskLog.log
Write-Output 'Disk partition with DISKPART Completed Successfully!'

}else {
    Write-Output 'Configuring Disk for Windows 2012/2016'
    Set-Service -Name msiscsi -StartupType Automatic
    Start-Service msiscsi
    
    New-IscsiTargetPortal -TargetPortalAddress $ipv4
    Connect-IscsiTarget -NodeAddress $iqn -TargetPortalAddress $ipv4 -IsPersistent $True

    Write-Output 'Configuring the new disk for a partition and file system'

    Get-Disk -Number $disk_number | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel $disk_label -Confirm:$false
    Write-Output 'Configured the new disk'

    Write-Output 'Updating Disk Letter'
    echo 'select volume "$disk_number_offset"' >> C:\part.txt
    echo 'assign letter "$disk_letter"' >> C:\part.txt
    Get-Content -Path "C:\part.txt" | Out-File -FilePath "C:\updateletter.txt" -Encoding ascii
    diskpart.exe /s C:\updateletter.txt > C:\updateletter.log
    Write-Output 'Updated Letter successfully'

    Write-Output "Enabling RDP Access"
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

    Write-Output "Shutting down instance firewall"
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    
    Write-Output 'ISCSI for Block Volumes for Windows 2012/2016 Completed Successfully!'
}