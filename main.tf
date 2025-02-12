provider "google" {
  credentials = file("key.json")  # GitHub Actions will inject this dynamically
  project     = "decisive-light-450717-k4"
  region      = "us-central1"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "default" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Open to all, restrict in production
}

resource "google_compute_instance" "vm_instance" {
  name         = "ubuntu-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }

  tags = ["ssh"]
}

output "instance_ip" {
  description = "Public IP of the instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
