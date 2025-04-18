variable "project" {
  description = "GCP project ID"
   default     = "dez-capstone-project1" # update it with your desired value
}

variable "region" {
  description = "GCP region"
  default     = "us-central1" # update it with your desired value
}

variable "zone" {
  description = "which zone of the region"
  default = "us-central1-b"  # update it with your desired value
}

variable "google_credentials" {
  description = "Service account credentials"
  default     = "../.secrets/my-creds.json" # update it with your value
}

variable "public_key_path" {
  description = "Path to SSH public key the content of which is to be input to Metadata under Compute Engine under the Project"
  default     = "../.secrets/gcp.pub"  # update it with your value
}

variable "ssh_username" {
  description = "Username for SSH access"
  default     = "sidd4ml"  # update it with your value
}

variable "instance_scopes" {
  description = "Scopes for the instance's service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "compute_engine_api" {
  description = "name of the google compute engine api"
  default = "compute.googleapis.com"
}

variable "is_api_disabled" {
  description = "should the compute engine api be disabled on terraform destroy"
  default = true
}

variable "is_auto_delete" {
  description = "should the VM storage be auto deleted with deletion of the VM"
  default = true
}

variable "device_name" {
    description = "Device name of the VM"       
    default = "dez-capstone-project-device"  # update it with your desired value
}

variable "OS_image" {
  description = "Which Operating System the VM will run"
  default =  "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250312"    # update it with your desired value
}

variable "disk_size"{
    description = "size of the storage for the VM"
    default = 100   # update it with your desired value                 
}

variable "disk_type" {
  description = "type of the storage for the VM"
  default = "pd-ssd"  # update it with your desired value
}

variable "storage_operational_mode" {
  description = "operational mode of the storage for the VM"
  default = "READ_WRITE"  
}

variable "can_ip_forward" {
  description = "is IP forwarding enabled in the VM"
  default = false
}

variable "is_deletion_protected" {
  description = "is it deletion protected"
  default = false
}

variable "is_display_enabled" {
  description = "is display enabled"
  default = false
}

variable "machine_type" {
  description = "the category and type of the VM server as per the compute resources"
  default = "e2-standard-8"   # update it with your desired value
}

variable "machine_name" {
  description = "name of the vm server which shall display and we use this name to connect with ssh"
  default = "dez-capstone-project-vm"     # update it with your desired value
}

variable "network_tier" {
  description = "type of network tier"
  default = "PREMIUM"
}

variable "queue_count" {
  description = "value of queue count"
  default = 0
}

variable "stack_type" {
  description = "type of stack"
  default = "IPV4_ONLY"
}

variable "subnetwork" {
  description = "GCP's default network"
  default = "projects/dez-capstone-project1/regions/us-central1/subnetworks/default"  # update it with your value
}

variable "schedule_automatic_restart" {
  description = "should instance be automatically restarting if terminated by Compute Engine"
  default = true
}

variable "on_host_maintenance" {
  description = "This parameter specifies the behavior of the instance during host maintenance events. Valid values are MIGRATE and TERMINATE"
  default = "MIGRATE"
}

variable "is_scheduling_preemptible" {
  description = "whether the instance is preemptible. Preemptible instances are short-lived and can be terminated by Compute Engine at any time. "
  default = false
}

variable "provisioning_model" {
  description = "This parameter specifies the provisioning model of the instance. The value STANDARD indicates that the instance uses standard provisioning."
  default = "STANDARD"
}

variable "service_account_email" {
  description = "what is the service account email. It also happens to be the name of the Principal"
  default = "cap-proj1-svc-acct@dez-capstone-project1.iam.gserviceaccount.com"    # update it with your value
}

variable "is_integrity_monitoring_enabled" {
  description = "When set to true, this option monitors the integrity of the boot and kernel processes, alerting you to any changes that could indicate a compromise."
  default = true
}

variable "is_secure_boot_enabled" {
  description = "This helps prevent malicious code from running during the boot sequence"
  default = false
}

variable "is_vtpm_enabled" {
  description = "Enabling this parameter provides a virtual Trusted Platform Module (vTPM), which offers hardware-based security functionalities such as key generation and storage, enhancing the overall security posture of your instance."
  default = true
}

variable "firewall_tag" {
  description = "for creation of firewall rule with target as https-server. This is needed for running Kestra from cloud"
  type = list(string)
  default = ["https-server"]
}

variable "firewall_rule_name" {
  description = "name of the firewall rule"
  default = "kestra-firewall-rule"         # update with your value
}

variable "firewall_rule_description" {
  description = "description of the firewall rule."
  default = "to allow Kestra to run from port 8080"
}

variable "firewall_rule_network" {
  description = "network for creation of firewall rule."
  default = "default"
}

variable "firewall_rule_network_traffic_direction" {
  description = "network traffic direction for creation of firewall rule."
  default = "INGRESS"
}

variable "firewall_rule_priority" {
  description = "priority number for creation of firewall rule."
  default = 1000
}

variable "firewall_rule_allowed_protocol" {
  description = "for creation of firewall rule with allowed protocol."
  default = "tcp"
}

variable "firewall_rule_allowed_ports" {
  description = "for creation of firewall rule with allowed ports."
  type = list(string)
  default = ["8080"]
}

variable "firewall_rule_source_ranges" {
  description = "for creation of firewall rule with allowed IP ranges."
  type = list(string)
  default = ["0.0.0.0/0"]
}


variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "air_quality_assam_dataset"      # update it with your value
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "air-quality-assam-bucket"     # update it with your value
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

variable "gcs_bucket_lifecycle_age" {
  description = "This sets the threshold for the rule. The value age = 1 means that if a multipart upload has been in progress (but not completed) for one day (1 day), then the condition is met."
  default = 1
}

variable "gcs_bucket_lifecycle_actiontype" {
  description = "When the condition is met (i.e., the incomplete upload is older than 1 day), this action is triggered."
  default = "AbortIncompleteMultipartUpload"
}