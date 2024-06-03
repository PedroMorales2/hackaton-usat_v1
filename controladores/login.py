from controladores.bd import conexion

def login(correo, contrasena):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute("""SELECT * FROM docentes WHERE correo = %s AND contrasena = %s""", (correo, contrasena))
            return cursor.fetchone()  # Devuelve None si no hay resultados
    except Exception as e:
        print(f"Error en la función de login: {e}")
        return None  # Manejo de errores
    finally:
        con.close()  # Asegura que la conexión se cierra correctamente

    
def ver_docenteXID(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute("""SELECT * FROM docentes WHERE id = %s""", (id))
        docente = cursor.fetchone()
        return docente
