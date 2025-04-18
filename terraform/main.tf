# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20"  # Allow v6.20.0 and newer patch versions
    }
  }
}

provider "google" {
  credentials = file(var.google_credentials)
  project     = var.project
  region      = var.region
}

# 1. Enable Compute Engine API
resource "google_project_service" "compute" {
  project = var.project
  service = var.compute_engine_api

  # Prevent disabling the API if resource is removed
  disable_on_destroy = var.is_api_disabled
}

# 2. Add SSH key to project metadata
resource "google_compute_project_metadata" "ssh_keys" {
  project = var.project

  metadata = {
    ssh-keys = <<-EOT
      ${var.ssh_username}:${file(var.public_key_path)}
      EOT
  }

  depends_on = [google_project_service.compute]
}

# 3. Create the Virtual Machine Server
resource "google_compute_instance" "dez-capstone-project-vm" {
   
  depends_on = [google_compute_project_metadata.ssh_keys] 

  boot_disk {
    auto_delete = var.is_auto_delete
    device_name = var.device_name

    initialize_params {
      image = var.OS_image
      size  = var.disk_size
      type  = var.disk_type
    }

    mode = var.storage_operational_mode
  }

  can_ip_forward      = var.can_ip_forward
  deletion_protection = var.is_deletion_protected
  enable_display      = var.is_display_enabled

  machine_type = var.machine_type
  name = var.machine_name

  network_interface {
    access_config {
      network_tier = var.network_tier
    }

    queue_count = var.queue_count
    stack_type  = var.stack_type
    subnetwork  = var.subnetwork
  }

  scheduling {
    automatic_restart   = var.schedule_automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.is_scheduling_preemptible
    provisioning_model  = var.provisioning_model
  }

  service_account {
    email  = var.service_account_email
    scopes = var.instance_scopes
  }

  shielded_instance_config {
    enable_integrity_monitoring = var.is_integrity_monitoring_enabled
    enable_secure_boot          = var.is_secure_boot_enabled
    enable_vtpm                 = var.is_vtpm_enabled
  }

  tags = var.firewall_tag # required for running Kestra from cloud.
  zone = var.zone
}

# 4. Create a Firewall rule for the VPC under the Project required for running Kestra from cloud(from inside the VM to be created above).
resource "google_compute_firewall" "kestra_firewall_rule" {
  depends_on = [google_compute_instance.dez-capstone-project-vm]

  name        = var.firewall_rule_name
  description = var.firewall_rule_description
  network     = var.firewall_rule_network
  direction   = var.firewall_rule_network_traffic_direction
  priority    = var.firewall_rule_priority

  allow {
    protocol = var.firewall_rule_allowed_protocol
    ports    = var.firewall_rule_allowed_ports
  }

  source_ranges = var.firewall_rule_source_ranges
  target_tags   = var.firewall_tag
}


# 5. Create a GSC bucket under the project
resource "google_storage_bucket" "auto-expire" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition {
      age = var.gcs_bucket_lifecycle_age
    }
    action {
      type = var.gcs_bucket_lifecycle_actiontype
    }
  }
}

# 6. Create a BigQuery dataset/schema under the project
resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id = var.bq_dataset_name
  location = var.region
}
