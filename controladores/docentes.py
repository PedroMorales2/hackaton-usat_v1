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
            return True
    except pymysql.MySQLError as e:
        print("Error al insertar el docente y vincularlo con el semestre:", e)
        con.rollback()
        return False
    finally:
        con.close()


def editar_docente(nombre, correo, telefono, contrasena, id_docente):
    con = conexion()  # Asegúrate de que esta función de conexión está bien implementada y devuelve una conexión válida.
    try:
        with con.cursor() as cursor:
            cursor.execute(
                "UPDATE docentes SET nombre=%s, correo=%s, telefono=%s, contrasena=%s WHERE id_docentes=%s",
                (nombre, correo, telefono, contrasena, id_docente)
            )
            con.commit()
            return True
    except pymysql.MySQLError as e:
        print("Error al editar el docente:", e)  # Asegúrate de que esto se está imprimiendo en un lugar visible
        con.rollback()
        return False
    finally:
        con.close()

def eliminar_docente(id_docente):
    con = conexion()  # Asegúrate de que esta función de conexión está bien implementada y devuelve una conexión válida.
    try:
        with con.cursor() as cursor:
            cursor.execute(
                "DELETE FROM docentes WHERE id_docentes=%s",
                (id_docente,)
            )
            con.commit()
            return True
    except pymysql.MySQLError as e:
        print("Error al eliminar el docente:", e)  # Asegúrate de que esto se está imprimiendo en un lugar visible
        con.rollback()
        return False
    finally:
        con.close()




    

