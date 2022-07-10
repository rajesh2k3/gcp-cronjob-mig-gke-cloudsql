apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
stringData:
  // db-username: dbuser
  db-username: cirrus
  db-password: ${DB_PASSWORD}
  // db-name: employees
  db-name: ws9kiam-db
  
