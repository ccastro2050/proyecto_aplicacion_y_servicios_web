-- =============================================================================
-- Script generado para SQL Server
-- Base de datos: gestion_profesoral
-- =============================================================================

IF DB_ID(N'gestion_profesoral') IS NULL
    CREATE DATABASE [gestion_profesoral];
GO

USE [gestion_profesoral];
GO

-- =============================================================================
-- Base de datos: gestion_profesoral
-- Módulo: Gestión Profesoral
-- Tablas del módulo: 16
-- Tablas de gestión de usuarios: 3
-- Total de tablas: 19
-- =============================================================================


-- =============================================
-- TABLAS DEL MÓDULO: GESTIÓN PROFESORAL
-- =============================================

-- Tabla: area_conocimiento
CREATE TABLE area_conocimiento (
    id INT NOT NULL,
    gran_area VARCHAR(60) NOT NULL,
    area VARCHAR(60) NOT NULL,
    disciplina VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: termino_clave
CREATE TABLE termino_clave (
    termino VARCHAR(30) NOT NULL,
    termino_ingles VARCHAR(30),
    PRIMARY KEY (termino)
);

-- Tabla: linea_investigacion
CREATE TABLE linea_investigacion (
    id INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(256) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: programa
CREATE TABLE programa (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    nivel VARCHAR(45) NOT NULL,
    fecha_creacion VARCHAR(45) NOT NULL,
    fecha_cierre VARCHAR(45),
    numero_cohortes VARCHAR(45) NOT NULL,
    cant_graduados VARCHAR(45) NOT NULL,
    fecha_actualizacion VARCHAR(45) NOT NULL,
    ciudad VARCHAR(45) NOT NULL,
    facultad INT NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: red
CREATE TABLE red (
    idr INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    url VARCHAR(45) NOT NULL,
    pais VARCHAR(45) NOT NULL,
    PRIMARY KEY (idr)
);

-- Tabla: docente
CREATE TABLE docente (
    cedula INT NOT NULL,
    nombres VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    genero VARCHAR(12) NOT NULL,
    cargo VARCHAR(30) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    correo VARCHAR(70) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    url_cvlac VARCHAR(128) NOT NULL,
    fecha_actualizacion DATE NOT NULL,
    escalafon VARCHAR(45) NOT NULL,
    perfil VARCHAR(MAX) NOT NULL,
    cat_minciencia VARCHAR(45),
    conv_minciencia VARCHAR(45) NOT NULL,
    nacionalidaad VARCHAR(45) NOT NULL,
    linea_investigacion_principal INT,
    PRIMARY KEY (cedula),
    FOREIGN KEY (linea_investigacion_principal) REFERENCES linea_investigacion(id)
);

-- Tabla: estudios_realizados
CREATE TABLE estudios_realizados (
    id INT NOT NULL,
    titulo VARCHAR(45) NOT NULL,
    universidad VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    ciudad VARCHAR(45) NOT NULL,
    docente INT NOT NULL,
    ins_acreditada TINYINT NOT NULL,
    metodologia VARCHAR(45) NOT NULL,
    perfil_egresado VARCHAR(MAX) NOT NULL,
    pais VARCHAR(45) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (docente) REFERENCES docente(cedula)
);

-- Tabla: docente_departamento
CREATE TABLE docente_departamento (
    docente INT NOT NULL,
    departamento INT NOT NULL,
    dedicacion VARCHAR(15) NOT NULL,
    modalidad VARCHAR(45) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_salida DATE,
    PRIMARY KEY (docente, departamento),
    FOREIGN KEY (docente) REFERENCES docente(cedula),
    FOREIGN KEY (departamento) REFERENCES programa(id)
);

-- Tabla: intereses_futuros
CREATE TABLE intereses_futuros (
    docente INT NOT NULL,
    termino_clave VARCHAR(30) NOT NULL,
    PRIMARY KEY (docente, termino_clave),
    FOREIGN KEY (docente) REFERENCES docente(cedula),
    FOREIGN KEY (termino_clave) REFERENCES termino_clave(termino)
);

-- Tabla: evaluacion_docente
CREATE TABLE evaluacion_docente (
    id INT IDENTITY(1,1) NOT NULL,
    calificacion REAL NOT NULL,
    semestre VARCHAR(45) NOT NULL,
    docente INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (docente) REFERENCES docente(cedula)
);

-- Tabla: reconocimiento
CREATE TABLE reconocimiento (
    id INT IDENTITY(1,1) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    fecha DATE NOT NULL,
    institucion VARCHAR(45) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    ambito VARCHAR(45) NOT NULL,
    docente INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (docente) REFERENCES docente(cedula)
);

-- Tabla: experiecia
CREATE TABLE experiecia (
    id INT IDENTITY(1,1) NOT NULL,
    nombre_cargo VARCHAR(45) NOT NULL,
    institucion VARCHAR(45) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    docente INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (docente) REFERENCES docente(cedula)
);

-- Tabla: red_docente
CREATE TABLE red_docente (
    red INT NOT NULL,
    docente INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin VARCHAR(45),
    act_destacadas VARCHAR(MAX) NOT NULL,
    PRIMARY KEY (red, docente),
    FOREIGN KEY (red) REFERENCES red(idr),
    FOREIGN KEY (docente) REFERENCES docente(cedula)
);

-- Tabla: estudio_ac
CREATE TABLE estudio_ac (
    estudio INT NOT NULL,
    area_conocimiento INT NOT NULL,
    PRIMARY KEY (estudio, area_conocimiento),
    FOREIGN KEY (estudio) REFERENCES estudios_realizados(id),
    FOREIGN KEY (area_conocimiento) REFERENCES area_conocimiento(id)
);

-- Tabla: apoyo_profesoral
CREATE TABLE apoyo_profesoral (
    estudios INT NOT NULL,
    con_apoyo TINYINT NOT NULL,
    institucion VARCHAR(45) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    PRIMARY KEY (estudios),
    FOREIGN KEY (estudios) REFERENCES estudios_realizados(id)
);

-- Tabla: beca
CREATE TABLE beca (
    estudios INT NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    institucion VARCHAR(80) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (estudios),
    FOREIGN KEY (estudios) REFERENCES estudios_realizados(id)
);


-- =============================================
-- MÓDULO DE GESTIÓN DE USUARIOS
-- =============================================

-- Tabla de roles
CREATE TABLE rol (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(MAX),
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE()
);

-- Tabla de usuarios
CREATE TABLE usuario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    nombre_completo VARCHAR(200),
    activo BIT DEFAULT 1,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_actualizacion DATETIME DEFAULT GETDATE()
);

-- Tabla de relación usuario-rol
CREATE TABLE rol_usuario (
    usuario_id INT NOT NULL,
    rol_id INT NOT NULL,
    PRIMARY KEY (usuario_id, rol_id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (rol_id) REFERENCES rol(id) ON DELETE CASCADE
);
