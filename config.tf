terraform {
    backend = "gcs"
}
provider "google" {
    version="3.41.0"
    project=var.project
    region=var.region
    zone=var.zone
}
provider "google-beta" {
    version="3.41.0"
    project=var.project
    region=var.region
    zone=var.zone
}