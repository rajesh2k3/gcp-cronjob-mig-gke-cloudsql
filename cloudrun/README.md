# cronjob in a cloud run service

copy the function code from `../python/etl` into `../python/cloudrun/realcode`.  the `python/cloudrun/main.py` wraps your code into into what cloud run expects, which is to respond to an http request.

```
cp -r ../python/etl/* ../python/cloudrun/realcode
```

build and push the container image to the registry.
then run terraform apply.  i used these params

```
service_project_id = "jkwng-cloudrun-migration-dev"
registry_project_id = "jkwng-images"

job_service_account_id = "etl-job"
scheduler_service_account_id = "etl-cloudrun-sched"

scheduler_job_name = "etl-cron-cloudrun"
region = "us-central1"
cloudsql_instance_name = "db-1e1b079a"
db_password_secret = "mydb-credentials"
```

note: sometimes i noticed cloudsql doesn't get connected properly after cloud run service is created, just go to the service -> edit -> connections and add the cloud sql connection manually.