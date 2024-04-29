terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  backend "gcs" {
    bucket = "t1-t2-tf-backend"
    prefix = "devops-t1-t2"
    credentials = var.service_account_key
  }
}

provider "google" {
  credentials = var.service_account_key
  project     = "devops-t1-t2"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_network" "vpc" {
  name                    = "t1-t2-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "t1-t2-subnet" {
  name          = "t1t2-subnet"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_service_account" "gke-sa" {
  account_id   = "gke-service-account-id"
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "pavle-cluster" {
  name                     = "gke-cluster"
  location                 = "us-central1"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "pavle_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.pavle-cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    service_account = google_service_account.gke-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
