from controladores.bd import conexion
    


def listar():
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM docentes')
        lista = cursor.fetchall()
        return lista
    
import pymysql

def insertarDocente(semestre, nombre,  correo, dedicacion, telefono, horas_asesoria):
    con = conexion()  
    try:
        with con.cursor() as cursor:
            cursor.callproc('insertar_docente', (semestre, nombre, correo, dedicacion, telefono, horas_asesoria))
            con.commit()
    except pymysql.MySQLError as e:
        print("Error al insertar el docente y vincularlo con el semestre:", e)
        con.rollback()
    finally:
        con.close()







    

