variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. dev-55427"
}

variable "job_service_account_id" {}
variable "scheduler_service_account_id" {
  default = "etl-cron-functions"
}

variable "function_name" {
  default = "etl-function"
}

variable "region" {
  default = "us-central1"
}

variable "scheduler_job_name" {
  default = "etl-cron-functions"
}

variable "create_app_engine_app" {
  default = false
}