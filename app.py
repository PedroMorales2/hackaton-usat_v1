from flask import Flask, render_template, request, redirect, url_for, flash, session
import xml.etree.ElementTree as ET
import pandas as pd
import controladores.semestre as sem
import controladores.docentes as doc
import controladores.cursos as cur
import controladores.grupo_horario as gru
import controladores.sustentacion as sus
import controladores.disponibilidad_docente as disponi
import controladores.cursos_asginados_docentes as cur_asig 
import controladores.login as logi

app = Flask(__name__)

app.secret_key = 'mysecret key'

@app.route('/modulo_administrador')
def home():
    return render_template('principal.html')

@app.route('/docentes')
def index():
    return render_template('docente/insertar_docente.html')

#semestres

@app.route('/semestres')
def listarSemestre():
    semestrese = sem.listar()
    return render_template('semestre/listarSemestre.html', semestrese = semestrese)

@app.route('/editar_semestre/<int:id>')
def editarSemestre(id):
    semestre = sem.buscarSemestre(id)
    return render_template('semestre/editar_semestre.html', semestre = semestre)

@app.route('/eliminar_semestre/<int:id>')
def eliminarSemestre(id):
    sem.eliminarSemestre(id)
    return redirect(url_for('listarSemestre'))

@app.route('/actualizar_semestre/<int:id>', methods=['POST'])
def actualizarSemestre(id):
    nombre = request.form['nombre']
    fecha_inicio = request.form['fecha_inicio']
    fecha_fin = request.form['fecha_fin']
    vigencia = request.form['vigencia']
    if not sem.editarSemestre(id,nombre, fecha_inicio, fecha_fin, vigencia):
        error = {'message': 'El semestre ya está agregado.'} # Usamos flash para enviar mensajes entre rutas
        return redirect(url_for('agregarSemestre', error=error))
    return redirect(url_for('listarSemestre2'))


@app.route('/agregar_semestre')
def agregarSemestre():
    return render_template('semestre/agregar_semestre.html')

@app.route('/listar_semestre2')
def listarSemestre2():
    semestrese = sem.listar()
    return render_template('semestre/listarSemestre2.html', semestrese = semestrese)



@app.route('/guardar_semestre', methods=['POST'])
def guardar_semestre():
    nombre = request.form['nombre']
    fecha_inicio = request.form['fecha_inicio']
    fecha_fin = request.form['fecha_fin']
    vigencia = request.form['vigencia']
    if not sem.insertarSemestre(nombre, fecha_inicio, fecha_fin, vigencia):
        flash("El semestre ya está agregado.", "danger")  # Agrega un mensaje con categoría 'error'
        return redirect(url_for('agregarSemestre'))
    return redirect(url_for('listarSemestre'))


# #docentes

# @app.route('/docentes')
# def listarDocente():
#     docente = doc.listar()
#     return render_template('docentes/listar_docente.html', docente = docente)

docentes = []

def find_start_row(df, columns):
    """Encuentra la fila inicial donde todas las columnas especificadas están presentes, considerando múltiples posibles nombres."""
    for index, row in df.iterrows():
        if all(any(col.lower() in str(x).lower() for x in row.values) for col in columns):
            return index
    return None


@app.route('/insertar', methods=['GET', 'POST'])
def upload_and_display():
    global docentes  
    if request.method == 'POST':
        file = request.files['file']
        if file:
            if file.filename.endswith(('.xml', '.xlsx', '.csv')):
                if file.filename.endswith('.xml'):
                    tree = ET.parse(file)
                    root = tree.getroot()
                    for docente in root.findall('.//docente'):
                        data = {}
                        fields = ['semestre', 'nombre', 'correo', 'dedicacion', 'telefono','hora_disponible']
                        for field in fields:
                            element = docente.find(field)
                            if element is not None:
                                data[field] = element.text
                            else:
                                data[field] = 'No especificado'
                        docentes.append(data)
                
                elif file.filename.endswith(('.xlsx', '.csv')):
                    if file.filename.endswith('.xlsx'):
                        df = pd.read_excel(file, header=None)
                    else:
                        df = pd.read_csv(file, header=None)
                    
                    expected_columns = ['semestre', 'nombre', 'correo', 'dedicacion', 'telefono','hora_disponible']
                    start_row = find_start_row(df, expected_columns)
                    if start_row is not None:
                        df.columns = df.iloc[start_row].apply(lambda x: x.lower() if isinstance(x, str) else x)
                        df = df[start_row+1:]
                        df = df.loc[:, df.columns.isin(expected_columns)].copy()  # Filtramos solo las columnas esperadas
                        docentes = df.to_dict(orient='records')
                    else:
                        missing_columns = [col for col in expected_columns if col not in df.columns]
                        return render_template('docente/insertar_docente.html', error=f'No se encontraron las columnas: {missing_columns}')
        
                                         
    return render_template('docente/insertar_docente.html', docentes=docentes)

