variable "OAuthTocken" {
  default = "......"
}

variable "vm_ips" {
  type        = map(any)
  description = "List of IPs used for the Vms"
}

variable "guest_name_prefix" {
  default = "makhota-zabbix-agent"
}


