//This will create network and subnet
module "network" {
  source  = "registry.terraform.io/terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = var.project
  network_name = var.network_name
  providers = {
    google = google
  }

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_cidr
      subnet_region = var.region
    }
  ]

  firewall_rules = [{
    name                    = "allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = [chomp(data.http.myip.body), var.subnet_cidr, "35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["internal-ssh", "external-ssh", "web"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22", "80"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = var.region
  network = module.network.network_id

}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}
