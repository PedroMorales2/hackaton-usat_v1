-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-06-2024 a las 08:41:45
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `AsignarJuradosAutomaticamente` ()   BEGIN
    DECLARE v_id_docente INT;
    DECLARE v_jurado1 INT;
    DECLARE v_jurado2 INT;
    DECLARE v_id_encargado INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR
        SELECT idDocenteEncargado, asesor FROM docente_encargado 
        WHERE jurado1 IS NULL AND jurado2 IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Verifica primero si hay suficientes docentes disponibles
    IF ((SELECT COUNT(*) FROM docentes WHERE status = 1) >= 3) THEN
        OPEN cur;

        read_loop: LOOP
            FETCH cur INTO v_id_encargado, v_id_docente;
            IF done THEN
                LEAVE read_loop;
            END IF;

            -- Seleccionar los dos jurados aleatoriamente
            SELECT id_docentes INTO v_jurado1 FROM docentes 
            WHERE id_docentes <> v_id_docente AND status = 1
            ORDER BY RAND() LIMIT 1;

            SELECT id_docentes INTO v_jurado2 FROM docentes 
            WHERE id_docentes <> v_id_docente AND id_docentes <> v_jurado1 AND status = 1
            ORDER BY RAND() LIMIT 1;

            -- Asignar jurados
            UPDATE docente_encargado
            SET jurado1 = v_jurado1, jurado2 = v_jurado2
            WHERE idDocenteEncargado = v_id_encargado;

        END LOOP;

        CLOSE cur;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes docentes disponibles para asignar como jurados.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarSustentacionYJurados` (IN `p_nombre_asesor` VARCHAR(100), IN `p_nombre_nombreAlumno` VARCHAR(100), IN `p_nombre_email` VARCHAR(100), IN `p_nombre_telefono` VARCHAR(20), IN `p_nombre_titulo` VARCHAR(100), IN `p_id_sustentacion` INT, IN `p_nombre_codigo` VARCHAR(20))   BEGIN
    DECLARE v_id_docente INT;
    DECLARE v_id_alumno INT;
    DECLARE v_jurado1 INT;
    DECLARE v_jurado2 INT;

    -- Encuentra el id del asesor
	SELECT id_docentes INTO v_id_docente FROM docentes WHERE nombre = p_nombre_asesor ORDER BY id_docentes DESC LIMIT 1;


    -- Inserta el alumno
    INSERT INTO alumno(nombre_completo, email, telefono, titulo_tesis, Sustentacion_id, codigo_universitario) 
    VALUES(p_nombre_nombreAlumno, p_nombre_email, p_nombre_telefono, p_nombre_titulo, p_id_sustentacion, p_nombre_codigo);
    SET v_id_alumno = LAST_INSERT_ID();
    
    -- Inserta el asesor
    INSERT INTO docente_encargado(asesor, AlumnoIdAlumno) 
    VALUES(v_id_docente, v_id_alumno);

    -- Verificar la cantidad de docentes disponibles
    SELECT COUNT(*) INTO @num_available FROM docentes WHERE id_docentes <> v_id_docente AND status = 1;
    
    -- Si hay menos de dos docentes disponibles, abortar
    IF @num_available < 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes docentes disponibles para ser jurados.';
    END IF;

    -- Seleccionar los dos jurados aleatoriamente
    SELECT id_docentes INTO v_jurado1 FROM docentes 
    WHERE id_docentes <> v_id_docente AND status = 1
    ORDER BY RAND() LIMIT 1;

    SELECT id_docentes INTO v_jurado2 FROM docentes 
    WHERE id_docentes <> v_id_docente AND id_docentes <> v_jurado1 AND status = 1
    ORDER BY RAND() LIMIT 1;

    -- Asignar jurados
    UPDATE docente_encargado
    SET jurado1 = v_jurado1, jurado2 = v_jurado2
    WHERE idDocenteEncargado = v_id_alumno;
    
     CALL AsignarJuradosAutomaticamente();

    COMMIT;
END$$

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
    INSERT INTO docentes (nombre, correo, dedicacion, telefono, status) 
    VALUES (p_nombre, p_correo, p_dedicacion, p_telefono, 1);
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
  `codigo_universitario` varchar(100) DEFAULT NULL,
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
(192, '201TD01159', 'Falu Sanchez', 'electronico4208978@gmail.com', '923505083', 'IA', NULL, NULL, 35),
(193, '201TD01160', 'juan perez', 'electronico4208978@gmail.com', '923505083', 'DSI', NULL, NULL, 35),
(194, '201TD01161', 'juan velazques', 'electronico4208978@gmail.com', '923505083', 'BI', NULL, NULL, 35),
(195, '201TD01162', 'juana renteros', 'electronico4208978@gmail.com', '923505083', 'IA', NULL, NULL, 35),
(196, '201TD01163', 'juan opayanqui', 'electronico4208978@gmail.com', '923505083', 'DSI', NULL, NULL, 35),
(197, '201TD01164', 'juliano sopilan', 'electronico4208978@gmail.com', '923505083', 'BI', NULL, NULL, 35),
(198, '201TD01165', 'catalina santamaria', 'electronico4208978@gmail.com', '923505083', 'IA', NULL, NULL, 35),
(199, '201TD01166', 'junion mera', 'electronico4208978@gmail.com', '923505083', 'DSI', NULL, NULL, 35),
(200, '201TD01167', 'juan villalobos', 'electronico4208978@gmail.com', '923505083', 'BI', NULL, NULL, 35),
(201, '201TD01168', 'somma andree', 'electronico4208978@gmail.com', '923505083', 'IA', NULL, NULL, 35),
(202, '201TD01169', 'aser pedro', 'electronico4208978@gmail.com', '923505083', 'DSI', NULL, NULL, 35),
(203, '201TD01170', 'diego parras', 'electronico4208978@gmail.com', '923505083', 'BI', NULL, NULL, 35),
(204, '201TD01171', 'juan parras', 'electronico4208978@gmail.com', '923505083', 'IA', NULL, NULL, 35),
(205, '201TD01172', 'santiago parras', 'electronico4208978@gmail.com', '923505083', 'DSI', NULL, NULL, 35);

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
(5, 'Seminario de Tesis I');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentes`
--

