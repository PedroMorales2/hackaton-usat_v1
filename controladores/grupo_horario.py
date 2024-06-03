from controladores.bd import conexion

def agregarGrupo(denominacion, id_semestre, id_docente, id_curso):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.callproc('insert_grupo_v2', (id_semestre, denominacion, id_docente, id_curso))
            con.commit()
            return True
    except Exception as e:
        print("Error al insertar grupo:", e)
        con.rollback()
        return False
    finally:
        cursor.close()
        
def listar_grupo_docente():
    con = conexion()
    try:
        with con.cursor() as cursor:
                 
            cursor.execute('SELECT gru.idGrupo, sem.nom_semestre, doc.nombre AS nom_docente, gru.denominacion, cu.nombre_curso FROM grupos gru INNER JOIN semestre_academico sem ON sem.id_semestre=gru.id_semestre INNER JOIN curso cu ON cu.idCurso = gru.CursoIdCurso INNER JOIN docentes doc ON doc.id_docentes = gru.id_docentes WHERE sem.vigencia = 1')
            return cursor.fetchall()
    except Exception as e:
        print("Error al listar grupos:", e)
        return []
    finally:
        cursor.close()
        
        
def listar_grupo_docenteXSEM(id_semestre):
    con = conexion()
    try:
        with con.cursor() as cursor:
                 
            cursor.execute('SELECT gru.idGrupo, sem.nom_semestre, doc.nombre AS nom_docente, gru.denominacion, cu.nombre_curso FROM grupos gru INNER JOIN semestre_academico sem ON sem.id_semestre=gru.id_semestre INNER JOIN curso cu ON cu.idCurso = gru.CursoIdCurso INNER JOIN docentes doc ON doc.id_docentes = gru.id_docentes where gru.id_semestre=%s',(id_semestre,))
            return cursor.fetchall()
    except Exception as e:
        print("Error al listar grupos:", e)
        return []
    finally:
        cursor.close()