# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# diskprovision.tf
#
# Purpose: The following script triggers the iscsi mount and then disk tagging using winrm commands with singular separated iscsi disks


resource "null_resource" "wait_for_cloudinit" {
  count = var.is_winrm_configured_for_image == "true" ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 10"
  }
}


resource "null_resource" "set_execution_policy" {
  depends_on = [null_resource.wait_for_cloudinit]
  count      = var.is_winrm_configured_for_image == "true" ? 1 : 0
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = var.windows_compute_private_ip
      user     = var.os_user
      password = var.os_password
      port     = var.is_winrm_configured_with_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_with_ssl
      insecure = "true"
    }

    inline = [
      "${local.powershell} Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser",
    ]
  }
}

resource "null_resource" "init_disk_services" {
  depends_on = [null_resource.wait_for_cloudinit]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = var.windows_compute_private_ip
      user     = var.os_user
      password = var.os_password
      port     = var.is_winrm_configured_with_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_with_ssl
      insecure = "true"
    }

    inline = [
      "${local.powershell} Set-Service -Name msiscsi -StartupType Automatic",
      "${local.powershell} Start-Service msiscsi",
    ]
  }
}



resource "null_resource" "present_disk" {
  depends_on = [null_resource.init_disk_services]
  count      = length(oci_core_volume_attachment.ISCSIDiskAttachment)
  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = var.windows_compute_private_ip
      user     = var.os_user
      password = var.os_password
      port     = var.is_winrm_configured_with_ssl == "true" ? 5986 : 5985
      https    = var.is_winrm_configured_with_ssl
      insecure = "true"
    }

    inline = [
      "${local.powershell} New-IscsiTargetPortal -TargetPortalAddress ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4}",
      "${local.powershell} Connect-IscsiTarget -NodeAddress ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].iqn} -TargetPortalAddress ${oci_core_volume_attachment.ISCSIDiskAttachment[count.index].ipv4} -IsPersistent $True",
    ]
  }
}

resource "null_resource" "init_and_format" {
  depends_on = [null_resource.present_disk]
  for_each    = var.disk_label_map
    provisioner "file" {
      connection {
        type     = "winrm"
        agent    = false
        timeout  = "1m"
        host     = var.windows_compute_private_ip
        user     = var.os_user
        password = var.os_password
        port     = var.is_winrm_configured_with_ssl == "true" ? 5986 : 5985
        https    = var.is_winrm_configured_with_ssl
        insecure = "true"
      }
      source      = local.format_disk_ps1_source
      destination = "C:/Temp/${each.key}_${var.format_disk_ps1}"
    }
    provisioner "remote-exec" {
      connection {
        type     = "winrm"
        agent    = false
        timeout  = "1m"
        host     = var.windows_compute_private_ip
        user     = var.os_user
        password = var.os_password
        port     = var.is_winrm_configured_with_ssl == "true" ? 5986 : 5985
        https    = var.is_winrm_configured_with_ssl
        insecure = "true"
      }

      inline = [        
        "${local.powershell} -file C:/Temp/${each.key}_${var.format_disk_ps1} ${var.partition_style} ${var.filesystem_format} ${each.value} ${each.key} ${oci_core_volume_attachment.ISCSIDiskAttachment[index(keys(var.disk_label_map), each.key)].iqn}",            
        "${local.powershell} Remove-Item C:/Temp/${each.key}_${var.format_disk_ps1}",  
      ]
    }
}