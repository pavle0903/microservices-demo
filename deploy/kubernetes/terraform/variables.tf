variable "dev_region" {
  description = "Region for the dev environment"
  type        = string
  default     = "us-east1"
}

variable "stage_region" {
  description = "Region for the stage environment"
  type        = string
  default     = "us-west1"
}

variable "prod_region" {
  description = "Region for the prod environment"
  type        = string
  default     = "us-central1"
}

variable "dev_zone" {
  description = "Default zone for the dev environment"
  type        = string
  default     = "us-east1-c"
}

variable "stage_zone" {
  description = "Default zone for the stage environment"
  type        = string
  default     = "us-west1-c"
}

variable "prod_zone" {
  description = "Default zone for the prod environment"
  type        = string
  default     = "us-central1-c"
}