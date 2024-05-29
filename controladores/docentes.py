from controladores.bd import conexion
    


def listar():
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM docentes')
        return cursor.fetchall()
    
def insertarDocente(nombre, apellido, correo, dedicacion,telefono):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('INSERT INTO docentes (nombre, apellido, correo, dedicacion, telefono) VALUES (%s, %s, %s, %s, %s)', 
                           (nombre, apellido, correo, dedicacion, telefono))
            con.commit()
    except Exception as e:
        print("Error al insertar docente:", e)
        con.rollback() 
        
