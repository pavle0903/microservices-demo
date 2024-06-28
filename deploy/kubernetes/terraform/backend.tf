terraform {
  backend "gcs" {
    bucket      = "t2-backend-pav"
    prefix      = "terraform/state"
    credentials = "/home/psarenac/actions-runner/gcp_key.json"
  }
}
