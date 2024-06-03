from controladores.bd import conexion

def insertar_disponibilidad_docente(fecha,hora_inicio,hpra_fin,id_docentes):
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('INSERT INTO horario_disponible_docente(fecha,hora_inicio,hora_fin,id_docentes) values (%s,%s,%s,%s)', (fecha,hora_inicio,hpra_fin,id_docentes))
            return con.commit()
    except Exception as e:
        print("Error al insertar la disponibilidad del docente:", e)
        return con.rollback()
    finally:
        cursor.close()

def listar_disponibilidad_docente():
    con = conexion()
    try:
        with con.cursor() as cursor:
            cursor.execute('SELECT * FROM horario_disponible_docente')
            return cursor.fetchall()
    except Exception as e:
        print("Error al listar la disponibilidad del docente:", e)
        return con.close()
    finally:
        cursor.close()
    