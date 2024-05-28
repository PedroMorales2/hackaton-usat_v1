from bd import conexion

con = conexion()

def listar():
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM docentes')
        return cursor.fetchall()
    
def insertarDocente(semestre_id,nombre, apellido, correo, dedicacion,telefono, hora_asesoria):
    with con.cursor() as cursor:
        cursor.execute('INSERT INTO docentes (semestre_id,nombre, apellido, correo, dedicacion, telefono, hora_asesoria) VALUES (%s,%s, %s, %s, %s, %s, %s)', (semestre_id,nombre, apellido, correo, dedicacion, telefono, hora_asesoria))
        con.commit()
        
