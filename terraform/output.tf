output "db_ip" {
  value = google_sql_database_instance.db.first_ip_address
}

output "db_port" {
  value = 3306
}

output "db_username" {
    value = google_sql_user.dbuser.name
}

output "db_password" {
    value = random_password.db_password.result
    sensitive = true
}

output "db_password_secret_version" {
    value = google_secret_manager_secret_version.db_creds.name
}

output "db_connection_string" {
    value = google_sql_database_instance.db.connection_name
}

output "db_name" {
  value = google_sql_database.db.name
}

output "db_instance_name" {
    value = google_sql_database_instance.db.name
}