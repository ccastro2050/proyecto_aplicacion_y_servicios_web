# Proyecto de aula — Módulo: Mapa de Conocimiento

> **Base de datos:** `mapa_conocimiento` · **21 tablas** (18 del módulo +
> 3 de gestión de usuarios) · Caso diseñado por: Carlos Arturo Castro Castro.
>
> La metodología (SDD por versiones, spec kit, ramas de Git, secretos por
> variables de entorno, rúbrica) está en **[0_METODOLOGIA.md](0_METODOLOGIA.md)**
> y es OBLIGATORIA. Este documento define el QUÉ de este módulo. El script
> de la BD está en `db_scripts/sqlserver/mapa_conocimiento.ss.sql` y los
> datos de referencia en el Excel de `Mapa_conocimiento/`.

---

## 1. Contexto

Una Universidad con sedes y seccionales en varias ciudades trabaja en un
Sistema de Información para gestionar el conocimiento generado desde sus
diferentes instancias. El sistema tiene 6 módulos; **cada equipo construye
su módulo en su propia base de datos independiente**, incluyendo las
tablas de gestión de usuarios.

**Este módulo** gestiona los proyectos de investigación y sus productos:
la participación de docentes, las alianzas con entidades externas, las
palabras clave, y las relaciones de cada proyecto con áreas de
conocimiento, ODS, áreas de aplicación y líneas de investigación.

## 2. Las tablas, organizadas por versión

### v1 — Tablas SIN claves foráneas (8)

| Tabla | Qué es | Datos del Excel |
|---|---|---|
| `area_conocimiento` | Catálogo jerárquico: gran_area → area → disciplina | 218 registros |
| `objetivo_desarrollo_sostenible` | Los 17 ODS con su categoría | 17 registros |
| `area_aplicacion` | Sectores económicos de aplicación | 21 registros |
| `termino_clave` | Keywords con traducción (termino PK, termino_ingles) | — |
| `linea_investigacion` | Líneas de investigación (id, nombre, descripcion) | — |
| `aliado` | Entidades externas aliadas (nit PK, razon_social, contacto, ciudad) | — |
| `tipo_producto` | Tipología de productos según Minciencias (id, categoria, clase, nombre, tipologia) | — |
| `proyecto` | Proyectos de investigación (id, titulo, resumen, presupuesto, tipo_financiacion, tipo_fondos, fechas) | — |

### v2 — Tablas CON claves foráneas (10)

| Tabla | Qué es |
|---|---|
| `docente` | La tabla central del perfil investigador: cedula (PK), CvLAC, escalafón, categoría Minciencias, linea_investigacion_principal (FK) |
| `producto` | Productos por proyecto (FK) y tipo_producto (FK): artículos, libros, patentes, software… |
| `desarrolla` | Participación docente↔proyecto con rol (investigador principal/coinvestigador/asesor) |
| `docente_producto` | Puente docente↔producto (un producto puede tener varios autores) |
| `aliado_proyecto` | Puente aliado↔proyecto |
| `palabras_clave` | Puente proyecto↔termino_clave |
| `ac_proyecto` | Puente proyecto↔área de conocimiento |
| `proyecto_linea` | Puente proyecto↔línea de investigación |
| `ods_proyecto` | Puente proyecto↔ODS |
| `aa_proyecto` | Puente proyecto↔área de aplicación |

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
| **v1** | CRUD completo (API + Front) de las **8 tablas sin FK**, con los catálogos del Excel cargados | Los 8 CRUD funcionan de punta a punta; borrado lógico filtrando inactivos; tag `v1` |
| **v2** | CRUD de las **10 tablas con FK**: las FK como listas desplegables cargadas desde la API; validación de integridad referencial | Los 18 CRUD funcionan; crear un `producto` exige un `proyecto` y un `tipo_producto` existentes; tag `v2` |
| **v3** | `POST /api/login` con **JWT**; middleware de autenticación y autorización; menú por roles; CRUD de usuario/rol/rol_usuario **solo para administradores**; logout | Un usuario "consulta" no puede escribir; solo el admin ve usuarios/roles; tag `v3` |
| **v4** | **10 consultas multitabla** (4+ tablas: p. ej. "proyectos cofinanciados con sus productos, autores y ODS asociados"), dashboard con gráficos, páginas corporativas con imagen propia, responsive/PWA, **publicación** | Sitio publicado y funcional con secretos en variables de entorno del servidor; tag `v4` |

## 4. Recordatorios innegociables (detalle en [0_METODOLOGIA.md](0_METODOLOGIA.md))

- **2 repos privados** (API y Frontend) con el profesor **`ccastro2050`**
  invitado desde el primer día.
- **Nadie trabaja en main**: cada estudiante en su rama; solo el
  **encargado del main** hace merge de los Pull Requests.
- **Cero secretos en el código**: cadena de conexión y `JWT_SECRET` por
  variables de entorno; `.env` en el `.gitignore`; `.env.example` en el
  repo. (En los repos del curso están quemados SOLO por didáctica — aquí no.)
- **La spec primero**: sin spec kit de la versión, la versión no se recibe.
