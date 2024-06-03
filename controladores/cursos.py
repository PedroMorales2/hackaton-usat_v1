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

