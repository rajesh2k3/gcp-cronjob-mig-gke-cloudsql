data "google_cloudfunctions_function" "function" {
  project     = data.google_project.service_project.project_id
  region      = var.region
  name        = var.function_name
}

data "google_service_account" "function_sa" {
  project = data.google_project.service_project.project_id
  account_id = var.job_service_account_id
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = data.google_project.service_project.project_id
  region         = data.google_cloudfunctions_function.function.region
  cloud_function = data.google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = format("serviceAccount:%s", google_service_account.scheduler_sa.email)
}
