# Specify the GCP Provider
  provider "google-beta" {
    project = var.project_id
    region  = var.region
    version = "~> 3.10"
    alias   = "gb3"
  }

  # Create a GKE cluster
  resource "google_container_cluster" "my_k8s_cluster" {
    provider           = google-beta.gb3
    name               = "my-k8s-cluster"
    location           = var.zone
    initial_node_count = 1

    master_auth {
      username = ""
      password = ""
    }

    # Enable Workload Identity
    # workload_identity_config {
    #   identity_namespace = "${var.project_id}.svc.id.goog"
    # }

    node_config {
      preemptible  = true
      machine_type = var.machine_type
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]

      service_account = "kubernetes-engine-node-sa@my-gcp-project-290010.iam.gserviceaccount.com"
      metadata = {
        "disable-legacy-endpoints" = "true"
      }

      # workload_metadata_config {
      #   node_metadata = "GKE_METADATA_SERVER"
      # }

      labels = { # Update: Replace with desired labels
        "environment" = "test"
        "team"        = "devops"
      }
    }
  }