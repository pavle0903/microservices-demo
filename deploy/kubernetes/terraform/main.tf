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
  project     = "t2-plan"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_network" "vpc" {
  name                    = "t1-t2-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
    name = "subnetwork"
    region = "us-central1"
    network = google_compute_network.vpc.id
    ip_cidr_range = "10.0.0.0/24"
}

resource "google_service_account" "gke-sa" {
  account_id   = "gke-service-account-id"
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "pavle-cluster" {
  name     = "pavle-cluster"
  location = "us-central1"
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

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_project_iam_binding" "gke_sa_admin_binding" {
  project = "t2-plan"

  role    = "roles/compute.instanceAdmin.v1"

  members = [
    "serviceAccount:${google_service_account.gke-sa.email}",
  ]
}