CREATE TABLE `docentes` (
  `id_docentes` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `dedicacion` varchar(50) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `contrasena` varchar(100) DEFAULT NULL,
  `status` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `docentes`
--

INSERT INTO `docentes` (`id_docentes`, `nombre`, `correo`, `dedicacion`, `telefono`, `contrasena`, `status`) VALUES
(50, 'JUANITO HUILDER', 'juanito@gmail.com', 'TC', '923505083', '123', 1),
(51, 'FALU SANCHEZ', 'fal@gmail.com', 'TP', '923505083', NULL, 1),
(52, 'PEDRO MORALES', 'pedro@gmail.com', 'TC', '923505083', '123', 1),
(53, 'YAMIR ACOSTA', 'yamir@gmail.com', 'TC', '923505083', NULL, 1),
(54, 'RUTH CARINA', 'ruth@gmail.com', 'TC', '923505083', NULL, 1),
(55, 'JUAN PEREZ', 'juan@gmail.com', 'TC', '923505083', NULL, 1),
(56, 'JUANITA MORALES', 'juanita@gmail.com', 'TC', '923505083', NULL, 1),
(57, 'SOL CAREN', 'sol@gmail.com', 'TP', '923505083', NULL, 1),
(58, 'CAREN MERA', 'caren@gmail.com', 'TP', '923505083', NULL, 1),
(59, 'JUANA VILLALOBOS', 'juana@gmail.com', 'TP', '923505083', NULL, 1),
(60, 'Algimantas', 'algimantas@gmail.com', 'TP', '923505083', NULL, 1),
(61, 'Alpidio', 'alpidio@gmail.com', 'TP', '923505083', NULL, 1),
(62, 'Amrane', 'amrane@gmail.com', 'TP', '923505083', NULL, 1),
(63, 'Anish', 'anish@gmail.com', 'TP', '923505083', NULL, 1),
(64, 'Arián', 'aria@gmail.com', 'TP', '923505083', NULL, 1),
(65, 'Ayun', 'ayun@gmail.com', 'TC', '923505083', NULL, 1),
(66, 'Azariel', 'azariel@gmail.com', 'TC', '923505083', NULL, 1),
(67, 'Bagrat', 'bagrat@gmail.com', 'TC', '923505083', NULL, 1),
(68, 'Bencomo', 'bencomo@gmail.com', 'TP', '923505083', NULL, 1),
(69, 'Bertino', 'bertino@gmail.com', 'TP', '923505083', NULL, 1),
(70, 'Candi', 'candi@gmail.com', 'TP', '923505083', NULL, 1),
(71, 'admin', 'admin', NULL, NULL, '123', 0),
(93, 'JUANITO HUILDER', 'juanito@gmail.com', 'TC', '923505083', '123', 1),
(94, 'FALU SANCHEZ', 'fal@gmail.com', 'TP', '923505083', '123', 1),
(95, 'PEDRO MORALES', 'pedro@gmail.com', 'TC', '923505083', NULL, 1),
(96, 'YAMIR ACOSTA', 'yamir@gmail.com', 'TC', '923505083', NULL, 1),
(97, 'RUTH CARINA', 'ruth@gmail.com', 'TC', '923505083', NULL, 1),
(98, 'JUAN PEREZ', 'juan@gmail.com', 'TC', '923505083', NULL, 1),
(99, 'JUANITA MORALES', 'juanita@gmail.com', 'TC', '923505083', NULL, 1),
(100, 'SOL CAREN', 'sol@gmail.com', 'TP', '923505083', NULL, 1),
(101, 'CAREN MERA', 'caren@gmail.com', 'TP', '923505083', NULL, 1),
(102, 'JUANA VILLALOBOS', 'juana@gmail.com', 'TP', '923505083', NULL, 1),
(103, 'Algimantas', 'algimantas@gmail.com', 'TP', '923505083', NULL, 1),
(104, 'Alpidio', 'alpidio@gmail.com', 'TP', '923505083', NULL, 1),
(105, 'Amrane', 'amrane@gmail.com', 'TP', '923505083', NULL, 1),
(106, 'Anish', 'anish@gmail.com', 'TP', '923505083', NULL, 1),
(107, 'Arián', 'aria@gmail.com', 'TP', '923505083', NULL, 1),
(108, 'Ayun', 'ayun@gmail.com', 'TC', '923505083', NULL, 1),
(109, 'Azariel', 'azariel@gmail.com', 'TC', '923505083', NULL, 1),
(110, 'Bagrat', 'bagrat@gmail.com', 'TC', '923505083', NULL, 1),
(111, 'Bencomo', 'bencomo@gmail.com', 'TP', '923505083', NULL, 1),
(112, 'Bertino', 'bertino@gmail.com', 'TP', '923505083', NULL, 1),
(113, 'Candi', 'candi@gmail.com', 'TP', '923505083', NULL, 1),
(114, 'JUANITO HUILDER', 'juanito@gmail.com', 'TC', '923505083', '123', 1),
(115, 'FALU SANCHEZ', 'fal@gmail.com', 'TP', '923505083', '123', 1),
(116, 'PEDRO MORALES', 'pedro@gmail.com', 'TC', '923505083', '123', 1),
(117, 'YAMIR ACOSTA', 'yamir@gmail.com', 'TC', '923505083', NULL, 1),
(118, 'RUTH CARINA', 'ruth@gmail.com', 'TC', '923505083', NULL, 1),
(119, 'JUAN PEREZ', 'juan@gmail.com', 'TC', '923505083', NULL, 1),
(120, 'JUANITA MORALES', 'juanita@gmail.com', 'TC', '923505083', NULL, 1),
(121, 'SOL CAREN', 'sol@gmail.com', 'TP', '923505083', NULL, 1),
(122, 'CAREN MERA', 'caren@gmail.com', 'TP', '923505083', NULL, 1),
(123, 'JUANA VILLALOBOS', 'juana@gmail.com', 'TP', '923505083', NULL, 1),
(124, 'Algimantas', 'algimantas@gmail.com', 'TP', '923505083', NULL, 1),
(125, 'Alpidio', 'alpidio@gmail.com', 'TP', '923505083', NULL, 1),
(126, 'Amrane', 'amrane@gmail.com', 'TP', '923505083', NULL, 1),
(127, 'Anish', 'anish@gmail.com', 'TP', '923505083', NULL, 1),
(128, 'Arián', 'aria@gmail.com', 'TP', '923505083', NULL, 1),
(129, 'Ayun', 'ayun@gmail.com', 'TC', '923505083', NULL, 1),
(130, 'Azariel', 'azariel@gmail.com', 'TC', '923505083', NULL, 1),
(131, 'Bagrat', 'bagrat@gmail.com', 'TC', '923505083', NULL, 1),
(132, 'Bencomo', 'bencomo@gmail.com', 'TP', '923505083', '123', 1),
(133, 'Bertino', 'bertino@gmail.com', 'TP', '923505083', NULL, 1),
(134, 'Candi', 'candi@gmail.com', 'TP', '923505083', NULL, 1);

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
(156, 192, 100, 104, 116),
(157, 193, 133, 94, 116),
(158, 194, 53, 114, 116),
(159, 195, 58, 98, 125),
(160, 196, 93, 109, 125),
(161, 197, 117, 100, 125),
(162, 198, 103, 59, 125),
(163, 199, 116, 127, 117),
(164, 200, 125, 122, 117),
(165, 201, 133, 103, 117),
(166, 202, 60, 122, 117),
(167, 203, 54, 115, 117),
(168, 204, 116, 122, 117),
(169, 205, 116, 66, 117);

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
(30, 50, 6),
(30, 51, 5),
(30, 52, 1),
(30, 53, 5),
(30, 54, 6),
(30, 55, 9),
(30, 56, 7),
(30, 57, 2),
(30, 58, 3),
(30, 59, 1),
(30, 60, 2),
(30, 61, 3),
(30, 62, 5),
(30, 63, 6),
(30, 64, 1),
(30, 65, 2),
(30, 66, 3),
(30, 67, 6),
(30, 68, 4),
(30, 69, 6),
(30, 70, 6),
(31, 93, 6),
(31, 94, 5),
(31, 95, 1),
(31, 96, 5),
(31, 97, 6),
(31, 98, 9),
(31, 99, 7),
(31, 100, 2),
(31, 101, 3),
(31, 102, 1),
(31, 103, 2),
(31, 104, 3),
(31, 105, 5),
(31, 106, 6),
(31, 107, 1),
(31, 108, 2),
(31, 109, 3),
(31, 110, 6),
(31, 111, 4),
(31, 112, 6),
(31, 113, 6),
(32, 114, 6),
(32, 115, 5),
(32, 116, 1),
(32, 117, 5),
(32, 118, 6),
(32, 119, 9),
(32, 120, 7),
(32, 121, 2),
(32, 122, 3),
(32, 123, 1),
(32, 124, 2),
(32, 125, 3),
(32, 126, 5),
(32, 127, 6),
(32, 128, 1),
(32, 129, 2),
(32, 130, 3),
(32, 131, 6),
(32, 132, 4),
(32, 133, 6),
(32, 134, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `idGrupo` int(11) NOT NULL,
  `denominacion` char(1) DEFAULT NULL,
  `id_semestre` int(11) NOT NULL,
  `CursoIdCurso` int(11) DEFAULT NULL,
  `id_docentes` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `grupos`
--

INSERT INTO `grupos` (`idGrupo`, `denominacion`, `id_semestre`, `CursoIdCurso`, `id_docentes`) VALUES
(30, 'B', 30, 1, 53),
(31, 'B', 31, 5, 97),
(32, 'A', 31, 1, 94),
(33, 'A', 32, 1, 114),
(34, 'B', 32, 1, 114);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario_disponible_docente`
--

CREATE TABLE `horario_disponible_docente` (
  `idHorario` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `id_docentes` int(11) DEFAULT NULL,
  `id_sustentacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `horario_disponible_docente`
--

INSERT INTO `horario_disponible_docente` (`idHorario`, `fecha`, `hora_inicio`, `hora_fin`, `id_docentes`, `id_sustentacion`) VALUES
(46, '2024-01-04', '23:41:00', '22:48:00', 52, 29),
(47, '2024-02-07', '02:54:00', '09:39:00', 116, 35),
(48, '2024-02-05', '02:03:00', '18:06:00', 114, 35),
(49, '2024-02-07', '02:03:00', '18:06:00', 114, 35);

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
(30, '2024-02-13', '2024-06-29', 0, '2024-1'),
(31, '2024-07-25', '2024-12-03', 0, '2024-2'),
(32, '2024-01-22', '2024-02-03', 1, '2024-0');

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
(29, 'parcial', '1,2', '2024-01-01', '2024-01-14', 30, 1, 30),
(30, 'parcial', '6,7', '2024-02-11', '2024-02-24', 30, 1, 31),
(33, 'final', '5,6', '2024-01-29', '2024-02-11', 60, 1, 32),
(34, 'final', '5,6', '2024-01-29', '2024-02-11', 60, 1, 33),
(35, 'final', '6,7', '2024-02-05', '2024-02-18', 60, 1, 34);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumno`
--
ALTER TABLE `alumno`
  ADD PRIMARY KEY (`codAlumno`),
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
  ADD KEY `docente_encargado_ibfk_2` (`jurado1`),
  ADD KEY `docente_encargado_ibfk_3` (`jurado2`),
  ADD KEY `docente_encargado_ibfk_4` (`asesor`),
  ADD KEY `docente_encargado_ibfk_1` (`AlumnoIdAlumno`);

--
-- Indices de la tabla `docente_semestre`
--
ALTER TABLE `docente_semestre`
  ADD PRIMARY KEY (`id_semestre`,`id_docentes`),
  ADD KEY `docente_semestre_ibfk_2` (`id_docentes`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`idGrupo`),
  ADD KEY `id_semestre` (`id_semestre`),
  ADD KEY `CursoIdCurso` (`CursoIdCurso`),
  ADD KEY `grupos_ibfk_3` (`id_docentes`);

--
-- Indices de la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  ADD PRIMARY KEY (`idHorario`),
  ADD KEY `horario_disponible_docente_ibfk_1` (`id_docentes`),
  ADD KEY `id_sustentacion` (`id_sustentacion`);

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
  ADD KEY `sustentacion_ibfk_1` (`GruposGrupo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumno`
--
ALTER TABLE `alumno`
  MODIFY `codAlumno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT de la tabla `curso`
--
ALTER TABLE `curso`
  MODIFY `idCurso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `docentes`
--
ALTER TABLE `docentes`
  MODIFY `id_docentes` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT de la tabla `docente_encargado`
--
ALTER TABLE `docente_encargado`
  MODIFY `idDocenteEncargado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170;

--
-- AUTO_INCREMENT de la tabla `grupos`
--
ALTER TABLE `grupos`
  MODIFY `idGrupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT de la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  MODIFY `idHorario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT de la tabla `semestre_academico`
--
ALTER TABLE `semestre_academico`
  MODIFY `id_semestre` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `sustentacion`
--
ALTER TABLE `sustentacion`
  MODIFY `idSustentacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

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
  ADD CONSTRAINT `docente_encargado_ibfk_1` FOREIGN KEY (`AlumnoIdAlumno`) REFERENCES `alumno` (`codAlumno`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `docente_encargado_ibfk_2` FOREIGN KEY (`jurado1`) REFERENCES `docentes` (`id_docentes`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `docente_encargado_ibfk_3` FOREIGN KEY (`jurado2`) REFERENCES `docentes` (`id_docentes`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `docente_encargado_ibfk_4` FOREIGN KEY (`asesor`) REFERENCES `docentes` (`id_docentes`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `docente_semestre`
--
ALTER TABLE `docente_semestre`
  ADD CONSTRAINT `docente_semestre_ibfk_1` FOREIGN KEY (`id_semestre`) REFERENCES `semestre_academico` (`id_semestre`),
  ADD CONSTRAINT `docente_semestre_ibfk_2` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD CONSTRAINT `grupos_ibfk_2` FOREIGN KEY (`CursoIdCurso`) REFERENCES `curso` (`idCurso`),
  ADD CONSTRAINT `grupos_ibfk_3` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Filtros para la tabla `horario_disponible_docente`
--
ALTER TABLE `horario_disponible_docente`
  ADD CONSTRAINT `horario_disponible_docente_ibfk_1` FOREIGN KEY (`id_docentes`) REFERENCES `docentes` (`id_docentes`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sustentacion_disponible_ibfk_1` FOREIGN KEY (`id_sustentacion`) REFERENCES `sustentacion` (`idSustentacion`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `sustentacion`
--
ALTER TABLE `sustentacion`
  ADD CONSTRAINT `sustentacion_ibfk_1` FOREIGN KEY (`GruposGrupo`) REFERENCES `grupos` (`idGrupo`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
