# Proyecto de aula — Módulo: Gestión Profesoral

> **Base de datos:** `gestion_profesoral` · **19 tablas** (16 del módulo +
> 3 de gestión de usuarios) · Caso diseñado por: Carlos Arturo Castro Castro.
>
> La metodología (SDD por versiones, spec kit, ramas de Git, secretos por
> variables de entorno, rúbrica) está en **[0_METODOLOGIA.md](0_METODOLOGIA.md)**
> y es OBLIGATORIA. Este documento define el QUÉ de este módulo. El script
> de la BD está en `db_scripts/sqlserver/gestion_profesoral.ss.sql` y los
> datos de referencia en el Excel de `Mapa_conocimiento/`.

---

## 1. Contexto

Una Universidad con sedes y seccionales en varias ciudades trabaja en un
Sistema de Información para gestionar el conocimiento generado desde sus
diferentes instancias. El sistema tiene 6 módulos; **cada equipo construye
su módulo en su propia base de datos independiente**, incluyendo las
tablas de gestión de usuarios.

**Este módulo** administra la información de los docentes: datos
personales, estudios, becas, apoyos profesorales, evaluaciones,
reconocimientos, experiencia laboral, redes académicas e intereses de
investigación; y su vinculación a programas académicos y líneas de
investigación.

## 2. Las tablas, organizadas por versión

### v1 — Tablas SIN claves foráneas (5)

| Tabla | Qué es | Datos del Excel |
|---|---|---|
| `area_conocimiento` | Catálogo jerárquico: gran_area → area → disciplina (id, gran_area, area, disciplina) | 218 registros |
| `termino_clave` | Keywords con traducción (termino PK, termino_ingles) | — |
| `linea_investigacion` | Líneas de investigación (id autoincremental, nombre, descripcion) | — |
| `programa` | Programas académicos (id, nombre, tipo, nivel, fechas, cohortes, graduados, ciudad, facultad) | 191 registros |
| `red` | Redes académicas (idr PK, nombre, url, pais) | — |

### v2 — Tablas CON claves foráneas (11)

| Tabla | Qué es |
|---|---|
| `docente` | La tabla central: cedula (PK), datos personales, url_cvlac, escalafón, categoría Minciencias, perfil, linea_investigacion_principal (FK) |
| `estudios_realizados` | Estudios por docente: titulo, universidad, fecha, tipo (Pregrado/Maestría/Doctorado…), docente (FK) |
| `docente_departamento` | Vinculación docente↔programa: dedicación, modalidad, fechas |
| `intereses_futuros` | Puente docente↔termino_clave (intereses de investigación) |
| `evaluacion_docente` | Calificación por semestre, docente (FK) |
| `reconocimiento` | Tipo, fecha, institución, ámbito, docente (FK) |
| `experiecia` | Cargo, institución, tipo, fechas, docente (FK) *(así, con su errata histórica)* |
| `red_docente` | Puente red↔docente con fechas y actividades destacadas |
| `estudio_ac` | Puente estudios_realizados↔area_conocimiento |
| `apoyo_profesoral` | Apoyo institucional por estudio (estudios FK/PK, con_apoyo, institución, tipo) |
| `beca` | Beca por estudio (estudios FK/PK, tipo, institución, fechas) |

### v3 — Tablas de gestión de usuarios (3)

| Tabla | Columnas |
|---|---|
| `rol` | id, nombre, descripcion, activo, fecha_creacion |
| `usuario` | id, username, **password (hasheada, jamás en texto plano)**, email, nombre_completo, activo, fechas |
| `rol_usuario` | usuario_id (FK), rol_id (FK) |

## 3. La ruta de versiones del módulo

Cada versión se ESPECIFICA antes de construirse (spec kit en
`docs/spec_kit/versiones/` del repo de la API — el molde son los repos del
curso) y se cierra con criterios de aceptación + tag.

| Versión | Qué agrega | Cierre (además de la regresión de las anteriores) |
|---|---|---|
| **v1** | CRUD completo (API + Front) de las **5 tablas sin FK**, con los catálogos del Excel cargados | Los 5 CRUD funcionan de punta a punta; borrado lógico filtrando inactivos; tag `v1` |
| **v2** | CRUD de las **11 tablas con FK**: las FK como listas desplegables cargadas desde la API; validación de integridad referencial | Los 16 CRUD funcionan; crear un `estudios_realizados` exige un `docente` existente; tag `v2` |
| **v3** | `POST /api/login` con **JWT**; middleware de autenticación y autorización; menú por roles; CRUD de usuario/rol/rol_usuario **solo para administradores**; logout | Un usuario "consulta" no puede escribir; solo el admin ve usuarios/roles; tag `v3` |
| **v4** | **10 consultas multitabla** (4+ tablas: p. ej. "docentes con estudios de doctorado becados, por área de conocimiento y programa"), dashboard con gráficos, páginas corporativas con imagen propia, responsive/PWA, **publicación** | Sitio publicado y funcional con secretos en variables de entorno del servidor; tag `v4` |

## 4. Recordatorios innegociables (detalle en [0_METODOLOGIA.md](0_METODOLOGIA.md))

- **2 repos privados** (API y Frontend) con el profesor **`ccastro2050`**
  invitado desde el primer día.
- **Nadie trabaja en main**: cada estudiante en su rama; solo el
  **encargado del main** hace merge de los Pull Requests.
- **Cero secretos en el código**: cadena de conexión y `JWT_SECRET` por
  variables de entorno; `.env` en el `.gitignore`; `.env.example` en el
  repo. (En los repos del curso están quemados SOLO por didáctica — aquí no.)
- **La spec primero**: sin spec kit de la versión, la versión no se recibe.
