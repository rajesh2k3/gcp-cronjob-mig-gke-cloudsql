variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC e.g. shared-vpc-host-project-55427"
}


variable "workload_identity_map" {
  type = map(any)
  default = {}
}

variable "region" {
  default = "us-central1"
}

variable "db_instance_type" {
  default = "db-g1-small"
}

variable "db_instance_flags" {
  type = list(object({
    name=string
    value=string
  }))
}
