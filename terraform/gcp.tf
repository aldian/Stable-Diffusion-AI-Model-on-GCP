provider "google" {
  project = var.gcp_project_id
  zone    = var.gcp_zone
}

resource "google_compute_address" "ip_address" {
  name = "${var.app_name}-ip"
}

data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["allow-http"]
}

data "google_compute_image" "cos_image" {
  family  = "cos-101-lts"
  project = "cos-cloud"
}

resource "google_compute_instance" "instance" {
  name         = "${var.app_name}-vm"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = google_compute_firewall.allow_http.target_tags

  metadata = {
    user-data = "${file("../user_data.yaml")}"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos_image.self_link
      size  = 100
    }
  }

  scratch_disk {
    interface = "SCSI"
  }

  guest_accelerator {
    count = 1
    type  = var.gpu_type
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }

  service_account {
    email  = "${var.gcp_project_number}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"
    ]
  }
}
