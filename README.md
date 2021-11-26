# cronjob-migration

## create project

run the base terraform in [terraform](./terraform) directory, creates:
- cloud sql instance 
- database
- password stored in secret manager (username is `dbuser`)
- service account that can access the secret and connect to the database


## load data into testdb

connect using the [cloud_sql_proxy](https://cloud.google.com/sql/docs/mysql/quickstart-proxy-test#linux-64-bit):

```
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy
```

if there's only one db, and you've configured the project using `gcloud`, you're inside GCP, and your user has access to list db instances, you can usually just run the cloud sql proxy and it will autodiscover things for you.  just set the socket dir to `/tmp`:

```
gcloud config set project <PROJECT_ID>
./cloud_sql_proxy -dir /tmp
```

you can connect to mysql now.  get the password:
```
gcloud secrets versions access  --secret=mydb-credentials latest
```

then connect and load the data (enter password at the prompt).  this creates the `employees` database
```
cd test_db
mysql -S /tmp/<cloudsql connection name> -u dbuser -p < ./employees.sql
```


