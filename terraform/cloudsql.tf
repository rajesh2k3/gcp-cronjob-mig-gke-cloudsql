

resource "google_project_service" "cloudsql_adminapi" {
  project                    = data.google_project.service_project.project_id
  service                    = "sqladmin.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "service_networking_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "servicenetworking.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "secret_manager_api" {
  project                    = data.google_project.service_project.project_id
  service                    = "secretmanager.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "random_id" "db_id" {
  byte_length           = 4
}

resource "google_sql_database_instance" "db" {
  // TODO: force SSL connections, and cloudsql auth proxy
  depends_on = [
    google_project_service.cloudsql_adminapi,
    google_project_service.service_networking_api,
  ]

  name                  = "db-${random_id.db_id.hex}" // TODO
  database_version      = "MYSQL_5_7"
  region                = var.region
  project               = data.google_project.service_project.project_id
  deletion_protection   = false

  settings {
    tier                = var.db_instance_type

    ip_configuration {
      ipv4_enabled      = true
      require_ssl       = true
    }

    dynamic "database_flags" {
      for_each = var.db_instance_flags
      content {
        name = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }
  }
}

resource "google_sql_database" "db" {
  name = "mydb"
  instance = google_sql_database_instance.db.name
  project               = data.google_project.service_project.project_id
}

resource "google_sql_user" "dbuser" {
    name = "dbuser"
    instance = google_sql_database_instance.db.name
    project               = data.google_project.service_project.project_id
    password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_project_iam_member" "wi_cloudsql_user" {
  count       = length(keys(var.workload_identity_map))
  project               = data.google_project.service_project.project_id
  role        = "roles/cloudsql.client"
  member      = format("serviceAccount:%s", element(google_service_account.wi_sa.*.email, count.index))
}

resource "google_secret_manager_secret" "db_creds" {
  depends_on = [
    google_project_service.secret_manager_api,
  ]
  secret_id = "mydb-credentials"
  project               = data.google_project.service_project.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "wi_secret_accessor" {
  count       = length(keys(var.workload_identity_map))
  secret_id   = google_secret_manager_secret.db_creds.id
  role        = "roles/secretmanager.secretAccessor"
  member      = format("serviceAccount:%s", element(google_service_account.wi_sa.*.email, count.index))
}

resource "google_secret_manager_secret_version" "db_creds" {
  secret = google_secret_manager_secret.db_creds.id

  // TODO: proxysql/clousql proxy sidecar for in-cluster connection pooling
  secret_data = random_password.db_password.result
}

