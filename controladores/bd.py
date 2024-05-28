import pymysql.cursors

# Connect to the database
def conexion():
    return pymysql.connect(host='localhost',
                             user='root',
                             password='',
                             database='hackaton_v1',
                             cursorclass=pymysql.cursors.DictCursor)