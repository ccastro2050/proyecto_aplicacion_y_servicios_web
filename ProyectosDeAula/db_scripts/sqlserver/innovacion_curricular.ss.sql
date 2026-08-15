-- =============================================================================
-- Script generado para SQL Server
-- Base de datos: innovacion_curricular
-- =============================================================================

IF DB_ID(N'innovacion_curricular') IS NULL
    CREATE DATABASE [innovacion_curricular];
GO

USE [innovacion_curricular];
GO

-- =============================================================================
-- Base de datos: innovacion_curricular
-- Módulo: Innovación Curricular
-- Tablas del módulo: 22
-- Tablas de gestión de usuarios: 3
-- Total de tablas: 25
-- =============================================================================


-- =============================================
-- TABLAS DEL MÓDULO: INNOVACIÓN CURRICULAR
-- =============================================

-- Tabla: area_conocimiento
CREATE TABLE area_conocimiento (
    id INT NOT NULL,
    gran_area VARCHAR(60) NOT NULL,
    area VARCHAR(60) NOT NULL,
    disciplina VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: universidad
CREATE TABLE universidad (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    ciudad VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: aspecto_normativo
CREATE TABLE aspecto_normativo (
    id INT NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    fuente VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: practica_estrategia
CREATE TABLE practica_estrategia (
    id INT NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: enfoque
CREATE TABLE enfoque (
    id INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: car_innovacion
CREATE TABLE car_innovacion (
    id INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(MAX) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

-- Tabla: aliado
CREATE TABLE aliado (
    nit INT NOT NULL,
    razon_social VARCHAR(60) NOT NULL,
    nombre_contacto VARCHAR(60) NOT NULL,
    correo VARCHAR(70) NOT NULL,
    telefono VARCHAR(45) NOT NULL,
    ciudad VARCHAR(45) NOT NULL,
    PRIMARY KEY (nit)
);

-- Tabla: facultad
CREATE TABLE facultad (
    id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    fecha_fun DATE NOT NULL,
    universidad INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (universidad) REFERENCES universidad(id)
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
    PRIMARY KEY (id),
    FOREIGN KEY (facultad) REFERENCES facultad(id)
);

-- Tabla: acreditacion
CREATE TABLE acreditacion (
    resolucion INT NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    calificacion VARCHAR(45) NOT NULL,
    fecha_inicio VARCHAR(45) NOT NULL,
    fecha_fin VARCHAR(45) NOT NULL,
    programa INT NOT NULL,
    PRIMARY KEY (resolucion),
    FOREIGN KEY (programa) REFERENCES programa(id)
);

-- Tabla: registro_calificado
CREATE TABLE registro_calificado (
    codigo INT NOT NULL,
    cant_creditos VARCHAR(45) NOT NULL,
    hora_acom VARCHAR(45) NOT NULL,
    hora_ind VARCHAR(45) NOT NULL,
    metodologia VARCHAR(45) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    duracion_anios VARCHAR(45) NOT NULL,
    duracion_semestres VARCHAR(45) NOT NULL,
    tipo_titulacion VARCHAR(45) NOT NULL,
    programa INT NOT NULL,
    PRIMARY KEY (codigo),
    FOREIGN KEY (programa) REFERENCES programa(id)
);

-- Tabla: activ_academica
CREATE TABLE activ_academica (
    id INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    num_creditos INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    area_formacion VARCHAR(45) NOT NULL,
    h_acom INT NOT NULL,
    h_indep INT NOT NULL,
    idioma VARCHAR(45) NOT NULL,
    espejo TINYINT NOT NULL,
    entidad_espejo VARCHAR(45) NOT NULL,
    pais_espejo VARCHAR(45) NOT NULL,
    disenio INT,
    PRIMARY KEY (id),
    FOREIGN KEY (disenio) REFERENCES programa(id)
);

-- Tabla: pasantia
CREATE TABLE pasantia (
    id INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    pais VARCHAR(45) NOT NULL,
    empresa VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    programa INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (programa) REFERENCES programa(id)
);

-- Tabla: premio
CREATE TABLE premio (
    id INT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(45) NOT NULL,
    fecha DATE NOT NULL,
    entidad_otorgante VARCHAR(45) NOT NULL,
    pais VARCHAR(45) NOT NULL,
    programa INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (programa) REFERENCES programa(id)
);

-- Tabla: programa_ac
CREATE TABLE programa_ac (
    programa INT NOT NULL,
    area_conocimiento INT NOT NULL,
    PRIMARY KEY (programa, area_conocimiento),
    FOREIGN KEY (programa) REFERENCES programa(id),
    FOREIGN KEY (area_conocimiento) REFERENCES area_conocimiento(id)
);

-- Tabla: programa_pe
CREATE TABLE programa_pe (
    programa INT NOT NULL,
    practica_estrategia INT NOT NULL,
    PRIMARY KEY (programa, practica_estrategia),
    FOREIGN KEY (programa) REFERENCES programa(id),
    FOREIGN KEY (practica_estrategia) REFERENCES practica_estrategia(id)
);

-- Tabla: programa_ci
CREATE TABLE programa_ci (
    programa INT NOT NULL,
    car_innovacion INT NOT NULL,
    PRIMARY KEY (programa, car_innovacion),
    FOREIGN KEY (programa) REFERENCES programa(id),
    FOREIGN KEY (car_innovacion) REFERENCES car_innovacion(id)
);

-- Tabla: an_programa
CREATE TABLE an_programa (
    aspecto_normativo INT NOT NULL,
    programa INT NOT NULL,
    PRIMARY KEY (aspecto_normativo, programa),
    FOREIGN KEY (aspecto_normativo) REFERENCES aspecto_normativo(id),
    FOREIGN KEY (programa) REFERENCES programa(id)
);

-- Tabla: enfoque_rc
CREATE TABLE enfoque_rc (
    enfoque INT NOT NULL,
    registro_calificado INT NOT NULL,
    PRIMARY KEY (enfoque, registro_calificado),
    FOREIGN KEY (enfoque) REFERENCES enfoque(id),
    FOREIGN KEY (registro_calificado) REFERENCES registro_calificado(codigo)
);

-- Tabla: aa_rc
CREATE TABLE aa_rc (
    activ_academicas_idcurso INT NOT NULL,
    registro_calificado_codigo INT NOT NULL,
    componente VARCHAR(45) NOT NULL,
    semestre VARCHAR(45) NOT NULL,
    PRIMARY KEY (activ_academicas_idcurso, registro_calificado_codigo),
    FOREIGN KEY (activ_academicas_idcurso) REFERENCES activ_academica(id),
    FOREIGN KEY (registro_calificado_codigo) REFERENCES registro_calificado(codigo)
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
    FOREIGN KEY (departamento) REFERENCES programa(id)
);

-- Tabla: alianza
CREATE TABLE alianza (
    aliado INT NOT NULL,
    departamento INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    docente INT,
    PRIMARY KEY (aliado, departamento),
    FOREIGN KEY (aliado) REFERENCES aliado(nit),
    FOREIGN KEY (departamento) REFERENCES programa(id)
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
