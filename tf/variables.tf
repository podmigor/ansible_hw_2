variable "project" {
  default = "hillel-project-1"
}

variable "zone" {
  default = "europe-west1-b"
}

variable "region" {
  default = "europe-west1"
}

variable "credentials" {
  default = "../../../gcp_keys/hillel-project-1-e39e275fb220.json"
}

variable "subnet_cidr" {
  default = "10.10.10.0/24"
}

variable "user" {
  default = "user"
}

variable "ssh_pub_key" {
  default = "../../../.ssh/id_rsa.pub"
}

variable "network_name" {
  default = "ansible"
}

//Added vars
variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "e2-micro"
}

variable "instance_image" {
  description = "Instance image"
  type        = string
  default     = "debian-10-buster-v20220317"
}

variable "subnet_name" {
  description = "VPC Subnet name"
  type        = string
  default     = "subnet-01"
}