terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("/home/psarenac/actions-runner/gcp_key.json")
  project     = "t1-t2-plan"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_network" "vpc" {
  name                    = "t1-t2-vpc"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}

module "dev-subnet" {
  source        = "./modules/subnetwork"
  name          = "dev-subnet"
  region        = var.dev_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

module "stage-subnet" {
  source        = "./modules/subnetwork"
  name          = "stage-subnet"
  region        = var.stage_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.1.0/24"
}

module "prod-subnet" {
  source        = "./modules/subnetwork"
  name          = "prod-subnet"
  region        = var.prod_region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_service_account" "gke-sa" {
  account_id   = "gke-service-account-id"
  display_name = "GKE Service Account"
}

module "dev-cluster" {
  source     = "./modules/gke"
  name       = "dev-cluster"
  location   = var.dev_zone
  network    = google_compute_network.vpc.self_link
  subnetwork = module.dev-subnet.self_link
}

module "dev_preemptible_nodes" {
  source          = "./modules/node_pool"
  name            = "dev-node-pool"
  location        = var.dev_zone
  cluster         = module.dev-cluster.name
  initial_node_count = 2
  min_node_count  = 1
  max_node_count  = 3
  preemptible     = true
  machine_type    = "e2-medium"
  service_account = google_service_account.gke-sa.email

}

module "stage-cluster" {
  source     = "./modules/gke"
  name       = "stage-cluster"
  location   = var.stage_zone
  network    = google_compute_network.vpc.self_link
  subnetwork = module.stage-subnet.self_link
}

module "stage_preemptible_nodes" {
  source          = "./modules/node_pool"
  name            = "stage-node-pool"
  location        = var.stage_zone
  cluster         = module.stage-cluster.name
  initial_node_count = 2
  min_node_count  = 1
  max_node_count  = 3
  preemptible     = true
  machine_type    = "e2-medium"
  service_account = google_service_account.gke-sa.email
}

module "prod-cluster" {
  source     = "./modules/gke"
  name       = "prod-cluster"
  location   = var.prod_zone
  network    = google_compute_network.vpc.self_link
  subnetwork = module.prod-subnet.self_link
}

module "prod_preemptible_nodes" {
  source          = "./modules/node_pool"
  name            = "prod-node-pool"
  location        = var.prod_zone
  cluster         = module.prod-cluster.name
  initial_node_count = 2
  min_node_count  = 1
  max_node_count  = 3
  preemptible     = true
  machine_type    = "e2-medium"
  service_account = google_service_account.gke-sa.email
}