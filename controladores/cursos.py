from controladores.bd import conexion

con = conexion()

def listar():
    cursor = con.cursor()
    cursor.execute("SELECT * FROM curso")
    cursos = cursor.fetchall()
    cursor.close()
    return cursos