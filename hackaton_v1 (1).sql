-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 31-05-2024 a las 19:03:25
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `hackaton_v1`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_alumno_v` (IN `p_nombre_codigo` VARCHAR(50), IN `p_nombre_nombreAlumno` VARCHAR(100), IN `p_nombre_email` VARCHAR(100), IN `p_nombre_telefono` VARCHAR(20), IN `p_nombre_asesor` VARCHAR(100), IN `p_id_sustentacion` INT, IN `p_nombre_titulo` VARCHAR(100))   BEGIN
	DECLARE v_id_docente INT;
	DECLARE v_id_alumno INT;
	 
	SELECT id_docentes INTO v_id_docente FROM docentes WHERE nombre =  p_nombre_asesor;
	
	INSERT INTO alumno(nombre_completo,email,telefono,titulo_tesis,Sustentacion_id,codigo_universitario) 
	VALUES(p_nombre_nombreAlumno, p_nombre_email,p_nombre_telefono,p_nombre_titulo,p_id_sustentacion,p_nombre_codigo);
	SET v_id_alumno = LAST_INSERT_ID();
	
	INSERT INTO docente_encargado(asesor,AlumnoIdAlumno) 
	VALUES(v_id_docente,v_id_alumno);
	
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_alumno_v2` (IN `p_nombre_codigo` VARCHAR(50), IN `p_nombre_nombreAlumno` VARCHAR(100), IN `p_nombre_email` VARCHAR(100), IN `p_nombre_telefono` VARCHAR(20), IN `p_nombre_jurado1` VARCHAR(100), IN `p_nombre_jurado2` VARCHAR(100), IN `p_nombre_asesor` VARCHAR(100), IN `p_id_sustentacion` INT, IN `p_nombre_titulo` VARCHAR(100))   BEGIN
	DECLARE v_id_docente INT;
	DECLARE v_id_jurado1 INT;
	DECLARE v_id_jurado2 INT;
	DECLARE v_id_alumno INT;
	 
	SELECT id_docentes INTO v_id_docente FROM docentes WHERE nombre =  p_nombre_asesor;
	SELECT id_docentes INTO v_id_jurado1 FROM docentes WHERE nombre =  p_nombre_jurado1;
	SELECT id_docentes INTO v_id_jurado2 FROM docentes WHERE nombre =  p_nombre_jurado2;	
	INSERT INTO alumno(nombre_completo,email,telefono,titulo_tesis,Sustentacion_id,codigo_universitario) 
	VALUES(p_nombre_nombreAlumno, p_nombre_email,p_nombre_telefono,p_nombre_titulo,p_id_sustentacion,p_nombre_codigo);
	SET v_id_alumno = LAST_INSERT_ID();
	
	INSERT INTO docente_encargado(asesor,AlumnoIdAlumno,jurado1,jurado2) 
	VALUES(v_id_docente,v_id_alumno,v_id_jurado1,v_id_jurado2);
	
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_docente` (IN `p_nom_semestre` VARCHAR(50), IN `p_nombre` VARCHAR(100), IN `p_correo` VARCHAR(100), IN `p_dedicacion` VARCHAR(50), IN `p_telefono` VARCHAR(20), IN `p_horas_asesoria` INT)   BEGIN
    DECLARE v_id_semestre INT;
    DECLARE v_id_docente INT;

    -- Buscar el ID del semestre
    SELECT id_semestre INTO v_id_semestre FROM semestre_academico WHERE nom_semestre = p_nom_semestre;
    IF v_id_semestre IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El semestre proporcionado no existe.';
    END IF;

    -- Insertar el nuevo docente
    INSERT INTO docentes (nombre, correo, dedicacion, telefono) 
    VALUES (p_nombre, p_correo, p_dedicacion, p_telefono);
    SET v_id_docente = LAST_INSERT_ID();

    -- Vincular el docente con el semestre
    INSERT INTO docente_semestre (id_docentes, id_semestre, horas_asesoria_semanal) 
    VALUES (v_id_docente, v_id_semestre, p_horas_asesoria);

    -- Commit la transacción
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_grupo` (IN `p_nom_semestre` VARCHAR(50), IN `p_denominacion` VARCHAR(100), IN `p_docente` VARCHAR(50), IN `p_curso` VARCHAR(50))   BEGIN
    DECLARE v_id_semestre INT;
    DECLARE v_id_docente INT;
    DECLARE v_id_curso INT;
    
    SELECT id_semestre INTO v_id_semestre FROM semestre_academico WHERE nom_semestre = p_nom_semestre;
    SELECT id_docentes INTO v_id_docente FROM docentes WHERE nombre = p_docente;
    SELECT idCurso INTO v_id_curso FROM curso WHERE nombre_curso = p_curso;
    
	 IF v_id_semestre IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El semestre proporcionado no existe.';
    END IF;


	 IF v_id_docente IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El semestre proporcionado no existe.';
    END IF;
    
    
	 IF v_id_curso IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El semestre proporcionado no existe.';
    END IF;
    
    INSERT INTO grupos(denominacion,id_semestre,CursoIdCurso,id_docente) 
	 VALUES (p_denominacion,v_id_semestre,v_id_curso,v_id_docente);
    -- Insertar el nuevo docente

    -- Vincular el docente c
    -- Commit la transacción
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_gruop` (IN `p_nom_semestre` VARCHAR(50), IN `p_denominacion` VARCHAR(100), IN `p_docente` VARCHAR(100), IN `p_curso` VARCHAR(100))   BEGIN
    DECLARE v_id_semestre INT;
    DECLARE v_id_docente INT;
    DECLARE v_id_curso INT;
    
    SELECT id_semestre INTO v_id_semestre FROM semestre_academico WHERE nom_semestre = p_nom_semestre;
    SELECT id_docentes INTO v_id_docente FROM docentes WHERE nombre = p_docente;
    SELECT idCurso INTO v_id_curso FROM curso WHERE nombre_curso = p_curso;
    
    INSERT INTO grupos(denominacion,id_semestre,CursoIdCurso,id_docentes) 
	 VALUES (p_denominacion,v_id_semestre,v_id_curso,v_id_docente);
    -- Insertar el nuevo docente

    -- Vincular el docente c
    -- Commit la transacción
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_grupo_v2` (IN `p_nom_semestre` VARCHAR(50), IN `p_denominacion` VARCHAR(100), IN `p_docente` INT, IN `p_curso` INT)   BEGIN
    DECLARE v_id_semestre INT;
    
    SELECT id_semestre INTO v_id_semestre FROM semestre_academico WHERE nom_semestre = p_nom_semestre;
    
    INSERT INTO grupos(denominacion,id_semestre,CursoIdCurso,id_docentes) 
	 VALUES (p_denominacion,v_id_semestre,p_curso,p_docente);
    -- Insertar el nuevo docente

    -- Vincular el docente c
    -- Commit la transacción
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno`
--

CREATE TABLE `alumno` (
  `codAlumno` int(11) NOT NULL,
  `codigo_universitario` int(11) DEFAULT NULL,
  `nombre_completo` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `titulo_tesis` varchar(100) DEFAULT NULL,
  `id_semestre` int(11) DEFAULT NULL,
  `GruposGrupo` int(11) DEFAULT NULL,
  `Sustentacion_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `alumno`
