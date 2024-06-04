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
            
            
def insertarSemestre(nombre, fecha_inicio, fecha_fin):
    con = conexion()
    try:
        with con.cursor() as cursor:
            # Comprobar si el semestre ya existe
            cursor.execute('SELECT 1 FROM semestre_academico WHERE nom_semestre = %s', (nombre,))
            if cursor.fetchone():
                return False  # El semestre ya existe

            # Insertar nuevo semestre con vigencia por defecto activada (1)
            cursor.execute(
                'INSERT INTO semestre_academico (nom_semestre, fecha_inicio, fecha_fin, vigencia) VALUES (%s, %s, %s, 1)',
                (nombre, fecha_inicio, fecha_fin)
            )
            con.commit()
            return True
    except Exception as e:
        print(f"Error al insertar el semestre: {e}")
        return False
    finally:
        con.close()

def eliminarSemestre(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('DELETE FROM semestre_academico WHERE id_semestre = %s', (id))
        con.commit()
        
def editarSemestre(id, fecha_inicio, fecha_fin, vigencia):
    con = conexion()  
    try:
        with con.cursor() as cursor:
            cursor.execute('UPDATE semestre_academico SET fecha_inicio = %s, fecha_fin = %s, vigencia = %s WHERE id_semestre = %s', ( fecha_inicio, fecha_fin, vigencia, id))
            con.commit()
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
    

def dar_baja_semestre(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('UPDATE `semestre_academico` SET `vigencia`=0 WHERE  `id_semestre` = %s', (id))
        con.commit()
        return True
    
def dar_alta_semestre(id):
    con = conexion()
    with con.cursor() as cursor:
        cursor.execute('UPDATE `semestre_academico` SET `vigencia`=1 WHERE  `id_semestre` = %s', (id))
        con.commit()
        return True

