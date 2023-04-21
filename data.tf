data "google_compute_network" "ncc" {
  project = data.aviatrix_account.this.gcloud_project_id
  name    = local.ncc_vpc_name
}

data "google_compute_subnetwork" "ncc" {
  for_each  = toset(data.google_compute_network.ncc.subnetworks_self_links)
  self_link = each.value
}