--

INSERT INTO `alumno` (`codAlumno`, `codigo_universitario`, `nombre_completo`, `email`, `telefono`, `titulo_tesis`, `id_semestre`, `GruposGrupo`, `Sustentacion_id`) VALUES
(1, 201, 'asd', 'asdasd', '123123', 'asd', NULL, NULL, 1),
(3, 2011, 'asd', 'asdasd', '123123', 'asd', NULL, NULL, 1),
(5, 20111, 'asd', 'asdasd', '123123', 'asd', NULL, NULL, 1),
(7, 0, 'pedro', 'asdasd', '923505083', 'asdasd', NULL, NULL, 1),
(9, 202466, 'pedro', 'asdasd', '923505083', 'asdasd', NULL, NULL, 3),
(10, 636363, 'pedro', 'asdasd', '923505083', 'asdasd', NULL, NULL, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `curso`
--

CREATE TABLE `curso` (
  `idCurso` int(11) NOT NULL,
  `nombre_curso` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `curso`
--

INSERT INTO `curso` (`idCurso`, `nombre_curso`) VALUES
(1, 'Proyecto de investigacion'),
(2, 'Seminario de Tesis II'),
(4, 'aaaaa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentes`
--

CREATE TABLE `docentes` (
  `id_docentes` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `dedicacion` varchar(50) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `docentes`
--

INSERT INTO `docentes` (`id_docentes`, `nombre`, `correo`, `dedicacion`, `telefono`) VALUES
(1, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(2, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(3, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(4, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(5, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(6, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(7, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(8, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(9, 'asd', 'asdas@gmail.com', 'TP', '923505083'),
(10, 'PEDRO', 'asdas@gmail.com', 'TC', '923505083'),
(11, 'FALU ', 'asdas@gmail.com', 'TP', '923505083'),
(12, 'PEDROA', 'asdas@gmail.com', 'TC', '923505083'),
(13, 'FALU AAA', 'asdas@gmail.com', 'TP', '923505083'),
(14, 'PEDRO', 'asdas@gmail.com', 'TC', '923505083'),
(15, 'FALU ', 'asdas@gmail.com', 'TP', '923505083'),
(16, 'PEDRO', 'asdas@gmail.com', 'TC', '923505083'),
(17, 'FALU ', 'asdas@gmail.com', 'TP', '923505083'),
(18, 'PEDRO', 'asdas@gmail.com', 'TC', '923505083'),
(19, 'FALU ', 'asdas@gmail.com', 'TP', '923505083'),
(20, 'unico', 'unico', 'TP', '923505479'),
(21, 'PEDRO', 'asdas@gmail.com', 'TC', '923505083'),
(22, 'FALU ', 'asdas@gmail.com', 'TP', '923505083');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docente_encargado`
--

CREATE TABLE `docente_encargado` (
  `idDocenteEncargado` int(11) NOT NULL,
  `AlumnoIdAlumno` int(11) DEFAULT NULL,
  `jurado1` int(11) DEFAULT NULL,
  `jurado2` int(11) DEFAULT NULL,
  `asesor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `docente_encargado`
--

INSERT INTO `docente_encargado` (`idDocenteEncargado`, `AlumnoIdAlumno`, `jurado1`, `jurado2`, `asesor`) VALUES
(1, 1, NULL, NULL, 20),
(2, 3, NULL, NULL, 20),
(3, 5, 20, 20, 20),
(4, 7, NULL, NULL, NULL),
(5, 9, 20, 20, 20),
(6, 10, NULL, NULL, 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docente_semestre`
--

CREATE TABLE `docente_semestre` (
  `id_semestre` int(11) NOT NULL,
  `id_docentes` int(11) NOT NULL,
  `horas_asesoria_semanal` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `docente_semestre`
--

INSERT INTO `docente_semestre` (`id_semestre`, `id_docentes`, `horas_asesoria_semanal`) VALUES
(1, 7, 500),
(1, 8, 500),
(1, 9, 500),
(1, 10, 5),
(1, 11, 50),
(1, 12, 5),
(1, 13, 10),
(1, 14, 5),
(1, 15, 50),
(1, 16, 5),
(1, 17, 50),
(1, 18, 5),
(1, 19, 50),
(1, 21, 5),
(1, 22, 50);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `idGrupo` int(11) NOT NULL,
  `denominacion` varchar(100) DEFAULT NULL,
  `id_semestre` int(11) NOT NULL,
  `CursoIdCurso` int(11) DEFAULT NULL,
  `id_docentes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `grupos`
--

INSERT INTO `grupos` (`idGrupo`, `denominacion`, `id_semestre`, `CursoIdCurso`, `id_docentes`) VALUES
(8, 'A', 3, 2, 7),
(9, 'A', 7, 2, 4),
(10, 'B', 7, 1, 1),
(11, 'B', 7, 2, 16),
(12, 'A', 1, 2, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario_disponible_docente`
--

CREATE TABLE `horario_disponible_docente` (
  `idHorario` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `id_docentes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `semestre_academico`
--

CREATE TABLE `semestre_academico` (
  `id_semestre` int(11) NOT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `vigencia` tinyint(1) DEFAULT NULL,
  `nom_semestre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `semestre_academico`
--

INSERT INTO `semestre_academico` (`id_semestre`, `fecha_inicio`, `fecha_fin`, `vigencia`, `nom_semestre`) VALUES
(1, '2024-05-09', '2024-05-24', 0, '2024-1'),
(2, '2024-05-10', '2024-06-01', 0, '2024-2'),
(3, '2024-05-10', '2024-05-26', 0, '2024-5'),
(4, '0000-00-00', '0000-00-00', 0, '2024-3'),
(5, '2024-05-08', '2024-05-25', 0, '2024-6'),
(6, '0000-00-00', '0000-00-00', 0, '2024-7'),
(7, '2024-05-10', '2024-05-18', 0, '2025-1'),
(11, '2024-05-16', '2024-05-25', 0, '2026-6'),
(12, '2024-05-23', '2024-05-31', 0, '2024-4'),
(13, '2024-05-08', '2024-05-25', 1, '2027-2'),
(14, '2024-05-17', '2024-05-24', 1, '2027-1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sustentacion`
--

CREATE TABLE `sustentacion` (
  `idSustentacion` int(11) NOT NULL,
  `tipo_sustentacion` varchar(50) DEFAULT NULL,
  `semanas` varchar(50) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `duracion_maxima` int(11) DEFAULT NULL,
  `compensacion` int(11) DEFAULT NULL,
  `GruposGrupo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `sustentacion`
--

INSERT INTO `sustentacion` (`idSustentacion`, `tipo_sustentacion`, `semanas`, `fecha_inicio`, `fecha_fin`, `duracion_maxima`, `compensacion`, `GruposGrupo`) VALUES
(1, 'parcial', '1 ', '0000-00-00', '0000-00-00', 50, 1, 9),
(2, 'parcial', '1', '2024-01-01', '2024-01-07', 30, 0, 8),
(3, 'final', '2', '0000-00-00', '0000-00-00', 50, 1, 9),
(4, 'parcial', '1,2', '2024-01-01', '2024-01-14', 50, 1, 10),
(5, 'final', '1', '0000-00-00', '0000-00-00', 50, 0, 11),
(6, 'final', '1', '0000-00-00', '0000-00-00', 50, 1, 12);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD PRIMARY KEY (`codAlumno`),
  ADD UNIQUE KEY `codigo_universitario` (`codigo_universitario`),
  ADD KEY `id_semestre` (`id_semestre`),
  ADD KEY `GruposGrupo` (`GruposGrupo`),
  ADD KEY `Column 9` (`Sustentacion_id`);

--
-- Indices de la tabla `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`idCurso`);

--
-- Indices de la tabla `docentes`
--
ALTER TABLE `docentes`
  ADD PRIMARY KEY (`id_docentes`);

--
-- Indices de la tabla `docente_encargado`
--
ALTER TABLE `docente_encargado`
  ADD PRIMARY KEY (`idDocenteEncargado`),
  ADD KEY `AlumnoIdAlumno` (`AlumnoIdAlumno`),
  ADD KEY `jurado1` (`jurado1`),
  ADD KEY `jurado2` (`jurado2`),
  ADD KEY `asesor` (`asesor`);

--
-- Indices de la tabla `docente_semestre`
--
ALTER TABLE `docente_semestre`
  ADD PRIMARY KEY (`id_semestre`,`id_docentes`),
  ADD KEY `id_docentes` (`id_docentes`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`idGrupo`),
  ADD KEY `id_semestre` (`id_semestre`),
  ADD KEY `CursoIdCurso` (`CursoIdCurso`),
  ADD KEY `id_docentes` (`id_docentes`);

--
-- Indices de la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  ADD PRIMARY KEY (`idHorario`),
  ADD KEY `id_docentes` (`id_docentes`);

--
-- Indices de la tabla `semestre_academico`
--
ALTER TABLE `semestre_academico`
  ADD PRIMARY KEY (`id_semestre`);

--
-- Indices de la tabla `sustentacion`
--
ALTER TABLE `sustentacion`
  ADD PRIMARY KEY (`idSustentacion`),
  ADD KEY `GruposGrupo` (`GruposGrupo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumno`
--
ALTER TABLE `alumno`
  MODIFY `codAlumno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `curso`
--
ALTER TABLE `curso`
  MODIFY `idCurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `docentes`
--
ALTER TABLE `docentes`
  MODIFY `id_docentes` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `docente_encargado`
--
ALTER TABLE `docente_encargado`
  MODIFY `idDocenteEncargado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `grupos`
--
ALTER TABLE `grupos`
  MODIFY `idGrupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  MODIFY `idHorario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `semestre_academico`
--
ALTER TABLE `semestre_academico`
  MODIFY `id_semestre` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `sustentacion`
--
ALTER TABLE `sustentacion`
  MODIFY `idSustentacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD CONSTRAINT `alumno_ibfk_1` FOREIGN KEY (`id_semestre`) REFERENCES `semestre_academico` (`id_semestre`),
  ADD CONSTRAINT `alumno_ibfk_2` FOREIGN KEY (`GruposGrupo`) REFERENCES `grupos` (`idGrupo`),
  ADD CONSTRAINT `sustentacion_ibfk_3` FOREIGN KEY (`Sustentacion_id`) REFERENCES `sustentacion` (`idSustentacion`);

--
-- Filtros para la tabla `docente_encargado`
--
ALTER TABLE `docente_encargado`
  ADD CONSTRAINT `docente_encargado_ibfk_1` FOREIGN KEY (`AlumnoIdAlumno`) REFERENCES `alumno` (`codAlumno`),
  ADD CONSTRAINT `docente_encargado_ibfk_2` FOREIGN KEY (`jurado1`) REFERENCES `docentes` (`id_docentes`),
  ADD CONSTRAINT `docente_encargado_ibfk_3` FOREIGN KEY (`jurado2`) REFERENCES `docentes` (`id_docentes`),
  ADD CONSTRAINT `docente_encargado_ibfk_4` FOREIGN KEY (`asesor`) REFERENCES `docentes` (`id_docentes`);

--
-- Filtros para la tabla `docente_semestre`
--
ALTER TABLE `docente_semestre`
  ADD CONSTRAINT `docente_semestre_ibfk_1` FOREIGN KEY (`id_semestre`) REFERENCES `semestre_academico` (`id_semestre`),
  ADD CONSTRAINT `docente_semestre_ibfk_2` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`);

--
-- Filtros para la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD CONSTRAINT `grupos_ibfk_2` FOREIGN KEY (`CursoIdCurso`) REFERENCES `curso` (`idCurso`),
  ADD CONSTRAINT `grupos_ibfk_3` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`);

--
-- Filtros para la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  ADD CONSTRAINT `horario_disponible_docente_ibfk_1` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`);

--
-- Filtros para la tabla `sustentacion`
--
ALTER TABLE `sustentacion`
  ADD CONSTRAINT `sustentacion_ibfk_1` FOREIGN KEY (`GruposGrupo`) REFERENCES `grupos` (`idGrupo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
