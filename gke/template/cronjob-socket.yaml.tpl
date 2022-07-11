apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: etl-5m
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          shareProcessNamespace: true
          containers:
          - name: etl
            // image: gcr.io/jkwng-images/cronjob-migration:latest
            image: gcr.io/ws9kiam-images/cronjob-migration:latest
            imagePullPolicy: Always
            command: ["/bin/bash"]
            args: 
            - -exc
            - |
              while [ ! -e /cloudsql/cloudsql.sock ]; do /bin/sleep 1; done
              python ./main.py
              pkill cloud_sql_proxy
              true
            env:
              - name: DB_SOCKET
                value: /cloudsql/cloudsql.sock
              - name: DB_NAME
                valueFrom:
                  secretKeyRef:
                    name: db-credentials
                    key: db-name
              - name: DB_USERNAME
                valueFrom:
                  secretKeyRef:
                    name: db-credentials
                    key: db-username
              - name: DB_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: db-credentials
                    key: db-password
            volumeMounts:
            - name: proxy-socket
              mountPath: /cloudsql
          - name: cloud-sql-proxy
            # It is recommended to use the latest version of the Cloud SQL proxy
            # Make sure to update on a regular schedule!
            # image: gcr.io/cloudsql-docker/gce-proxy:1.17
            image: gcr.io/cloudsql-docker/gce-proxy:1.28.0
            command:
            - "/cloud_sql_proxy"
            - "-dir=/cloudsql"
            - "-instances=${CLOUDSQL_CONNECTION_NAME}=unix:/cloudsql/cloudsql.sock"
            securityContext:
              runAsNonRoot: true
            volumeMounts:
            - name: proxy-socket
              mountPath: /cloudsql
          restartPolicy: OnFailure
          serviceAccountName: etl-job
          volumes:
          - name: proxy-socket
            emptyDir: {}
