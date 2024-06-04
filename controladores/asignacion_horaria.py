from controladores.bd import conexion

def obtener_disponibilidad_curso(id_curso):
    con = conexion()
    resultados = []
    try:
        with con.cursor() as cursor:
            query = """
            SELECT DATE_FORMAT(hor.fecha, '%%Y-%%m-%%d') as fecha, 
                   TIME_FORMAT(hor.hora_inicio, '%%H:%%i:%%s') as hora_inicio, 
                   TIME_FORMAT(hor.hora_fin, '%%H:%%i:%%s') as hora_fin, 
                   doc.id_docentes 
            FROM horario_disponible_docente hor 
            INNER JOIN docentes doc ON hor.id_docentes = doc.id_docentes
            INNER JOIN sustentacion sus ON sus.idSustentacion = hor.id_sustentacion
            INNER JOIN grupos gru ON gru.idGrupo = sus.GruposGrupo
            INNER JOIN curso cur ON cur.idCurso = gru.CursoIdCurso
            WHERE cur.idCurso = %s
            """
            cursor.execute(query, (id_curso,))
            resultados = cursor.fetchall()
        return resultados
    except Exception as e:
        print("Error al obtener disponibilidad:", e)
        con.rollback()
        return []
    finally:
        if con:
            con.close()
import pymysql



def obtener_datos_de_la_base():
    conn = conexion()
    cursor = conn.cursor()

    # Incluir el nombre en la consulta de disponibilidad
    cursor.execute("""
    SELECT d.id_docentes, d.nombre, h.fecha, h.hora_inicio, h.hora_fin
    FROM horario_disponible_docente h
    JOIN docentes d ON h.id_docentes = d.id_docentes
    """)
    disponibilidad_docentes = cursor.fetchall()

    # Incluir los nombres de los jurados en la consulta
    cursor.execute("""
    SELECT e.AlumnoIdAlumno, d1.nombre as jurado1, d2.nombre as jurado2, d3.nombre as asesor
    FROM docente_encargado e
    JOIN docentes d1 ON e.jurado1 = d1.id_docentes
    JOIN docentes d2 ON e.jurado2 = d2.id_docentes
    JOIN docentes d3 ON e.asesor = d3.id_docentes
    """)
    jurados_por_alumno = cursor.fetchall()

    conn.close()
    return disponibilidad_docentes, jurados_por_alumno
