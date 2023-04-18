variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnetwork_link" {
  description = "Self_link of BGP subnet."
  type        = string
}

variable "ncc_hub_id" {
  description = "Id of NCC hub."
  type        = string
}

variable "workload_vpc_name" {
  description = "Name of the workload VPC"
  type        = string
}

variable "transit_vpc_id" {
  description = "VPC ID of Transit Gateway"
  type        = string
}

variable "transit_pri_name" {
  description = "Name of Transit Gateway"
  type        = string
}

variable "transit_pri_ip" {
  description = "IP of Primary Transit Gateway"
  type        = string
}

variable "transit_pri_bgp_ip" {
  description = "IP of Primary Transit Gateway"
  type        = string
}

variable "transit_pri_zone" {
  description = "Zone of Primary Transit Gateway"
  type        = string
}

variable "transit_ha_ip" {
  description = "IP of HA Transit Gateway"
  type        = string
}

variable "transit_ha_bgp_ip" {
  description = "IP of HA Transit Gateway"
  type        = string
}

variable "transit_ha_zone" {
  description = "Zone of HA Transit Gateway"
  type        = string
}

variable "transit_ha_name" {
  description = "Name of HA Transit Gateway"
  type        = string
}

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
  transit_pri_self_link = "${data.google_project.project.id}/zones/${var.transit_pri_zone}/instances/${var.transit_pri_name}"
  transit_ha_self_link  = "${data.google_project.project.id}/zones/${var.transit_ha_zone}/instances/${var.transit_ha_name}"
}