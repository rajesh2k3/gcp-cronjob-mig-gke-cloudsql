data "google_project" "service_project" {
  project_id = var.service_project_id
}

resource "google_project_service" "functions_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "cloudfunctions.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "scheduler_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "cloudscheduler.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "appengine_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "appengine.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "cloudbuild_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "cloudbuild.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}