from controladores.bd import conexion
    


def listar():
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM docentes')
        return cursor.fetchall()
    
import pymysql

def insertarDocente(semestre, nombre, apellido, correo, dedicacion, telefono, horas_asesoria):
    con = conexion()  # Asume que esta función correctamente configura y devuelve una conexión a la base de datos
    try:
        with con.cursor() as cursor:
            cursor.callproc('insertar_docente', (semestre, nombre, apellido, correo, dedicacion, telefono, horas_asesoria))
            con.commit()
    except pymysql.MySQLError as e:
        print("Error al insertar el docente y vincularlo con el semestre:", e)
        con.rollback()
    finally:
        con.close()







    

