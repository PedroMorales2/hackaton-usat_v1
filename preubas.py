import controladores.asignacion_horaria as ase
from ortools.sat.python import cp_model
from datetime import datetime


def convertir_a_bloques(hora_inicio_str, hora_fin_str):
    formato = "%H:%M:%S"
    try:
        hora_inicio = datetime.strptime(hora_inicio_str, formato)
        hora_fin = datetime.strptime(hora_fin_str, formato)
    except ValueError as e:
        print(f"Error al convertir las horas: {e}")
        return []

    inicio_bloque = hora_inicio.hour - 8
    fin_bloque = hora_fin.hour - 8

    return list(range(inicio_bloque, fin_bloque))

def main():
    disponibilidad_docentes, jurados_por_alumno = ase.obtener_datos_de_la_base()
    model = cp_model.CpModel()

    num_horarios = 10  # Suponiendo 10 bloques horarios
    horarios = {}
    nombres_docentes = {}

    # Asegúrate de que la estructura de datos para horarios y nombres_docentes se establece correctamente
    for AlumnoIdAlumno, jurado1, jurado2, asesor in jurados_por_alumno:
        horarios[AlumnoIdAlumno] = {
            'jurado1': model.NewIntVar(0, num_horarios - 1, f'horario_jurado1_{AlumnoIdAlumno}'),
            'jurado2': model.NewIntVar(0, num_horarios - 1, f'horario_jurado2_{AlumnoIdAlumno}'),
            'asesor': model.NewIntVar(0, num_horarios - 1, f'horario_asesor_{AlumnoIdAlumno}')
        }
        nombres_docentes[AlumnoIdAlumno] = {
            'jurado1': jurado1,
            'jurado2': jurado2,
            'asesor': asesor
        }

    # Comprobación para evitar el TypeError
    for alumno in horarios:
        model.AddAllDifferent(list(horarios[alumno].values()))

    for id_docente, nombre, fecha, hora_inicio, hora_fin in disponibilidad_docentes:
        bloques = convertir_a_bloques(hora_inicio, hora_fin)
        for AlumnoIdAlumno in jurados_por_alumno:
            for role in ['jurado1', 'jurado2', 'asesor']:
                if nombres_docentes[AlumnoIdAlumno][role] == nombre:
                    # Asegúrate de pasar valores hashables correctamente
                    model.AddAllowedAssignments([horarios[AlumnoIdAlumno][role]], [(x,) for x in bloques])

    solver = cp_model.CpSolver()
    status = solver.Solve(model)

    if status == cp_model.OPTIMAL:
        print('Horarios asignados:')
        for alumno in horarios:
            print(f'Alumno {alumno}:')
            for role, var in horarios[alumno].items():
                print(f'  {role} ({nombres_docentes[alumno][role]}) tiene el horario {solver.Value(var)} desde {8 + solver.Value(var)}:00 a {9 + solver.Value(var)}:00')
    else:
        print('No se encontró una solución óptima.')

if __name__ == '__main__':
    main()