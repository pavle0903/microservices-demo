resource "google_container_cluster" "gke-cluster" {
  name                     = var.name
  location                 = var.location
  network = var.network
  subnetwork = var.subnetwork
  remove_default_node_pool = true
  initial_node_count       = 1
}