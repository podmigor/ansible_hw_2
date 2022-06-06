terraform {
  required_providers {
    google = {
      source = "registry.terraform.io/hashicorp/google"
    }
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}