terraform {
  backend "gcs" {
    bucket = "t1-t2-tf-backend"
    prefix = "devops-t1-t2"
}
}
