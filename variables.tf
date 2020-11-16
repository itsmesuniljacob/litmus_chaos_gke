variable "project_id" {
    description = "Google Project ID."
    type        = string
  }

  variable "region" {
    description = "Google Cloud region"
    type        = string
    default     = "us-east4"
  }

    variable "zone" {
    description = "Google Cloud zone"
    type        = string
    default     = "us-east4-a"
  }

  variable "machine_type" {
    description = "Google VM Instance type."
    type        = string
  }