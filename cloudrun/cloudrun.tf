data "google_sql_database_instance" "db" {
  name       = var.cloudsql_instance_name
  project    = data.google_project.service_project.project_id
}

data "google_service_account" "cloudrun_sa" {
  project = data.google_project.service_project.project_id
  account_id = var.job_service_account_id
}

data "google_secret_manager_secret_version" "secret" {
  secret = var.db_password_secret
  project    = data.google_project.service_project.project_id
}

# IAM entry for all users to invoke the function
resource "google_cloud_run_service_iam_member" "invoker" {
  project        = data.google_project.service_project.project_id
  service        = google_cloud_run_service.job.name
  location       = google_cloud_run_service.job.location

  role   = "roles/run.invoker"
  member = format("serviceAccount:%s", google_service_account.scheduler_sa.email)
}

resource "google_cloud_run_service" "job" {
  provider = google-beta
  project  = data.google_project.service_project.project_id
  name     = var.cloudrun_service_name
  location = var.region

  template {
    spec {
      containers {
        image = format("gcr.io/%s/cronjob-migration-cloudrun:latest", data.google_project.registry_project.project_id)
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = "mydb-credentials"
              key = "latest"
            }
          }
        }
        env {
          name = "DB_SOCKET"
          value = format("/cloudsql/%s", data.google_sql_database_instance.db.connection_name)
        }
      }
      service_account_name = data.google_service_account.cloudrun_sa.email
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = data.google_sql_database_instance.db.connection_name
        "run.googleapis.com/secrets" = format("mydb-credentials:%s", replace(data.google_secret_manager_secret_version.secret.name, "//versions/.*/", ""))
      }
    }

  }

  traffic {
    percent         = 100
    latest_revision = true
  }


  autogenerate_revision_name = true

}

/*
data "google_iam_policy" "auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  project    = module.service_project.project_id
  depends_on = [
  ]

  location    = google_cloud_run_service.job.location
  service     = google_cloud_run_service.job.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
*/