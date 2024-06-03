from controladores.bd import conexion

def listar():
    con = conexion()
    with con.cursor() as cursor:
        try:
            cursor.execute('SELECT * FROM semestre_academico')
            return cursor.fetchall()
        except Exception as e:
            print("Error al listar semestres:", e)
            return None
        finally:
            cursor.close()
            
            
def insertarSemestre(nombre, fecha_inicio, fecha_fin, vigencia):
    con = conexion()  

    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre_academico WHERE nom_semestre = %s', (nombre,))
        if cursor.fetchone() is not None:
            return False 
        cursor.execute('INSERT INTO semestre_academico (nom_semestre, fecha_inicio, fecha_fin, vigencia) VALUES (%s, %s, %s, %s)', 
                       (nombre, fecha_inicio, fecha_fin, vigencia))
        con.commit()
        return True

def eliminarSemestre(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('DELETE FROM semestre_academico WHERE id_semestre = %s', (id))
        con.commit()
        
def editarSemestre(id, nombre, fecha_inicio, fecha_fin, vigencia):
    
    con = conexion()  
    try:
        with con.cursor() as cursor:
            cursor.execute('SELECT * FROM semestre_academico WHERE nom_semestre = %s', (nombre,))
            if cursor.fetchone() is not None:
                return False 
            cursor.execute('UPDATE semestre_academico SET nom_semestre = %s, fecha_inicio = %s, fecha_fin = %s, vigencia = %s WHERE id_semestre = %s', (nombre, fecha_inicio, fecha_fin, vigencia, id))
            cursor.commit()
            return True
    except Exception as e:
        print("Error al actualizar semestre:", e)
        con.rollback()
        return False
    finally:
        cursor.close()  
        
def buscarSemestre(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre_academico WHERE id_semestre = %s', (id))
        return cursor.fetchone()
    
def buscarSemestrePorNombre(nombre):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('SELECT * FROM semestre_academico WHERE nombre = %s', (nombre))
        return cursor.fetchone()
    

