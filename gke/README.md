# cronjob in gke

build the code in `../python/etl` into a container image and push it to the registry.

create a service project and subnet to use.

then run terraform apply.  to create a gke cluster and generate the yamls for the job.  i used these params

```
shared_vpc_host_project_id = "jkwng-nonprod-vpc"
shared_vpc_network = "shared-vpc-nonprod-1"

service_project_id = "jkwng-cronjob-migration-dev"
registry_project_id = "jkwng-images"

subnet_name = "cronjob-migration"
subnet_region = "us-central1"
subnet_pods_range_name = "pods"
subnet_services_range_name = "services"

gke_clusters = [
  {
    name = "clust1"
    master_range = "10.0.6.0/28"
    region = "us-central1",
    private_cluster = true,
    default_nodepool_machine_type = "e2-medium",
    default_nodepool_initial_size = 1,
    default_nodepool_min_size = 0,
    default_nodepool_max_size = 3,
    use_preemptible_nodes = true,
  },
]

db_instance_name = "db-2dbf2db9"
db_password_secret =  "mydb-credentials"

workload_identity_map = {
  "etl-job" = "default/etl-job"
}

```

If you want to look at the sample yamls, it's in the [generated](./generated) directory.