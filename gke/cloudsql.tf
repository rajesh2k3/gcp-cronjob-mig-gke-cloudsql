data "google_sql_database_instance" "db" {
  project    = data.google_project.service_project.project_id
  name = var.cloudsql_instance_name
}

data "google_secret_manager_secret_version" "dbsecret" {
  project   = data.google_project.service_project.project_id
  secret    = var.db_password_secret


}

resource "local_file" "k8s-cronjob" {
  content =  templatefile("${path.module}/template/cronjob-socket.yaml.tpl",
    {
      CLOUDSQL_CONNECTION_NAME = data.google_sql_database_instance.db.connection_name
    }
  )
  filename = "${path.module}/generated/cronjob.yaml"
}

resource "local_file" "k8s-secret" {
  content =  templatefile("${path.module}/template/secret.yaml.tpl",
    {
      DB_PASSWORD = data.google_secret_manager_secret_version.dbsecret.secret_data
    }
  )
  filename = "${path.module}/generated/secret.yaml"
}