-- Creación de la tabla Semestre
CREATE TABLE semestre_academico (
    id_semestre INT PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    vigencia BOOLEAN
);

-- Creación de la tabla Docentes
CREATE TABLE docentes (
    id_docentes INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    dedicacion VARCHAR(50),
    telefono VARCHAR(20)
);

-- Creación de la tabla Curso
CREATE TABLE Curso (
    idCurso INT PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL
);

-- Creación de la tabla Grupos
CREATE TABLE Grupos (
    idGrupo INT PRIMARY KEY,
    denominacion VARCHAR(100),
    id_semestre INT NOT NULL,
    CursoIdCurso INT,
    id_docentes INT,
    FOREIGN KEY (id_semestre) REFERENCES semestre_academico(id_semestre),
    FOREIGN KEY (CursoIdCurso) REFERENCES Curso(idCurso),
    FOREIGN KEY (id_docentes) REFERENCES docentes(id_docentes)
);

-- Creación de la tabla Alumno
CREATE TABLE Alumno (
    codAlumno INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    stu_becas BOOLEAN,
    id_semestre INT,
    GruposGrupo INT,
    FOREIGN KEY (id_semestre) REFERENCES semestre_academico(id_semestre),
    FOREIGN KEY (GruposGrupo) REFERENCES Grupos(idGrupo)
);

-- Creación de la tabla Sustentacion
CREATE TABLE Sustentacion (
    idSustentacion INT PRIMARY KEY,
    tipo_sustentacion VARCHAR(50),
    semanas INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    duracion_maxima INT,
    compensacion INT,
    GruposGrupo INT,
    FOREIGN KEY (GruposGrupo) REFERENCES Grupos(idGrupo)
);

-- Creación de la tabla Docente_encargado
CREATE TABLE Docente_encargado (
    idDocenteEncargado INT PRIMARY KEY,
    AlumnoIdAlumno INT,
    jurado1 INT,
    jurado2 INT,
    asesor INT,
    FOREIGN KEY (AlumnoIdAlumno) REFERENCES Alumno(codAlumno),
    FOREIGN KEY (jurado1) REFERENCES docentes(id_docentes),
    FOREIGN KEY (jurado2) REFERENCES docentes(id_docentes),
    FOREIGN KEY (asesor) REFERENCES docentes(id_docentes)
);

-- Creación de la tabla Horario_disponible_docente
CREATE TABLE Horario_disponible_docente (
    idHorario INT PRIMARY KEY,
    fecha DATE,
    hora_inicio TIME,
    hora_fin TIME,
    id_docentes INT,
    FOREIGN KEY (id_docentes) REFERENCES docentes(id_docentes)
);hackaton_v1hackaton_v1

-- Creación de la tabla DOCENTE_SEMESTRE
CREATE TABLE DOCENTE_SEMESTRE (
    id_semestre INT,
    id_docentes INT,
    horas_asesoria_semanal INT,
    PRIMARY KEY (id_semestre, id_docentes),
    FOREIGN KEY (id_semestre) REFERENCES semestre_academico(id_semestre),
    FOREIGN KEY (id_docentes) REFERENCES docentes(id_docentes)
);
