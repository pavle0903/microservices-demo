resource "google_container_node_pool" "gke_preemptible_nodes" {
  name     = var.name
  location = var.location
  cluster  = var.cluster
  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    service_account = var.service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}