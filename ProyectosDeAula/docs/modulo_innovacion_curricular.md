# Proyecto de aula — Módulo: Innovación Curricular

> **Base de datos:** `innovacion_curricular` · **25 tablas** (22 del
> módulo + 3 de gestión de usuarios) · Caso diseñado por: Carlos Arturo
> Castro Castro.
>
> La metodología (SDD por versiones, spec kit, ramas de Git, secretos por
> variables de entorno, rúbrica) está en **[0_METODOLOGIA.md](0_METODOLOGIA.md)**
> y es OBLIGATORIA. Este documento define el QUÉ de este módulo. El script
> de la BD está en `db_scripts/sqlserver/innovacion_curricular.ss.sql` y
> los datos de referencia en el Excel de `Mapa_conocimiento/`.

---

## 1. Contexto

Una Universidad con sedes y seccionales en varias ciudades trabaja en un
Sistema de Información para gestionar el conocimiento generado desde sus
diferentes instancias. El sistema tiene 6 módulos; **cada equipo construye
su módulo en su propia base de datos independiente**, incluyendo las
tablas de gestión de usuarios.

**Este módulo** gestiona la estructura académica institucional:
universidades, facultades y programas con sus acreditaciones, registros
calificados y actividades académicas; los aspectos normativos, prácticas y
estrategias pedagógicas, enfoques y características de innovación; y las
pasantías, premios y alianzas con entidades externas.

## 2. Las tablas, organizadas por versión

### v1 — Tablas SIN claves foráneas (7)

| Tabla | Qué es | Datos del Excel |
|---|---|---|
| `area_conocimiento` | Catálogo jerárquico: gran_area → area → disciplina | 218 registros |
| `universidad` | Sedes y seccionales (id, nombre, tipo, ciudad) | 6 registros |
| `aspecto_normativo` | Leyes, decretos y normativas aplicables (id, tipo, descripcion, fuente) | — |
| `practica_estrategia` | Prácticas y estrategias pedagógicas (id, tipo, nombre, descripcion) | — |
| `enfoque` | Enfoques pedagógicos (id, nombre, descripcion) | — |
| `car_innovacion` | Características de innovación curricular (id, nombre, descripcion, tipo) | — |
| `aliado` | Entidades externas aliadas (nit PK, razon_social, contacto, ciudad) | — |

### v2 — Tablas CON claves foráneas (15)

| Tabla | Qué es |
|---|---|
| `facultad` | Facultades/departamentos/institutos por universidad (FK) — 35 registros en el Excel |
| `programa` | Programas académicos por facultad (FK) — 191 registros en el Excel |
| `acreditacion` | Acreditaciones por programa (resolucion PK, tipo, calificación, fechas) |
| `registro_calificado` | Autorización legal del programa (codigo PK, créditos, horas, metodología, duración, titulación) |
| `activ_academica` | Cursos/asignaturas: créditos, horas, idioma, cursos espejo |
| `pasantia` | Pasantías por programa (FK) |
| `premio` | Premios a programas (FK) con entidad otorgante |
| `docente_departamento` | Vinculación docente↔programa: dedicación, modalidad, fechas |
| `alianza` | Alianza aliado↔programa con fechas y docente responsable |
| `programa_ac` | Puente programa↔área de conocimiento |
| `programa_pe` | Puente programa↔práctica/estrategia |
| `programa_ci` | Puente programa↔característica de innovación |
| `an_programa` | Puente aspecto_normativo↔programa |
| `enfoque_rc` | Puente enfoque↔registro_calificado |
| `aa_rc` | Puente actividad_académica↔registro_calificado (con componente y semestre) |

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
| **v1** | CRUD completo (API + Front) de las **7 tablas sin FK**, con los catálogos del Excel cargados | Los 7 CRUD funcionan de punta a punta; borrado lógico filtrando inactivos; tag `v1` |
| **v2** | CRUD de las **15 tablas con FK**: las FK como listas desplegables cargadas desde la API; validación de integridad referencial | Los 22 CRUD funcionan; crear un `programa` exige una `facultad` existente; tag `v2` |
| **v3** | `POST /api/login` con **JWT**; middleware de autenticación y autorización; menú por roles; CRUD de usuario/rol/rol_usuario **solo para administradores**; logout | Un usuario "consulta" no puede escribir; solo el admin ve usuarios/roles; tag `v3` |
| **v4** | **10 consultas multitabla** (4+ tablas: p. ej. "programas acreditados por facultad con sus registros calificados y enfoques"), dashboard con gráficos, páginas corporativas con imagen propia, responsive/PWA, **publicación** | Sitio publicado y funcional con secretos en variables de entorno del servidor; tag `v4` |

## 4. Recordatorios innegociables (detalle en [0_METODOLOGIA.md](0_METODOLOGIA.md))

- **2 repos privados** (API y Frontend) con el profesor **`ccastro2050`**
  invitado desde el primer día.
- **Nadie trabaja en main**: cada estudiante en su rama; solo el
  **encargado del main** hace merge de los Pull Requests.
- **Cero secretos en el código**: cadena de conexión y `JWT_SECRET` por
  variables de entorno; `.env` en el `.gitignore`; `.env.example` en el
  repo. (En los repos del curso están quemados SOLO por didáctica — aquí no.)
- **La spec primero**: sin spec kit de la versión, la versión no se recibe.
