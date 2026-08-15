# Proyecto de aula — Proyecto Completo (los 6 módulos integrados)

> **Base de datos:** `knowledge_map_db` · **60 tablas** (57 del modelo +
> 3 de gestión de usuarios) · Caso diseñado por: Carlos Arturo Castro Castro.
>
> La metodología (SDD por versiones, spec kit, ramas de Git, secretos por
> variables de entorno, rúbrica) está en **[0_METODOLOGIA.md](0_METODOLOGIA.md)**
> y es OBLIGATORIA. El script de la BD completa está en
> `db_scripts/sqlserver/knowledge_map_db_completa.ss.sql`, el modelo
> relacional en `Mapa_conocimiento/04_Modelo_y_Base_de_datos/` y los datos
> de referencia en el Excel.

---

## 1. Contexto

El proyecto completo integra los **6 módulos** del Sistema de Gestión de
Información del Conocimiento Universitario en **una sola base de datos**:

| Módulo | Qué aporta |
|---|---|
| **Caracterización** | Catálogos compartidos: áreas de conocimiento (218), ODS (17), áreas de aplicación (21) |
| **Común** | Tablas compartidas por varios módulos: docente, línea de investigación, término clave, red |
| **Mapa de Conocimiento** | Proyectos de investigación, productos, aliados y sus relaciones |
| **Gestión Profesoral** | Perfil académico y profesional de los docentes |
| **Innovación Curricular** | Universidades, facultades, programas, registros calificados, actividades |
| **Investigación** | Grupos, semilleros, líneas y participación de docentes |

El detalle tabla por tabla de cada módulo está en su documento
(`modulo_*.md`); las diferencias clave del proyecto completo son que los
catálogos y `docente` son ÚNICOS y compartidos (no se repiten por módulo),
y que las 10 consultas multitabla de la v4 pueden (y deben) cruzar módulos.

## 2. Las tablas, organizadas por versión

### v1 — Tablas SIN claves foráneas (~14)

Los catálogos de todos los módulos: `area_aplicacion`,
`area_conocimiento`, `objetivo_desarrollo_sostenible` (Caracterización) ·
`linea_investigacion`, `termino_clave`, `red` (Común) · `aliado`,
`tipo_producto`, `proyecto` (Mapa) · `aspecto_normativo`,
`car_innovacion`, `enfoque`, `practica_estrategia`, `universidad`
(Innovación Curricular). Cargar los datos de referencia del Excel.

### v2 — Tablas CON claves foráneas (~43)

Todas las demás, en orden de dependencias: primero `docente`, `facultad`,
`programa`, `grupo_investigacion`; luego las que dependen de ellas
(`estudios_realizados`, `producto`, `registro_calificado`, `semillero`…);
y al final las tablas puente (los `*_ac`, `*_linea`, `*_proyecto`,
`*_rc`, `programa_*`, participaciones y alianzas). La lista completa con
columnas está en los documentos de los módulos y en el script SQL.

### v3 — Gestión de usuarios (3)

`rol` · `usuario` (password **hasheada**) · `rol_usuario` — únicas para
todo el sistema.

## 3. La ruta de versiones

La misma de los módulos ([0_METODOLOGIA.md](0_METODOLOGIA.md) §2), con el
alcance del sistema completo:

| Versión | Qué agrega | Cierre |
|---|---|---|
| **v1** | CRUD (API + Front) de los ~14 catálogos sin FK, con datos del Excel | Criterios + tag `v1` |
| **v2** | CRUD de las ~43 tablas con FK, respetando el orden de dependencias; FK como selects desde la API | Regresión v1 + criterios + tag `v2` |
| **v3** | JWT + roles + CRUD usuarios/roles (solo admin) | Regresión + criterios + tag `v3` |
| **v4** | 10 consultas multitabla **cruzando módulos** (p. ej. "productos de proyectos por grupo de investigación, programa y ODS"), dashboard, imagen corporativa, responsive, publicación | Regresión total + tag `v4` |

**Advertencia de alcance:** este proyecto es ~3 veces un módulo. Solo para
equipos que acuerden ese alcance con el profesor; la metodología no cambia
— cambia el volumen. Se recomienda que el spec kit de cada versión
subdivida el trabajo por módulo (una rebanada por integrante).

## 4. Recordatorios innegociables (detalle en [0_METODOLOGIA.md](0_METODOLOGIA.md))

- **2 repos privados** (API y Frontend) con el profesor **`ccastro2050`**
  invitado desde el primer día.
- **Nadie trabaja en main**: cada estudiante en su rama; solo el
  **encargado del main** hace merge de los Pull Requests.
- **Cero secretos en el código**: cadena de conexión y `JWT_SECRET` por
  variables de entorno; `.env` en el `.gitignore`; `.env.example` en el
  repo. (En los repos del curso están quemados SOLO por didáctica — aquí no.)
- **La spec primero**: sin spec kit de la versión, la versión no se recibe.
