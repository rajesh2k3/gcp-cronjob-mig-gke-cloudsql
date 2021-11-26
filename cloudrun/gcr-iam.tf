data "google_project" "registry_project" {
    project_id = var.registry_project_id
}

resource "google_storage_bucket_iam_member" "cloud_run_service_agent" {
    bucket = format("artifacts.%s.appspot.com", data.google_project.registry_project.project_id)
    role = "roles/storage.objectViewer"
    member = format("serviceAccount:service-%s@serverless-robot-prod.iam.gserviceaccount.com", data.google_project.service_project.number)
}

