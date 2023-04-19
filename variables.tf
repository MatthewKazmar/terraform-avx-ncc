variable "avx_gcp_account_name" {
  description = "GCP account as it appears in the controller."
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "ncc_hub_name" {
  description = "Name of NCC hub."
  type        = string
}

variable "ncc_vpc_name" {
  description = "Name of the NCC hub VPC"
  type        = string
}

variable "bgp_subnetwork" {
  description = "Name of BGP subnet in the NCC hub VPC."
  type        = string
}

variable "transit_gateway" {
  description = "Transit Gateway resource."
  type = object(any)
}

variable "bgp_interface_index" {
  description = "Number of the BGP LAN/LANHA interface."
  type = number
}

# variable "transit_vpc_id" {
#   description = "VPC ID of Transit Gateway"
#   type        = string
# }

# variable "transit_pri_name" {
#   description = "Name of Transit Gateway"
#   type        = string
# }

# variable "transit_pri_ip" {
#   description = "IP of Primary Transit Gateway"
#   type        = string
# }

# variable "transit_pri_bgp_ip" {
#   description = "IP of Primary Transit Gateway"
#   type        = string
# }

# variable "transit_pri_zone" {
#   description = "Zone of Primary Transit Gateway"
#   type        = string
# }

# variable "transit_ha_ip" {
#   description = "IP of HA Transit Gateway"
#   type        = string
# }

# variable "transit_ha_bgp_ip" {
#   description = "IP of HA Transit Gateway"
#   type        = string
# }

# variable "transit_ha_zone" {
#   description = "Zone of HA Transit Gateway"
#   type        = string
# }

# variable "transit_ha_name" {
#   description = "Name of HA Transit Gateway"
#   type        = string
# }

variable "avx_asn" {
  description = "ASN of Aviatrix Gateway"
  type        = number
}

variable "cr_asn" {
  description = "ASN of Cloud Router"
  type        = number
}

variable "network_domain" {
  description = "Aviatrix network domain"
  type        = string
  default     = null
}

locals {
  ncc_hub_id = "projects/${data.aviatrix_account.this.gcloud_project_id}/locations/global/hubs/${var.ncc_hub_name}"

  transit_pri_self_link = "${data.aviatrix_account.this.gcloud_project_id}/zones/${var.transit_pri_zone}/instances/${var.transit_pri_name}"
  transit_ha_self_link  = "${data.aviatrix_account.this.gcloud_project_id}/zones/${var.transit_ha_zone}/instances/${var.transit_ha_name}"

  transit_vpc_id     = var.transit_gateway.vpc_id
  transit_pri_name   = var.transit_gateway.gw_name
  transit_pri_ip     = var.transit_gateway.private_ip
  transit_pri_bgp_ip = var.transit_gateway.bgp_lan_ip_list[var.bgp_interface_index]
  transit_pri_zone   = var.transit_gateway.vpc_reg
  transit_ha_name    = var.transit_gateway.ha_gw_name
  transit_ha_ip      = var.transit_gateway.ha_private_ip
  transit_ha_bgp_ip  = var.transit_gateway.ha_bgp_lan_ip_list[var.bgp_interface_index]
  transit_ha_zone    = var.transit_gateway.ha_zone
}