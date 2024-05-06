terraform {
  backend "gcs" {
    bucket = "t2-backend"
    prefix = "terraform/state"
}
}
