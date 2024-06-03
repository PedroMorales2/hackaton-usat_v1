from controladores.bd import conexion

def listarSustentaciones():
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('SELECT sus.idSustentacion,sem.nom_semestre, cur.nombre_curso,gru.denominacion ,sus.tipo_sustentacion, sus.semanas, sus.fecha_inicio, sus.fecha_fin, sus.duracion_maxima, CASE WHEN sus.compensacion = 0 THEN "Si" ELSE "No" END AS compensacion FROM sustentacion sus INNER JOIN grupos gru ON sus.GruposGrupo = gru.idGrupo INNER JOIN semestre_academico sem ON sem.id_semestre = gru.id_semestre INNER JOIN curso cur ON cur.idCurso = gru.CursoIdCurso where sem.vigencia = 1')
            return cursor.fetchall()
    except Exception as e:
        print("Error al listar sustentaciones:", e)
        return []
    finally:
        cursor.close()


def listarSustentacionesXID(id_sustentacion):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('SELECT doc.nombre AS nombre_docente, doc.correo,doc.dedicacion,doc.telefono,cur.idCurso,sus.idSustentacion,sem.nom_semestre, cur.nombre_curso,gru.denominacion ,sus.tipo_sustentacion, sus.semanas, sus.fecha_inicio, sus.fecha_fin, sus.duracion_maxima, CASE WHEN sus.compensacion = 0 THEN "Si" ELSE "No" END AS compensacion FROM sustentacion sus INNER JOIN grupos gru ON sus.GruposGrupo = gru.idGrupo INNER JOIN semestre_academico sem ON sem.id_semestre = gru.id_semestre INNER JOIN curso cur ON cur.idCurso = gru.CursoIdCurso INNER JOIN docentes doc ON doc.id_docentes=gru.id_docentes WHERE sus.idSustentacion = %s', (id_sustentacion,))
            return cursor.fetchone()
    except Exception as e:
        print("Error al listar sustentaciones:", e)
        return []
    finally:
        cursor.close()
    


def agregarSustentacion(tipo_sustentacion, semana, fecha_inicio, fecha_fin, duracion, compensacion, id_grupo):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('insert into sustentacion (tipo_sustentacion, semanas, fecha_inicio, fecha_fin, duracion_maxima, compensacion, GruposGrupo) values (%s, %s, %s, %s, %s, %s, %s)', (tipo_sustentacion, semana, fecha_inicio, fecha_fin, duracion, compensacion, id_grupo))
            con.commit()
            return True
    except Exception as e:
        print("Error al insertar sustentacion:", e)
        con.rollback()
        return False
    finally:
        cursor.close()
        
def agregarDocenteSustentacion_proyecto(codigo,nombreAlumno,email,telefono,asesor,id_sustentacion,proyecto):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.callproc('insertar_alumno_v', (codigo,nombreAlumno,email,telefono,asesor,id_sustentacion,proyecto))
            con.commit()
            return True
    except Exception as e:
        print("Error al insertar alumno sustentacion:", e)
        con.rollback()
        return False
    finally:
        cursor.close()

def agregarDocenteSustentacion_disc(codigo,nombreAlumno,email,telefono,jurado1,jurado2,asesor,id_sustentacion,proyecto):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.callproc('insertar_alumno_v2', (codigo,nombreAlumno,email,telefono,jurado1,jurado2,asesor,id_sustentacion,proyecto))
            con.commit()
            return True
    except Exception as e:
        print("Error al insertar alumno sustentacion:", e)
        con.rollback()
        return False
    finally:
        cursor.close()