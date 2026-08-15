-- =============================================================================
-- Script generado para SQL Server
-- Base de datos: investigacion
-- =============================================================================

IF DB_ID(N'investigacion') IS NULL
    CREATE DATABASE [investigacion];
GO

USE [investigacion];
GO

-- =============================================================================
-- Base de datos: investigacion
-- Módulo: Investigación
-- Tablas del módulo: 16
-- Tablas de gestión de usuarios: 3
-- Total de tablas: 19
-- =============================================================================


-- =============================================
-- TABLAS DEL MÓDULO: INVESTIGACIÓN
-- =============================================

-- Tabla: area_conocimiento
CREATE TABLE area_conocimiento (
    id INT NOT NULL,
    gran_area VARCHAR(60) NOT NULL,
    area VARCHAR(60) NOT NULL,
    disciplina VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: objetivo_desarrollo_sostenible
CREATE TABLE objetivo_desarrollo_sostenible (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    categoria VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: area_aplicacion
CREATE TABLE area_aplicacion (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: termino_clave
CREATE TABLE termino_clave (
    termino VARCHAR(30) NOT NULL,
    termino_ingles VARCHAR(30),
    PRIMARY KEY (termino)
);

-- Tabla: universidad
CREATE TABLE universidad (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    ciudad VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: linea_investigacion
CREATE TABLE linea_investigacion (
    id INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(256) NOT NULL,
    PRIMARY KEY (id)
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

-- Tabla: grupo_investigacion
CREATE TABLE grupo_investigacion (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    url_gruplac VARCHAR(128),
    categoria VARCHAR(10),
    convocatoria VARCHAR(10),
    fecha_fundacion DATE NOT NULL,
    universidsad INT,
    interno TINYINT NOT NULL,
    ambito VARCHAR(45) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (universidsad) REFERENCES universidad(id)
);

-- Tabla: semillero
CREATE TABLE semillero (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    fecha_fundacion DATE NOT NULL,
    grupo_investigacion INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (grupo_investigacion) REFERENCES grupo_investigacion(id)
);

-- Tabla: participa_semillero
CREATE TABLE participa_semillero (
    docente INT NOT NULL,
    semillero INT NOT NULL,
    rol VARCHAR(15) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (docente, semillero),
    FOREIGN KEY (docente) REFERENCES docente(cedula),
    FOREIGN KEY (semillero) REFERENCES semillero(id)
);

-- Tabla: participa_grupo
CREATE TABLE participa_grupo (
    docente_cedula INT NOT NULL,
    grupo_investigacion_id INT NOT NULL,
    rol VARCHAR(15) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (docente_cedula, grupo_investigacion_id),
    FOREIGN KEY (docente_cedula) REFERENCES docente(cedula),
    FOREIGN KEY (grupo_investigacion_id) REFERENCES grupo_investigacion(id)
);

-- Tabla: semillero_linea
CREATE TABLE semillero_linea (
    semillero INT NOT NULL,
    linea_investigacion INT NOT NULL,
    PRIMARY KEY (semillero, linea_investigacion),
    FOREIGN KEY (semillero) REFERENCES semillero(id),
    FOREIGN KEY (linea_investigacion) REFERENCES linea_investigacion(id)
);

-- Tabla: grupo_linea
CREATE TABLE grupo_linea (
    grupo_investigacion INT NOT NULL,
    linea_investigacion INT NOT NULL,
    PRIMARY KEY (grupo_investigacion, linea_investigacion),
    FOREIGN KEY (grupo_investigacion) REFERENCES grupo_investigacion(id),
    FOREIGN KEY (linea_investigacion) REFERENCES linea_investigacion(id)
);

-- Tabla: ac_linea
CREATE TABLE ac_linea (
    linea_investigacion INT NOT NULL,
    area_conocimiento INT NOT NULL,
    PRIMARY KEY (linea_investigacion, area_conocimiento),
    FOREIGN KEY (linea_investigacion) REFERENCES linea_investigacion(id),
    FOREIGN KEY (area_conocimiento) REFERENCES area_conocimiento(id)
);

-- Tabla: ods_linea
CREATE TABLE ods_linea (
    linea_investigacion INT NOT NULL,
    ods INT NOT NULL,
    PRIMARY KEY (linea_investigacion, ods),
    FOREIGN KEY (linea_investigacion) REFERENCES linea_investigacion(id),
    FOREIGN KEY (ods) REFERENCES objetivo_desarrollo_sostenible(id)
);

-- Tabla: aa_linea
CREATE TABLE aa_linea (
    area_aplicacion INT NOT NULL,
    linea_investigacion INT NOT NULL,
    PRIMARY KEY (area_aplicacion, linea_investigacion),
    FOREIGN KEY (area_aplicacion) REFERENCES area_aplicacion(id),
    FOREIGN KEY (linea_investigacion) REFERENCES linea_investigacion(id)
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
