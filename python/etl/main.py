import datetime
import pymysql.cursors
import os

db_host = os.getenv('DB_HOST', '127.0.0.1')
db_port = os.getenv('DB_PORT', 3306)
db_username = os.getenv('DB_USERNAME', 'dbuser')
db_password = os.getenv('DB_PASSWORD', 'dbpassword')
db_name = os.getenv('DB_NAME', 'employees')
db_socket = os.getenv('DB_SOCKET', None)


def write_users():
    connection = pymysql.connect(host=db_host,
                                user=db_username,
                                password=db_password,                             
                                db=db_name,
                                unix_socket=db_socket,
                                charset='utf8mb4',
                                cursorclass=pymysql.cursors.DictCursor) 

    print ("connect successful!!") 
    try:  
        with connection.cursor() as cursor: 
            print("Dropping LATEST_EMPLOYEES table ...")

            sql = "DROP TABLE IF EXISTS LATEST_EMPLOYEES"
            cursor.execute(sql) 

            print ("Creating LATEST_EMPLOYEES table ...")
            sql = """
            CREATE TABLE LATEST_EMPLOYEES 
            (
                emp_no int(11), 
                first_name VARCHAR(255), 
                last_name VARCHAR(255), 
                hire_date date
            )
            """

            cursor.execute(sql) 

            # SQL 
            sql = """INSERT INTO LATEST_EMPLOYEES (emp_no, first_name, last_name, hire_date) 
            SELECT emp_no, first_name, last_name, hire_date FROM employees 
            WHERE hire_date BETWEEN %s AND %s"""

            print(sql)

            hire_start = datetime.date(1999, 1, 1)
            hire_end = datetime.date(1999, 12, 31)

            # Execute query.
            retVal = cursor.execute(sql, (hire_start, hire_end)) 

            print("{0} rows inserted".format(retVal))

            """ 
            print ("cursor.description: ", cursor.description) 
            print() 
            for row in cursor:
                print(row) 
            """

        connection.commit()

    finally:
        # Close connection.
        connection.close()

    return ""


if __name__ == "__main__":
    write_users()