@app.route('/update_docente', methods=['POST'])
def update_docente():
    index = int(request.form['index'])
    docentes[index]['semestre'] = request.form['semestre']
    docentes[index]['nombre'] = request.form['nombre']
    docentes[index]['correo'] = request.form['correo']
    docentes[index]['dedicacion'] = request.form['dedicacion']
    docentes[index]['telefono'] = request.form['telefono']
    docentes[index]['hora_disponible'] = request.form['hora_disponible']
    return redirect(url_for('upload_and_display'))


# insertar docente en la base de datos desde la tabla
@app.route('/insertar_docente', methods=['POST'])
def insertar_docente():
    try: 
        semestre = request.form.getlist('semestre[]')
        nombre = request.form.getlist('nombre[]')
        correo = request.form.getlist('correo[]')
        dedicacion = request.form.getlist('dedicacion[]')
        telefono = request.form.getlist('telefono[]')
        horas_asesoria = request.form.getlist('hora_disponible[]')

        for i in range(len(nombre)):  # Asumimos que todas las listas tienen la misma longitud
            doc.insertarDocente(semestre[i], nombre[i], correo[i], dedicacion[i], telefono[i], horas_asesoria[i])
        global docentes
        docentes = []
        flash('Todos los docentes han sido insertados exitosamente.', 'success')
    except Exception as e:
        flash(f'Error al insertar docentes: {str(e)}', 'danger')
    return redirect(url_for('upload_and_display'))


# @app.route('/insertar_docentes', methods=['POST'])
# def insertar_docentes():
#     semestre = request.form.getlist('semestre[]')
#     nombre = request.form.getlist('nombre[]')
#     apellidos = request.form.getlist('apellido[]')
#     correos = request.form.getlist('correo[]')
#     dedicaciones = request.form.getlist('dedicacion[]')
#     telefonos = request.form.getlist('telefono[]')
#     hora_disponible = request.form.getlist('hora_disponible[]')
    
#     for i in range(len(nombre)):
#         doc.insertarDocente(semestre[i],nombre[i], apellidos[i], correos[i], dedicaciones[i], telefonos[i],hora_disponible[i])
    
#     return redirect(url_for('upload_and_display'))  



######CURSOS
@app.route('/curso')
def cursito():
    cursos = cur.listar()
    return render_template('cursos/lista_cursos.html', cursos = cursos)

@app.route('/agregar_curso')
def agregarCurso():
    return render_template('cursos/agregar_cursos.html')

@app.route('/guardar_curso', methods=['POST'])
def guardar_curso():
    nombre = request.form['nombre_curso']
    cur.insertarCurso(nombre)
    return redirect(url_for('cursito'))

@app.route('/editar_curso/<int:id>')
def editarCurso(id):
    curso = cur.buscar(id)
    return render_template('cursos/modificar_cursos.html', curso = curso)

@app.route('/modificar_curso/<int:id>', methods=['POST'])
def modificarCurso(id):
    nombre = request.form['nombre_curso']
    cur.actualizarCurso(id, nombre)
    return redirect(url_for('cursito'))

@app.route('/eliminar_curso/<int:id>')
def eliminarCurso(id):
    cur.eliminarCurso(id)
    return redirect(url_for('cursito'))

########## AGREGAR GRUPOS EN SEMESTRES
@app.route('/agregar_grupos/<int:id>')
def agregarGrupo(id):
    semestres = sem.buscarSemestre(id)
    cursos = cur.listar()
    docente = doc.listar()
    return render_template('grupo_cursos/agregar_grupo.html', semestres = semestres, cursos = cursos, docente = docente)

# @app.route('/agregar_grupo_curso', methods=['POST'])
# def agregarTdos():
#     semestre = request.form['semestre']
#     curso = request.form['curso']
#     docente = request.form['docente']
    
