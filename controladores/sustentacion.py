from controladores.bd import conexion

con = conexion()

def listarSustentaciones():
    try:
        with con.cursor() as cursor:
            cursor.execute('SELECT sus.idSustentacion, sem.nom_semestre, cur.nombre_curso, sus.tipo_sustentacion, sus.semanas, sus.fecha_inicio, sus.fecha_fin, sus.duracion_maxima, CASE WHEN sus.compensacion = 0 THEN "Si" ELSE "No" END AS compensacion FROM sustentacion sus INNER JOIN grupos gru ON sus.GruposGrupo = gru.idGrupo INNER JOIN semestre_academico sem ON sem.id_semestre = gru.id_semestre INNER JOIN curso cur ON cur.idCurso = gru.CursoIdCurso')
            return cursor.fetchall()
    except Exception as e:
        print("Error al listar sustentaciones:", e)
        return []
    finally:
        cursor.close()


def agregarSustentacion(tipo_sustentacion, semana, fecha_inicio, fecha_fin, duracion, compensacion, id_grupo):
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