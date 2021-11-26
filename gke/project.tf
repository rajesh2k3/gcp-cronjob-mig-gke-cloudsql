data "google_project" "host_project" {
  project_id = var.shared_vpc_host_project_id
}

data "google_compute_network" "shared_vpc" {
  name    =  var.shared_vpc_network
  project = data.google_project.host_project.project_id
}

data "google_project" "service_project" {
  project_id = var.service_project_id
}

data "google_compute_subnetwork" "subnet" {
  name      = var.subnet_name
  project   = data.google_project.host_project.project_id
  region    = var.subnet_region
}

resource "google_project_service" "container_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "container.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_compute_shared_vpc_service_project" "shared_vpc_attachment" {
  host_project    = data.google_project.host_project.project_id
  service_project = data.google_project.service_project.project_id
}

resource "google_compute_subnetwork_iam_binding" "subnet_user" {
  project     = data.google_project.host_project.project_id
  region      = var.subnet_region
  role        = "roles/compute.networkUser"
  subnetwork  = data.google_compute_subnetwork.subnet.name
  members     = [
    format("serviceAccount:service-%d@container-engine-robot.iam.gserviceaccount.com", data.google_project.service_project.number),
    format("serviceAccount:%d@cloudservices.gserviceaccount.com", data.google_project.service_project.number),
  ]
}

resource "google_project_iam_member" "gkeHostServiceAgentUser" {
  project     = data.google_project.host_project.project_id
  role        = "roles/container.hostServiceAgentUser"
  member      = format("serviceAccount:service-%d@container-engine-robot.iam.gserviceaccount.com", data.google_project.service_project.number)
}