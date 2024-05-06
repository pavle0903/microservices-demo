terraform {
  backend "gcs" {
    bucket = "t1-t2-tf-backend"
    prefix = "terraform/state"
}
}
