from controladores.bd import conexion
 
 
 
def listar():
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute("""SELECT doce.* FROM docente_semestre dos
                            INNER JOIN docentes doce ON dos.id_docentes = doce.id_docentes
                            INNER JOIN semestre_academico sem ON sem.id_semestre = dos.id_semestre
                            WHERE sem.vigencia = 1""")
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







    

