data "google_project" "service_project" {
  project_id = var.service_project_id
}

resource "google_project_service" "cloudrun_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "run.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}