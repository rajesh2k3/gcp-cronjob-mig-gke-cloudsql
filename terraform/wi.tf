resource "google_service_account" "wi_sa" {
  count         = length(keys(var.workload_identity_map))
  project       = data.google_project.service_project.project_id
  account_id    = element(keys(var.workload_identity_map), count.index)
  display_name  = format("workload identity %s service account", element(keys(var.workload_identity_map), count.index))
}

