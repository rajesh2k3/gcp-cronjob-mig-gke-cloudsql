variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}

variable "registry_project_id" {
  description = "The project ID of where the images are stored"
}

variable "create_app_engine_app" {
  default = false
}

variable "job_service_account_id" { }
variable "scheduler_service_account_id" { }

variable "scheduler_job_name" {
  default = "etl-cron-cloudrun"
}

variable "cloudrun_service_name" {
  default = "etl-job"
}


variable "region" {
  default = "us-central1"
}

variable "cloudsql_instance_name" {

}

variable "db_password_secret" {
  
}