#     cur.insertarGrupo(semestre, curso, docente)
#     return redirect(url_for('listarSemestre'))

# agregar desde el html con los input y los select

@app.route('/agregar_grupito', methods=['POST'])
def agregar_grupo_curso():
    denominacion = request.form['denominacion']
    id_docente = request.form['id_docente']
    id_curso = request.form['id_curso']
    semestre = request.form['semestre']
    
    resultado = gru.agregarGrupo(denominacion, semestre, id_docente,id_curso)
    
    if resultado:
        flash('Grupo agregado exitosamente.', 'success')
    else:
        flash('Error al agregar el grupo.', 'danger')


    return redirect(url_for('listarGrupo'))
    
    
# listar grupos
@app.route('/listar_grupos')
def listarGrupo():
    grupo = gru.listar_grupo_docente()
    return render_template('grupo_cursos/listar_grupo.html', grupo = grupo)

@app.route('/listar_gruposXID/<int:id>')
def listarGrupoXID(id):
    grupo = gru.listar_grupo_docenteXSEM(id)
    return render_template('grupo_cursos/listar_grupo.html', grupo = grupo)



@app.route('/insertar_sustentacion_grupo', methods=['POST'])
def insertar_sustentacion_grupo():
    # semestre = request.form['semestre']
    # curso = request.form['curso']
    tipo_sustentacion = request.form['tiempo']
    semanas = request.form['weekNumbers']
    inicio = request.form['startDate']
    fin = request.form['endDate']
    duracion = request.form['minutos']
    # compensacion = request.form['compensa']
    id_grupo = request.form['id_grupo']
    com = 1 if 'compensa' in request.form else 0
    sus.agregarSustentacion(tipo_sustentacion, semanas, inicio, fin, duracion, com, id_grupo)
    # print(id_grupo, tipo_sustentacion, semanas, inicio, fin, duracion, com)
    return redirect(url_for('sustentacionesGrupo'))



######### sustentaciones
@app.route('/sustentaciones_grupo')
def sustentacionesGrupo():
    sustentaciones = sus.listarSustentaciones()
    return render_template('sustentacion/sustentacion_lista_N1.html', sustentaciones = sustentaciones)

@app.route('/sustentacion/usuarios/<int:id>')
def sustentacionUsuarios(id):
    suss = sus.listarSustentacionesXID(id)
    return render_template('sustentacion/estudiantes_sustentacion.html', sus = suss)



########## ESTUDIANTES

estudiantes = {}

# formatear los campos vacios de la fila
def format_row(row):
    return {k: v if v else 'No especificado' for k, v in row.items()}



@app.route('/gestion_estudiantes/<int:id>', methods=['GET', 'POST'])
def gestion_estudiantes(id):
    global estudiantes
    suss = sus.listarSustentacionesXID(id)
    if request.method == 'POST' and 'file' in request.files:
        file = request.files['file']
        if file and file.filename.endswith(('.xlsx', '.csv')):
           
            df = pd.read_excel(file) if file.filename.endswith('.xlsx') else pd.read_csv(file)
            
            
            df.columns = [str(col).strip() for col in df.columns] 
            
            
            estudiantes = {i: row.to_dict() for i, row in df.iterrows()}
        else:
            return render_template('sustentacion/estudiantes_sustentacion.html', estudiantes=estudiantes, error='Formato de archivo no soportado o no enviado')

    return render_template('sustentacion/estudiantes_sustentacion.html', estudiantes=estudiantes, sus = suss)


@app.route('/sustentacion/proyecto/agregar_usuario/<int:id>', methods=['POST'])
def agregar_estudiantes_proyecto(id):
    codigo = request.form.getlist('codigo_universitario[]')
    nombres = request.form.getlist('apellidos_nombres[]')
    email = request.form.getlist('email[]')
    telefono = request.form.getlist('telefono[]')
    asesor = request.form.getlist('asesor[]')
    
    titulo = request.form.getlist('titulo_tesis[]')
    for i in range(len(nombres)):
        if sus.agregarDocenteSustentacion_proyecto(codigo[i], nombres[i], email[i], telefono[i], asesor[i], id, titulo[i]):
            flash('Estudiantes agregados exitosamente.', 'success')
        else:
            flash('Error al agregar el estudiante.', 'danger')
    return redirect(url_for('sustentacionesGrupo'))
                            

