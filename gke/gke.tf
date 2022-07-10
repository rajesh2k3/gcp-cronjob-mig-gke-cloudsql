locals {
  gke_sa_roles = [
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/monitoring.viewer",
  ]

  gke_default_cluster = {
    // name = ""
    name = "gke-cluster-ws9kiam-dev"
    master_range = ""
    private_cluster = true,
    default_nodepool_machine_type = "e2-medium",
    default_nodepool_initial_size = 1,
    default_nodepool_min_size = 0,
    default_nodepool_max_size = 3,
    use_preemptible_nodes = true,
  }
} 



resource "google_service_account" "gke_sa" {
  project    = data.google_project.service_project.project_id
  account_id    = "node-sa"
  display_name  = "cluster node service account"
}

resource "google_project_iam_member" "gke_sa_role" {
  count     = length(local.gke_sa_roles)

  project   = data.google_project.service_project.project_id
  role      = element(local.gke_sa_roles, count.index)
  member    = format("serviceAccount:%s", google_service_account.gke_sa.email)
}

resource "google_container_cluster" "primary" {
  for_each = zipmap(var.gke_clusters.*.name, var.gke_clusters)
  provider = google-beta

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      node_config,
    ]
  }

  depends_on = [
    google_project_iam_member.gke_sa_role,
    google_project_organization_policy.shielded_vm_disable,
    google_project_organization_policy.oslogin_disable,
    google_compute_subnetwork_iam_binding.subnet_user,
    google_compute_shared_vpc_service_project.shared_vpc_attachment,
  ]

  name     = each.value.name
  location = var.subnet_region
  project   = data.google_project.service_project.project_id

  release_channel  {
    channel = "REGULAR"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    enable_private_nodes = each.value.private_cluster     # nodes have private IPs only
    enable_private_endpoint = false  # master nodes private IP only
    master_ipv4_cidr_block = each.value.master_range
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "eerbody"
    }
  }

  network = data.google_compute_network.shared_vpc.self_link
  subnetwork = data.google_compute_subnetwork.subnet.self_link

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name = var.subnet_pods_range_name
    services_secondary_range_name = var.subnet_services_range_name
  }

  workload_identity_config {
    identity_namespace = "${data.google_project.service_project.project_id}.svc.id.goog"
  }

  cluster_autoscaling {
    enabled = false # this settings is for nodepool autoprovisioning
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  for_each = zipmap(var.gke_clusters.*.name, var.gke_clusters)

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }

  depends_on = [
    google_container_cluster.primary,
  ]

  name       = format("%s-default-pvm", each.value.name)
  location   = var.subnet_region
  cluster    = each.value.name
  node_count = lookup(zipmap(var.gke_clusters.*.name, var.gke_clusters), each.value.name, local.gke_default_cluster).default_nodepool_initial_size
  project    = data.google_project.service_project.project_id

  autoscaling {
    min_node_count = lookup(zipmap(var.gke_clusters.*.name, var.gke_clusters), each.value.name, local.gke_default_cluster).default_nodepool_min_size
    max_node_count = lookup(zipmap(var.gke_clusters.*.name, var.gke_clusters), each.value.name, local.gke_default_cluster).default_nodepool_max_size
  }

  node_config {
    preemptible  = lookup(zipmap(var.gke_clusters.*.name, var.gke_clusters), each.value.name, local.gke_default_cluster).use_preemptible_nodes
    machine_type = lookup(zipmap(var.gke_clusters.*.name, var.gke_clusters), each.value.name, local.gke_default_cluster).default_nodepool_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


