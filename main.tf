data "google_project" "project" {}

resource "google_compute_router" "this" {
  region  = var.region
  name    = "${var.workload_vpc_name}-cr"
  network = var.workload_vpc_name
  bgp {
    asn = var.cr_asn
  }
}

resource "google_compute_address" "this" {
  for_each = toset(["pri", "ha"])

  name         = "${var.workload_vpc_name}-cr-address-${each.value}"
  region       = var.region
  subnetwork   = var.subnetwork_link
  address_type = "INTERNAL"
}


resource "google_compute_router_interface" "pri" {
  name                = "${var.workload_vpc_name}-cr-int-pri"
  router              = google_compute_router.this.name
  region              = var.region
  subnetwork          = var.subnetwork_link
  private_ip_address  = google_compute_address.this["pri"].address
  redundant_interface = google_compute_router_interface.ha.name
}


resource "google_compute_router_interface" "ha" {
  name               = "${var.workload_vpc_name}-cr-int-ha"
  router             = google_compute_router.this.name
  region             = var.region
  subnetwork         = var.subnetwork_link
  private_ip_address = google_compute_address.this["ha"].address
}

resource "google_network_connectivity_spoke" "avx" {
  name     = "${var.workload_vpc_name}-ncc-avx"
  location = var.region
  hub      = var.ncc_hub_id
  linked_router_appliance_instances {
    instances {
      virtual_machine = local.transit_pri_self_link
      ip_address      = var.transit_pri_bgp_ip
    }
    instances {
      virtual_machine = local.transit_ha_self_link
      ip_address      = var.transit_ha_bgp_ip
    }
    site_to_site_data_transfer = true
  }
  lifecycle {
    ignore_changes = [
      linked_router_appliance_instances
    ]
  }
}

resource "google_compute_router_peer" "pri" {
  for_each = { "pri" = 0, "ha" = 1 }

  name                      = "${var.workload_vpc_name}-ncc-avx-crpri-to-${each.key}-gw"
  router                    = google_compute_router.this.name
  region                    = var.region
  peer_ip_address           = [var.transit_pri_bgp_ip, var.transit_ha_bgp_ip][each.value]
  peer_asn                  = var.avx_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.pri.name
  router_appliance_instance = [google_network_connectivity_spoke.avx.linked_router_appliance_instances[0].instances[0].virtual_machine, google_network_connectivity_spoke.avx.linked_router_appliance_instances[0].instances[1].virtual_machine][each.value]

  lifecycle {
    ignore_changes = [
      peer_ip_address,
      router_appliance_instance
    ]
  }
}

resource "google_compute_router_peer" "ha" {
  for_each = { "pri" = 0, "ha" = 1 }

  name                      = "${var.workload_vpc_name}-ncc-avx-crha-to-${each.key}-gw"
  router                    = google_compute_router.this.name
  region                    = var.region
  peer_ip_address           = [var.transit_pri_bgp_ip, var.transit_ha_bgp_ip][each.value]
  peer_asn                  = var.avx_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.ha.name
  router_appliance_instance = [google_network_connectivity_spoke.avx.linked_router_appliance_instances[0].instances[0].virtual_machine, google_network_connectivity_spoke.avx.linked_router_appliance_instances[0].instances[1].virtual_machine][each.value]

  lifecycle {
    ignore_changes = [
      peer_ip_address,
      router_appliance_instance
    ]
  }
}

resource "aviatrix_transit_external_device_conn" "avx_to_cr" {
  vpc_id                    = var.transit_vpc_id
  connection_name           = "${var.workload_vpc_name}-avx-to-ncc"
  gw_name                   = var.transit_pri_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  bgp_local_as_num          = var.avx_asn
  bgp_remote_as_num         = var.cr_asn
  remote_lan_ip             = google_compute_address.this["pri"].address
  local_lan_ip              = var.transit_pri_bgp_ip
  ha_enabled                = true
  backup_bgp_remote_as_num  = var.cr_asn
  backup_remote_lan_ip      = google_compute_address.this["ha"].address
  backup_local_lan_ip       = var.transit_ha_bgp_ip
  enable_bgp_lan_activemesh = true

  lifecycle {
    ignore_changes = [
      gw_name,
      local_lan_ip,
      backup_local_lan_ip,
      vpc_id
    ]
  }
}

resource "aviatrix_segmentation_network_domain_association" "this" {
  count = var.network_domain == null ? 0 : 1

  network_domain_name = var.network_domain
  attachment_name     = aviatrix_transit_external_device_conn.avx_to_cr.connection_name
}