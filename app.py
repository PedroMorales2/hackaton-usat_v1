from flask import Flask, render_template, request, redirect, url_for, flash, session
import xml.etree.ElementTree as ET
import controladores.semestre as sem
import controladores.docentes as doc
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('docente/insertar_docente.html')

#semestres

@app.route('/semestres')
def listarSemestre():
    semestre = sem.listar()
    return render_template('semestres/listarSemestre.html', semestre = semestre)

@app.route('/editar_semestre/<int:id>')
def editarSemestre(id):
    semestre = sem.buscarSemestre(id)
    return render_template('semestres/editarSemestre.html', semestre = semestre)

@app.route('/eliminar_semestre/<int:id>')
def eliminarSemestre(id):
    sem.eliminarSemestre(id)
    return redirect(url_for('listarSemestre'))

@app.route('/actualizar_semestre', methods=['POST'])
def actualizarSemestre():
    id = request.form['id']
    nombre = request.form['nombre']
    fecha_inicio = request.form['fecha_inicio']
    fecha_fin = request.form['fecha_fin']
    vigencia = request.form['vigencia']
    sem.editarSemestre(id, nombre, fecha_inicio, fecha_fin, vigencia)
    return redirect(url_for('listarSemestre'))

#docentes

@app.route('/docentes')
def listarDocente():
    docente = doc.listar()
    return render_template('docentes/listar_docente.html', docente = docente)

@app.route('/insertarDocente', methods=['POST'])
def insertarDocente():
    semestre_id = request.form['semestre_id']
    nombre = request.form['nombre']
    apellido = request.form['apellido']
    correo = request.form['correo']
    dedicacion = request.form['dedicacion']
    telefono = request.form['telefono']
    hora_asesoria = request.form['hora_asesoria']
    doc.insertarDocente(semestre_id,nombre, apellido, correo, dedicacion,telefono, hora_asesoria)
    return redirect(url_for('listarDocente'))

@app.route('/insertar', methods=['GET', 'POST'])
def upload_and_display():
    docentes = []
    if request.method == 'POST':
        file = request.files['file']
        if file and file.filename.endswith('.xml'):
            tree = ET.parse(file)
            root = tree.getroot()
            docentes = [{
                'semestre_id': docente.find('semestre').text,
                'nombre': docente.find('nombre').text,
                'apellido': docente.find('apellido').text,
                'correo': docente.find('correo').text,
                'dedicacion': docente.find('dedicacion').text,
                'telefono': docente.find('telefono').text,
                'hora_asesoria': docente.find('hora_asesoria').text
            } for docente in root.findall('.//docente')]
    return render_template('docente/insertar_docente.html', docentes=docentes)


            
             

if __name__ == '__main__':
    app.run( debug=True, use_reloader=True)
