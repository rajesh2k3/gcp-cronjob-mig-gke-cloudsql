resource "google_project_organization_policy" "allowed_ingress" {
  project    = data.google_project.service_project.project_id
  constraint = "constraints/cloudfunctions.allowedIngressSettings"

  list_policy {
    allow {
      all = true
    }
  }
}