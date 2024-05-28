from bd import conexion

con = conexion()

def listar():
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre')
        return cursor.fetchall()

def insertarSemestre(nombre, fecha_inicio, fecha_fin, vigencia):
    with con.cursor() as cursor:
        cursor.execute('INSERT INTO semestre (nombre, fecha_inicio, fecha_fin, vigencia) VALUES (%s, %s, %s, %s)', (nombre, fecha_inicio, fecha_fin, vigencia))
        con.commit()

def eliminarSemestre(id):
    with con.cursor() as cursor:
        cursor.execute('DELETE FROM semestre WHERE id = %s', (id))
        con.commit()
        
def editarSemestre(id, nombre, fecha_inicio, fecha_fin, vigencia):
    with con.cursor() as cursor:
        cursor.execute('UPDATE semestre SET nombre = %s, fecha_inicio = %s, fecha_fin = %s, vigencia = %s WHERE id = %s', (nombre, fecha_inicio, fecha_fin, vigencia, id))
        con.commit()
        
def buscarSemestre(id):
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre WHERE id = %s', (id))
        return cursor.fetchone()
    
def buscarSemestrePorNombre(nombre):
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre WHERE nombre = %s', (nombre))
        return cursor.fetchone()
    
