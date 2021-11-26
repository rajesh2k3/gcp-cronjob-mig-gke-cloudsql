variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC e.g. shared-vpc-host-project-55427"
}

variable "registry_project_id" {
}

variable "shared_vpc_network" {
  description = "The ID of the shared VPC e.g. shared-network"
}

variable "gke_clusters" {
  type = list(object({
    name=string,
    master_range=string,
    private_cluster=bool,
    default_nodepool_machine_type=string,
    default_nodepool_initial_size=number,
    default_nodepool_min_size=number,
    default_nodepool_max_size=number,
    use_preemptible_nodes=bool,
  }))

  default = []
}

variable "subnet_name" {}
variable "subnet_region" {}
variable "subnet_pods_range_name" {}
variable "subnet_services_range_name" {}

variable "workload_identity_map" {
  type = map(any)
  default = {}
}


variable "cloudsql_instance_name" {}

variable "db_password_secret" {}