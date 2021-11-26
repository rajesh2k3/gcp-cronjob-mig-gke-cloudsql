data "google_project" "registry_project" {
    project_id = var.registry_project_id
}

resource "google_storage_bucket_iam_member" "gke_node_service_agent" {
    bucket = format("artifacts.%s.appspot.com", data.google_project.registry_project.project_id)
    role = "roles/storage.objectViewer"
    member = format("serviceAccount:%s", google_service_account.gke_sa.email)
}