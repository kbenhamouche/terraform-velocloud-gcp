// Create VPC
resource "google_compute_network" "vcn_demo_public_vpc" {
    name = "vcn-demo-public-vpc"
    auto_create_subnetworks = "false"
    routing_mode = "REGIONAL"
}

resource "google_compute_network" "vcn_demo_private_vpc" {
    name = "vcn-demo-private-vpc"
    auto_create_subnetworks = "false"
    routing_mode = "REGIONAL"
}

resource "google_compute_network" "vcn_demo_mngt_vpc" {
    name = "vcn-demo-mngt-vpc"
    auto_create_subnetworks = "false"
    routing_mode = "REGIONAL"
}

// Create Subnets
resource "google_compute_subnetwork" "vcn_public_sn" {
    name          = "vcn-public-sn"
    ip_cidr_range = var.public_sn_cidr_block
    network       = google_compute_network.vcn_demo_public_vpc.id
    depends_on    = ["google_compute_network.vcn_demo_public_vpc"]
    region = var.gcp_region
}

resource "google_compute_subnetwork" "vcn_private_sn" {
    name          = "vcn-private-sn"
    ip_cidr_range = var.private_sn_cidr_block
    network       = google_compute_network.vcn_demo_private_vpc.id
    depends_on    = ["google_compute_network.vcn_demo_private_vpc"]
    region = var.gcp_region 
}

resource "google_compute_subnetwork" "vcn_mngt_sn" {
    name          = "vcn-mngt-sn"
    ip_cidr_range = var.mngt_sn_cidr_block
    network       = google_compute_network.vcn_demo_mngt_vpc.id
    depends_on    = ["google_compute_network.vcn_demo_mngt_vpc"]
    region = var.gcp_region 
}

// FW rules
resource "google_compute_firewall" "public_fw_rules" {
    name = "public-fw-rules"
    network = google_compute_network.vcn_demo_public_vpc.id
    allow { //SSH
        protocol = "tcp"
        ports = ["22"]
    }
    allow { //VCMP
        protocol = "udp"
        ports = ["2426"]
    }
    allow { //ICMP
        protocol = "icmp"
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "private_fw_rules" {
    name = "private-fw-rules"
    network = google_compute_network.vcn_demo_private_vpc.id
    allow { //ALL
        protocol = "all"
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "mngt_fw_rules" {
    name = "mngt-fw-rules"
    network = google_compute_network.vcn_demo_mngt_vpc.id
    allow { //SSH
        protocol = "tcp"
        ports = ["22"]
    }
    allow { //ICMP
        protocol = "icmp"
    }
    source_ranges = ["0.0.0.0/0"]
}

// Key pair creation
resource "tls_private_key" "velo-key" {
  algorithm = "RSA"
}

// Create the instance
resource "google_compute_instance" "vce_instance" { 
    name = "vce" 
    machine_type = var.instance_type
    can_ip_forward = true
    boot_disk {
        initialize_params {
            image = "https://www.googleapis.com/compute/v1/projects/vmware-sdwan-public/global/images/vce-342-102-r342-20200610-ga-3f5ad3b9e2"
            } 
    }
    metadata = {
        user-data = file("cloud-init")
        //user-data = "#cloud-config\n velocloud:\n vce:\n vco: vco12-usvi1.velocloud.net\n activation_code: 2CMR-Y8AL-TJ73-TYRH\n vco_ignore_cert_errors: true\n"
        ssh-keys = tls_private_key.velo-key.public_key_openssh
    }
    // GE1 interface
    network_interface {
        subnetwork = google_compute_subnetwork.vcn_mngt_sn.id
    }
    // GE2 interface
    network_interface {
        subnetwork = google_compute_subnetwork.vcn_public_sn.id
        access_config {
            //Ephemeral IP
        } 
    }
    // GE3 interface
    network_interface { 
        subnetwork = google_compute_subnetwork.vcn_private_sn.id
        network_ip = var.private_ip
    }
}

// Static route for branch (example)
resource "google_compute_route" "branch_route" {
  name        = "branch-route"
  dest_range  = "10.5.99.0/24"
  network     = google_compute_network.vcn_demo_private_vpc.id
  depends_on    = ["google_compute_subnetwork.vcn_private_sn"]
  next_hop_ip = var.private_ip
  priority    = 100
}