@app.route('/sustentacion/disc/agregar_usuario/<int:id>', methods=['POST'])
def agregar_estudiantes_disc(id):
    codigo = request.form.getlist('codigo_universitario[]')
    nombres = request.form.getlist('apellidos_nombres[]')
    email = request.form.getlist('email[]')
    telefono = request.form.getlist('telefono[]')
    asesor = request.form.getlist('asesor[]')
    jurado1 = request.form.getlist('jurado_1[]') 
    jurado2 = request.form.getlist('jurado_2[]')  
    titulo = request.form.getlist('titulo_tesis[]')
    for i in range(len(nombres)):
        sus.agregarDocenteSustentacion_disc(codigo[i], nombres[i], email[i], telefono[i], jurado1[i], jurado2[i], asesor[i], id, titulo[i])
    # solo muestre un mensaje:
    flash('Estudiantes agregados exitosamente.', 'success')
    return redirect(url_for('sustentacionesGrupo'))    


@app.route('/')
def mostrar_logueo():
    return render_template('login.html')



@app.route('/ver_cursos_asignados_docentes/<int:id>')
def ver_cursos_asignados_docentes(id):
    cur = cur_asig.listar_cursos_asignados_docentes(id)
    return render_template('info_docentes/ver_grupo.html', cur=cur)

@app.route('/inicio_sesion', methods=['POST'])
def inicio_sesion():
    correo = request.form['correo']
    contrasena = request.form['contrasena']
    usuario = logi.login(correo, contrasena)
    
    if usuario is None:
        flash('Correo o contraseña incorrectos.', 'danger')
        return redirect(url_for('mostrar_logueo'))

    # Asumimos que el estado del usuario indica su rol: 0 para administradores, 1 para docentes
    if usuario['status'] == 0:
        flash('ACCEDIDO CORRECTAMENTE.', 'success')
        return render_template('principal.html', usuario=usuario)
    elif usuario['status'] == 1:
        flash('ACCEDIDO CORRECTAMENTE.', 'success')
        return redirect(url_for('ver_cursos_asignados_docentes', id=usuario['id_docentes']))  # Usar ID del docente
    else:
        flash('Usuario no autorizado.', 'danger')
        return redirect(url_for('mostrar_logueo'))
    
@app.route('/listar_asesor_jurado/<int:id>')
def listar_asesor_juradosssss(id):
    try:
        cur = cur_asig.listar_asesor_jurado(id)
        return render_template('info_docentes/listar_jurados.html', cur=cur)
    except Exception as e:
        flash(f'Error al listar asesores y jurados: No tienes ninguna disponibilidad asignado', 'danger')
        return redirect(url_for('ver_cursos_asignados_docentes', id=id))


@app.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión exitosamente.', 'success')  # Mensaje opcional para confirmar el cierre de sesión
    return redirect(url_for('mostrar_logueo'))  # Redirige al usuario a la página de inicio de sesión



@app.route('/agregar_disponibilidad_horaria_docente', methods=['POST', 'GET'])
def agregar_disponibilidad_horaria_docente():
    if request.method == 'POST':
        try:
            fechas = request.form.getlist('fecha[]')
            horas_inicio = request.form.getlist('hora_inicio[]')
            horas_fin = request.form.getlist('hora_fin[]')
            ids_docentes = request.form.getlist('id_docentes[]')
            ids_sustentacion = request.form.getlist('id_sustentacion[]')
            
            for i in range(len(fechas)):
                cur_asig.insertar_disponibilidad_docente(fechas[i], horas_inicio[i], horas_fin[i], ids_docentes[i], ids_sustentacion[i])

            flash('Disponibilidad agregada exitosamente.', 'success')
            return redirect(url_for('ver_cursos_asignados_docentes', id=ids_docentes[0]))  # Asumiendo que 'mostrar_logueo' no necesita argumentos adicionales

        except Exception as e:
            flash(f'Error al agregar la disponibilidad: {str(e)}', 'danger')
            return redirect(url_for('ver_cursos_asignados_docentes', id=ids_docentes[0]))

    else:
        flash('Método no permitido para esta ruta.', 'danger')
        return redirect(url_for('ver_cursos_asignados_docentes', id=ids_docentes[0] if ids_docentes else 0))



if __name__ == '__main__':
    app.run( debug=True)
