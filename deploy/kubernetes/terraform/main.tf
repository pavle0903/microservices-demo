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
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "dev-subnet" {
    name = "subnetwork"
    region = "us-east1"
    network = google_compute_network.vpc.id
    ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_subnetwork" "stage-subnet" {
    name = "subnetwork"
    region = "us-west1"
    network = google_compute_network.vpc.id
    ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "prod-subnet" {
    name = "subnetwork"
    region = "us-central1"
    network = google_compute_network.vpc.id
    ip_cidr_range = "10.0.2.0/24"
}

resource "google_service_account" "gke-sa" {
  account_id   = "gke-service-account-id"
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "dev-cluster" {
  name     = "dev-cluster"
  location = "us-east1-c"
  remove_default_node_pool = true
  initial_node_count       = 1
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.dev-subnet.self_link
}

resource "google_container_node_pool" "dev_preemptible_nodes" {
  name       = "dev-node-pool"
  location   = "us-east1-c"
  cluster    = google_container_cluster.dev-cluster.name
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

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

resource "google_container_cluster" "stage-cluster" {
  name     = "stage-cluster"
  location = "us-west1-c"
  remove_default_node_pool = true
  initial_node_count       = 1
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.stage-subnet.self_link
}

resource "google_container_node_pool" "stage_preemptible_nodes" {
  name       = "stage-node-pool"
  location   = "us-west1-c"
  cluster    = google_container_cluster.stage-cluster.name
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

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

resource "google_container_cluster" "prod-cluster" {
  name     = "prod-cluster"
  location = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count       = 1
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.prod-subnet.self_link
}

resource "google_container_node_pool" "prod_preemptible_nodes" {
  name       = "prod-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.prod-cluster.name
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

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