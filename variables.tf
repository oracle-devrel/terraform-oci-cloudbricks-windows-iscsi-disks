# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# variables.tf 
#
# Purpose: The following file declares all variables used in this backend repository

/********** Provider Variables NOT OVERLOADABLE **********/
variable "region" {
  description = "Target region where artifacts are going to be created"
}

variable "tenancy_ocid" {
  description = "OCID of tenancy"
}

variable "user_ocid" {
  description = "User OCID in tenancy. Currently hardcoded to user denny.alquinta@oracle.com"
}

variable "fingerprint" {
  description = "API Key Fingerprint for user_ocid derived from public API Key imported in OCI User config"
}

variable "private_key_path" {
  description = "Private Key Absolute path location where terraform is executed"

}
/********** Provider Variables NOT OVERLOADABLE **********/

/********** Brick Variables **********/

/************* Datasource Script Variables *************/
variable "iscsi_disk_instance_compartment_name" {
  description = "Defines the compartment name where the infrastructure will be created"
}
/************* Datasource Script Variables *************/

/************* Disk Variables *************/
variable "ssh_private_is_path" {
  description = "Determines if key is supposed to be on file or in text"
  default     = true
}

variable "ssh_private_key" {
  description = "Determines what is the private key to connect to machine"
}

variable "amount_of_disks" {
  description = "Amount of equally sized disks"
}

variable "disk_size_in_gb" {
  description = "Size in GB for Product Disk"
}

variable "volume_display_name" {
  description = "Disk display name."
}

variable "attachment_type" {
  description = "Atacchment type can be iscsi or paravirtualized"
  default     = "iscsi"
}

variable "windows_compute_id" {
  description = "OCI Id for instance to attach the disk"
  default     = null
}

variable "attach_disks" {
  description = "Atach disk to a Linux instance"
  default     = true
}

variable "backup_policy_level" {
  description = "Backup policy level for ISCSI disks"
}

variable "vpus_per_gb" {
  default = 10
}

variable "compute_display_name" {
  description = "Name of the compute where the disk will be attached to"

}

variable "compute_availability_domain_list" {
  type        = list(any)
  description = "Defines the availability domain list where OCI artifact will be created. This is a numeric value greater than 0"
}

variable "windows_compute_private_ip" {
  description = "Compute private IP to logon into machine"
}

variable "is_winrm_configured_for_image" {
  description = "Defines if winrm is being used in this installation"
  default     = "true"
}


variable "is_winrm_configured_with_ssl" {
  description = "Use the https 5986 port for winrm by default. If that fails with a http response error: 401 - invalid content type, the SSL may not be configured correctly"
  default     = "true"
}

variable "partition_style" {
  description = "Describes Partition Style for the Disk"
  default     = "MBR"
}

variable "filesystem_format" {
  description = "Describes Filesystem format for the Disk"
  default     = "NTFS"
}

variable "iswin2008" {
  description = "Describes if the instance is Windows 2008 or not"
  default     = false

}

variable "userdata" {
  description = "Describes userdata placeholder variable"
  default     = "userdata"
}

variable "setup_ps1" {
  description = "Describes setup.ps1 powershell script placeholder variable"
  default     = "setup.ps1"
}

variable "format_disk_ps1" {
  description = "Describes format_disk.ps1 powershell script placeholder variable"
  default     = "format_disk.ps1"
}

variable "os_user" {
  description = "Defines default admin user for instance"
  default     = "opc"

}

variable "os_password" {
  description = "Defines Windows opc password"
}

variable "disk_label_map" {
  type        = map(any)
  description = "Mapping of Disk Letter plus it's mapping"
}
/************* Disk Variables *************/

/********** Brick Variables **********/