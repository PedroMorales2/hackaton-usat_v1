from controladores.bd import conexion


def listar():
    con = conexion()
    try:
        cursor = con.cursor()
        cursor.execute("SELECT * FROM curso")
        cursos = cursor.fetchall()
        return cursos
    except Exception as e:
        print("Error al listar cursos:", e)
        return None
    finally:
        cursor.close()
        
def buscar(id):
    con = conexion()
    try:
        cursor = con.cursor()
        cursor.execute("SELECT * FROM curso WHERE idCurso = %s", (id,))
        curso = cursor.fetchone()
        return curso
    except Exception as e:
        print("Error al buscar curso:", e)
        return None
    finally:
        cursor.close()
   
def insertarCurso(nombre):
   con = conexion()
   try:
        cursor = con.cursor()
        cursor.execute("INSERT INTO curso (nombre_curso) VALUES (%s)", (nombre,))
        con.commit()
   except Exception as e:
        print("Error al insertar curso:", e)
   finally:
        cursor.close()

def actualizarCurso(id, nombre):
    con = conexion()
    try:
        cursor = con.cursor()
        cursor.execute("UPDATE curso SET nombre_curso = %s WHERE idCurso = %s", (nombre, id))
        con.commit()
    except Exception as e:
        print("Error al actualizar curso:", e)
    finally:
        cursor.close()

def eliminarCurso(id):
    con = conexion()
    try:
        cursor = con.cursor()
        cursor.execute("DELETE FROM curso WHERE idCurso = %s", (id,))
        con.commit()
    except Exception as e:
        print("Error al eliminar curso:", e)
    finally:
        cursor.close()
        
def editarCursos(denominacion, id):
    con = conexion()
    try:
        with con.cursor() as cursor:
            # Corrige la consulta SQL para usar marcadores de posición correctamente
            sql = "UPDATE `grupos` SET `denominacion`=%s WHERE `idGrupo`=%s"
            cursor.execute(sql, (denominacion, id))
            con.commit()
            return True  # Añade un retorno para confirmar la actualización exitosa
    except Exception as e:
        print("Error al actualizar curso:", e)
        return False  # Retorna False si hay un error
    finally:
        con.close()  # Asegúrate de cerrar la conexión


