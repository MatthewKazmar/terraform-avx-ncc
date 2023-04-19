# terraform-avx-ncc

This module creates a regional connection between and Aviatrix Transit Gateway and Google VPC. The module requires that the Aviatrix Transit Gateway is created with a BGP over LAN interface in the specified VPC and Region.

Example:
```
resource "google_network_connectivity_hub" "prod" {
  name = prod-ncc"
}

module "avx_ncc_prod_east" {
  source = "github.com/MatthewKazmar/terraform-avx-ncc"

  region             = var.gcp_east_region
  prefix             = "${var.prefix}-prod-east"
  subnetwork_link    = module.gcp_prod_vpc.subnet_bgp[var.gcp_east_region].self_link
  ncc_hub_id         = google_network_connectivity_hub.prod.id
  ncc_vpc_name  = module.gcp_prod_vpc.vpc.name
  transit_vpc_id     = module.avx_backbone.transit["gcp_east"]["transit_gateway"].vpc_id
  transit_pri_name   = module.avx_backbone.transit["gcp_east"]["transit_gateway"].gw_name
  transit_pri_ip     = module.avx_backbone.transit["gcp_east"]["transit_gateway"].private_ip
  transit_pri_bgp_ip = module.avx_backbone.transit["gcp_east"]["transit_gateway"].bgp_lan_ip_list[0]
  transit_pri_zone   = module.avx_backbone.transit["gcp_east"]["transit_gateway"].vpc_reg
  transit_ha_name    = module.avx_backbone.transit["gcp_east"]["transit_gateway"].ha_gw_name
  transit_ha_ip      = module.avx_backbone.transit["gcp_east"]["transit_gateway"].ha_private_ip
  transit_ha_bgp_ip  = module.avx_backbone.transit["gcp_east"]["transit_gateway"].ha_bgp_lan_ip_list[0]
  transit_ha_zone    = module.avx_backbone.transit["gcp_east"]["transit_gateway"].ha_zone
  avx_asn            = local.asns["gcp_east_avx"]
  cr_asn             = local.asns["gcp_prod_east_cr"]
  security_domain    = aviatrix_segmentation_network_domain.prod.domain_name
}
```
