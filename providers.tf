// GCP provider

provider "google" {
  credentials = file("~/gcp-auth.json")
  project = var.gcp_project // to change
  region  = var.gcp_region
  zone = var.gcp_zone
}