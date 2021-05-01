resource "google_compute_network" "network" {
  name = "sample"
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "sample-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.network.id
}


resource "google_compute_address" "static" {
  name = "ipv4-address"
}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = var.project
}

resource "google_compute_instance" "instance_with_ip" {
  name         = "my-sample-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = google_compute_network.network.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}


resource "google_service_account" "service_account" {
  account_id   = var.environment
  display_name = "example Service Account"
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:google_service_account.service_account.email",
    ]
  }
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}

resource "google_compute_firewall" "faulty-firewall" {
  name    = "fault-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["ALL"]
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_disk" "problematic-disk" {
  name  = "test-disk"
  type  = "pd-ssd"
  zone  = var.zone
  image = "sample-images"
  disk_encryption_key {}
  labels = {
    environment = "random"
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_firewall" "destruction-rule" {
  name = "not-so-cool-rule"
  network = google_compute_network.default.name
  allow {
    protocol = "icmp"
    ports = ["ALL"]
  }
###############some GKE examples ####################
  resource "google_container_cluster" "rule-to-enable-leagacy-abac" {
    name= "some-random"
    location="US"
	enable_legacy_abac = "true"
}

resource "google_container_node_pool" "expose-metadata" {
	node_config {
		workload_metadata_config {
			node_metadata = "EXPOSE"
		}
	}
}

resource "google_container_cluster" "metadata-leagacy-endpoints" {
	metadata {
    disable-legacy-endpoints = false
  }
}


resource "google_container_cluster" "exposing the username and password" {
	master_auth {
	    username = ""
	    password = ""
		client_certificate_config {
			issue_client_certificate = true
	    }
	}
}

resource "google_container_cluster" "disablesecuritypolicy" {
	pod_security_policy_config {
        enabled = "false"
	}
}
#############################################################
###########################iam example################
resource "google_project_iam_binding" "iam-role" {
	members = [
		"user:user@example.com",
		]
}


  
	destination_ranges = ["0.0.0.0/0"]
}