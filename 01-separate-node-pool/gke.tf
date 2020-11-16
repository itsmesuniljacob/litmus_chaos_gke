# Specify the GCP Provider
provider "google-beta" {
    project = var.project_id
    region  = var.region
    version = "~> 3.10"
    alias   = "gb3"
}

resource "google_container_cluster" "primary" {
  provider    = google-beta.gb3
  name     = "my-gke-cluster"
  location = "us-east4-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

      # Enable Workload Identity
  workload_identity_config {
     identity_namespace = "${var.project_id}.svc.id.goog"
    }  

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  provider           = google-beta.gb3
  location = "us-east4-a"  
  name       = "my-node-pool"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "g1-small"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "secondary_preemptible_nodes" {
  provider           = google-beta.gb3
  location = "us-east4-a"
  name       = "my-node-pool-secondary"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "g1-small"
    
    service_account = "kubernetes-engine-node-sa@my-gcp-project-290010.iam.gserviceaccount.com"
    
    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
        node_metadata = "GKE_METADATA_SERVER"
    }  

    oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}