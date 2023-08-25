#Create a network 
resource google_compute_network "mynetwork" {
    name = "mynetwork"
# RESOURCE properties go here
auto_create_subnetworks = "true"
}

resource google_compute_firewall "mynetwork-allow-http-ssh-rdp-icmp" {
    name = "mynetwork-allow-http-ssh-rdp-icmp"
network = google_compute_network.mynetwork.self_link
allow{
    protocol = "icmp"
}
allow{
    protocol = "tcp"
    ports = ["80","22","3389"]
    }
source_ranges = ["0.0.0.0/0"]
}

module "mynet-us-vm" {
  source = "./instance"
  instance_name = "mynet-us-vm"
  instance_zone = "us-central1-c"
  instance_network = google_compute_network.mynetwork.self_link
}

module "mynet-eu-vm" {
  source = "./instance"
  instance_name = "mynet-us-vm"
  instance_zone = "europe-west1-c"
  instance_network = google_compute_network.mynetwork.self_link
}
