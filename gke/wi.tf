data "google_service_account" "wi_sa" {
  for_each      = var.workload_identity_map
  project       = data.google_project.service_project.project_id
  account_id    = each.key
}

resource "google_service_account_iam_member" "wi_sa_role" {
  depends_on = [
    google_container_cluster.primary
  ]
  for_each            = var.workload_identity_map
  service_account_id  = data.google_service_account.wi_sa[each.key].name
  role                = "roles/iam.workloadIdentityUser"
  member              = format("serviceAccount:%s.svc.id.goog[%s]", 
                            data.google_project.service_project.project_id,
                            each.value)
}

resource "local_file" "k8s-sa" {
  for_each = var.workload_identity_map

  content = <<EOT
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    iam.gke.io/gcp-service-account: ${each.key}@${data.google_project.service_project.project_id}.iam.gserviceaccount.com
  name: ${element(split("/", each.value), 1)}
  namespace: ${element(split("/", each.value), 0)}
EOT
  filename = "${path.module}/generated/${each.key}-sa.yaml"
}

