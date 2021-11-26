apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
stringData:
  db-username: dbuser
  db-password: ${DB_PASSWORD}
  db-name: employees
