from controladores.bd import conexion



def listar_cursos_asignados_docentes(id_docente):
    con = conexion()
    try:
        cursor = con.cursor()
        query = """
        SELECT sus.idSustentacion,d.id_docentes,cur.nombre_curso, gru.denominacion, 
        hor.fecha, hor.hora_inicio, hor.hora_fin,
        sem.nom_semestre, sus.fecha_inicio, 
        sus.fecha_fin, sus.tipo_sustentacion, sus.duracion_maxima
        FROM curso cur 
        JOIN grupos gru ON cur.idCurso = gru.CursoIdCurso
        JOIN semestre_academico sem ON sem.id_semestre = gru.id_semestre
        JOIN sustentacion sus ON sus.GruposGrupo = gru.idGrupo
        JOIN alumno al ON al.Sustentacion_id = sus.idSustentacion
        JOIN docente_encargado de ON de.AlumnoIdAlumno = al.codAlumno
        JOIN 
            docentes d ON de.asesor = d.id_docentes OR de.jurado1 = d.id_docentes OR de.jurado2 = d.id_docentes
        left JOIN horario_disponible_docente hor ON hor.id_docentes = d.id_docentes
        WHERE d.id_docentes = %s && sem.vigencia= 1 
        GROUP BY cur.nombre_curso
        """
        cursor.execute(query, (id_docente,))
        cursos_asignados_docentes = cursor.fetchall()
        return cursos_asignados_docentes
    except Exception as e:
        print("Error al listar cursos asignados a docentes:", e)
        return None
    finally:
        cursor.close()


def insertar_disponibilidad_docente(fecha, hora_inicio, hora_fin, id_docentes, id_sustentacion):
    con = conexion()
    cursor = con.cursor()
    try:
        query = """
            INSERT INTO horario_disponible_docente (fecha, hora_inicio, hora_fin, id_docentes, id_sustentacion) 
            VALUES (%s, %s, %s, %s, %s);
        """
        cursor.execute(query, (fecha, hora_inicio, hora_fin, id_docentes, id_sustentacion))
        con.commit()
        return True
    except Exception as e:
        con.rollback()
        print("Error al insertar disponibilidad docente:", e)
        return False
    finally:
        cursor.close()
        con.close()
        
def listar_asesor_jurado(id):
    con = conexion()
    try:
        cursor = con.cursor()
        query = """
                    SELECT 
	 cur.nombre_curso,
  al.codAlumno,
  doce.id_docentes,
    al.nombre_completo, 
    GROUP_CONCAT(DISTINCT CASE 
        WHEN doc.asesor = doce.id_docentes THEN 'Asesor'
        WHEN doc.jurado1 = doce.id_docentes THEN 'Jurado 1'
        WHEN doc.jurado2 = doce.id_docentes THEN 'Jurado 2'
        ELSE 'No definido'
    END ORDER BY doc.asesor, doc.jurado1, doc.jurado2) AS roles
FROM 
    alumno al 
INNER JOIN 
    docente_encargado doc ON doc.AlumnoIdAlumno = al.codAlumno
LEFT JOIN 
    docentes doce ON doc.jurado1 = doce.id_docentes OR doc.jurado2 = doce.id_docentes OR doc.asesor = doce.id_docentes
INNER JOIN horario_disponible_docente hor ON hor.id_docentes = doce.id_docentes
INNER JOIN sustentacion sus ON sus.idSustentacion = hor.id_sustentacion
INNER JOIN grupos gru ON gru.idGrupo = sus.GruposGrupo
INNER JOIN curso cur ON cur.idCurso = gru.CursoIdCurso
INNER JOIN semestre_academico sem ON sem.id_semestre = gru.id_semestre
WHERE 
    doce.id_docentes = %s AND sem.vigencia = 1
GROUP BY 
    al.nombre_completo

        """
        cursor.execute(query, (id,))
        asesor_jurado = cursor.fetchall()
        return asesor_jurado
    except Exception as e:
        print("Error al listar asesor asesor o jurado:", e)
        return None
    finally:
        cursor.close()
        con.close()
