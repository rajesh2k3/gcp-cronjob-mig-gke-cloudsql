resource "google_service_account" "scheduler_sa" {
  project = data.google_project.service_project.project_id
  account_id = var.scheduler_service_account_id
}

resource "google_cloud_scheduler_job" "job" {
  depends_on = [
    google_project_service.appengine_api,
    google_app_engine_application.app,
  ]
  name        = var.scheduler_job_name
  region      = var.region
  project     = data.google_project.service_project.project_id
  schedule    = "*/5 * * * *"
  time_zone   = "America/Toronto"

  http_target {
    http_method = "POST"
    uri         = data.google_cloudfunctions_function.function.https_trigger_url
    body        = base64encode("{}")

    oidc_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}

resource "google_app_engine_application" "app" {
  count = var.create_app_engine_app ? 1 : 0
  location_id = "us-central"
  project = data.google_project.service_project.project_id

}