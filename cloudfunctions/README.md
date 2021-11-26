# cronjob in a cloud function

copy the function code from `../python/etl` into `../python/cloudfunctions`.  the `python/cloudfunction/main.py` wraps your code into what functions expects in a pubsub function, the `execute` method

```
cp -r ../python/etl/* ../python/cloudfunction/realcode
```

you may need to enable the cloud build api:

```
gcloud services enable cloudbuild.googleapis.com
```

Because functions terraform resources doesn't support secret manager integrations, we have to use the gcloud command line to deploy.  alternatively we could also trigger from source / cloud build.

```
export PROJECT_ID=<project id>
export CLOUDSQL_CONNECTION_NAME=<cloudsql connection name>
export SECRET_NAME=<secret name>
export REGION=<region>
export SERVICE_ACCOUNT_ID=etl-job
export FUNCTION_NAME=etl-function

gcloud beta functions deploy $FUNCTION_NAME \
--trigger-http \
--entry-point=execute \
--region ${REGION} \
--runtime python38 \
--service-account ${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com \
--no-allow-unauthenticated \
--set-env-vars DB_SOCKET=/cloudsql/${CLOUDSQL_CONNECTION_NAME} \
--set-secrets "DB_PASSWORD=${SECRET_NAME}:latest" \
--source ../python/cloudfunctions
```

NOTE: trigger from scheduler requires the function ingress settings be set to all, however we will force authentication so not just anybody can trigger our function.

then run terraform apply.  i used these vars:

```
service_project_id = "jkwng-cronjob-migration-dev"

job_service_account_id = "etl-job"
scheduler_service_account_id = "etl-cron-function"

function_name = "etl-function"
scheduler_job_name = "etl-cron-cloudfunction"
region = "us-central1"
```