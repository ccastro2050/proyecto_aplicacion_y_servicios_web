# Proyecto de aula — Metodología de trabajo (SDD, versiones, Git y secretos)

> **Léame primero.** Este documento define CÓMO se trabaja el proyecto de
> aula — la misma metodología del ejemplo que construimos en clase. Lo QUE
> construye cada equipo está en el documento de su módulo:
> [Gestión Profesoral](modulo_gestion_profesoral.md) ·
> [Investigación](modulo_investigacion.md) ·
> [Innovación Curricular](modulo_innovacion_curricular.md) ·
> [Mapa de Conocimiento](modulo_mapa_conocimiento.md) ·
> [Proyecto Completo](proyecto_completo.md).

---

## 1. El método: SDD por versiones (igual que en clase)

El proyecto de aula se trabaja con **Spec-Driven Development (SDD)**:
primero la especificación, después el código, **versión por versión** —
exactamente como el ejemplo del curso:

| Ejemplo de clase | Qué demuestra |
|---|---|
| [proyecto_aplicacion_y_servicios_web1](https://github.com/ccastro2050/proyecto_aplicacion_y_servicios_web1) | La v1: una rebanada vertical con capas, especificada antes de codificar |
| [proyecto_aplicacion_y_servicios_web2](https://github.com/ccastro2050/proyecto_aplicacion_y_servicios_web2) | La v2: crecer SOBRE la v1 sin romperla (regresión + spec del delta) |
| proyecto_aplicacion_y_servicios_web3 y …web4 | Llegarán durante el semestre — la ruta continúa igual |

Lo que se replica del ejemplo **es el MÉTODO, no el contenido**: la
constitución permanente, una carpeta de specs por versión con sus 7
documentos + su guía, los criterios de aceptación como definición de
"terminado", el cierre con tag, y la regla de que una versión cerrada no
se reabre. Estudien el `docs/spec_kit/` de esos repos: ese es el molde.

### 1.1 Las reglas de oro (del mapa de versiones del curso)

1. **La especificación manda**: no se programa nada que la spec de la
   versión en curso no pida.
2. **No se anticipa**: nada de una versión futura se construye "de una
   vez" (ni JWT en la v1, ni dashboard en la v2).
3. **Una versión está TERMINADA** solo cuando pasan sus criterios de
   aceptación → commit + **tag `vN`** en main → solo entonces se escribe
   la spec de la siguiente.
4. **Una versión cerrada no se reabre**: los ajustes van en la siguiente.
5. **Regresión obligatoria**: al cerrar la vN, los criterios de TODAS las
   versiones anteriores deben seguir pasando (las versiones son
   acumulativas).

## 2. Las 4 versiones del proyecto de aula

Las antiguas "entregas" ahora son **versiones** con spec kit propio:

| Versión | Qué agrega (acumulativo) | Cierre |
|---|---|---|
| **v1** | CRUD de las **tablas sin FK** del módulo — API REST + Frontend funcionando | Criterios en verde + tag `v1` |
| **v2** | CRUD de **TODAS las tablas** (FK con listas desplegables cargadas desde la API; tablas puente) | Regresión v1 + criterios + tag `v2` |
| **v3** | **JWT + sesiones + control de acceso por roles** + CRUD de usuario/rol/rol_usuario (solo admin) | Regresión v1-v2 + criterios + tag `v3` |
| **v4** | Aplicativo completo: **10 consultas multitabla** (4+ tablas c/u), **dashboard**, **imagen corporativa**, páginas corporativas, responsive/PWA y **publicación** en servidor gratuito | Regresión total + criterios + tag `v4` |

Las fechas y porcentajes de cada versión los asigna el profesor en clase.

## 3. El spec kit que cada equipo ESCRIBE (por versión)

Antes de programar cada versión, el equipo escribe su especificación en
`docs/spec_kit/` del repositorio de la API (el mismo formato del curso):

```
docs/spec_kit/
├── 1_constitution.md            ← UNA vez (los principios del equipo: stack
│                                   elegido, capas, español, borrado lógico,
│                                   secretos por variables de entorno…)
└── versiones/
    ├── 0_mapa_versiones.md      ← la tabla de la sección 2, con estados
    ├── v1_<nombre>/             ← 2_spec.md · 3_plan.md · 4_research.md ·
    │                              5_data_model.md · 6_contracts.md ·
    │                              7_quickstart.md · 8_tasks.md · GUIA_IA1.md*
    ├── v2_<nombre>/             ← los mismos 7+1, para el delta de la v2
    └── …
```

\* La `GUIA_IA<N>.md` es opcional pero recomendada: si van a construir con
ayuda de IA, escriban el prompt y las reglas COMO en las guías del curso —
la IA sigue la spec, no improvisa. Copien la estructura de los repos de
clase y adáptenla; eso ES el ejercicio.

**La spec es parte de la nota**: en cada versión se evalúa que el spec kit
exista, esté completo y **coincida con lo construido** (si el código hace
algo que la spec no dice, uno de los dos está mal).

## 4. Los dos repositorios (y las reglas de GitHub)

El sistema son **DOS proyectos separados**, cada uno con su repositorio:

| Repositorio | Qué es | Regla de oro |
|---|---|---|
| `<equipo>-api` | El backend: REST + JSON, conecta a la BD | NO genera HTML |
| `<equipo>-frontend` | La interfaz: consume la API por HTTP | NO se conecta a la BD |

**Requisitos obligatorios de ambos repositorios:**

1. **Privados.** El código del equipo no es público.
2. **Invitar al profesor** como colaborador desde el primer día:
   *Settings → Collaborators → Add people* → **`ccastro2050`**.
   Sin acceso del profesor, la entrega no existe.
3. El spec kit vive en el repo de la API (`docs/spec_kit/`).

### 4.1 El flujo de ramas (obligatorio desde la v1)

- **NADIE trabaja en `main`. Nunca.** Ni un commit directo.
- **Cada estudiante tiene SU rama** (nómbrela con su nombre:
  `rama-mariana`, `rama-jorge`) y trabaja siempre ahí.
- El equipo designa **UN encargado del main** (el integrador). Ese
  estudiante TAMBIÉN tiene su propia rama para su trabajo — su rol extra
  es ser el único que integra.
- Todo llega a `main` por **Pull Request**: el autor abre el PR desde su
  rama, el encargado del main lo revisa (¿compila? ¿cumple la spec? ¿los
  criterios siguen pasando?) y SOLO el encargado hace el merge.
- El cierre de cada versión es un **tag `vN` sobre main** (lo pone el
  encargado cuando los criterios de aceptación pasan).
- Commits pequeños, frecuentes y con mensajes descriptivos en español —
  "avances" no es un mensaje.

```
rama-mariana ──●──●──●──╮ PR
rama-jorge   ──●──●─────┤ PR      (revisa y hace merge: SOLO el encargado)
rama-andres  ──●──●──●──┤ PR
                        ▼
main         ────────●──●──●── tag v1 ──●──●── tag v2 ──…
```

## 5. Secretos: variables de entorno, SIEMPRE

**Regla innegociable:** ningún secreto va escrito en el código ni en
archivos versionados. Son secretos: la **cadena de conexión** a la BD (y
su contraseña), el **secreto de firma del JWT**, y cualquier clave de
servicios externos.

> **Aclaración importante del profesor:** en los repositorios del curso
> (web1, web2…) las credenciales están escritas a la vista **a propósito y
> solo por didáctica**: es un entorno de juguete que corre en su PC y
> jamás se despliega. El proyecto de aula es distinto — **se publica en un
> servidor real (v4)**, así que ahí la regla aplica completa desde la v1.

Cómo cumplirla:

1. El código lee los secretos de **variables de entorno**
   (`DB_CONNECTION`, `JWT_SECRET`, …) con el mecanismo de su stack
   (variables del sistema, `.env` con la librería del lenguaje,
   `environment:` en compose, configuración del servidor de publicación).
2. El archivo **`.env` NUNCA se sube a git** — va en el `.gitignore`
   desde el primer commit.
3. El repo SÍ incluye un **`.env.example`**: las mismas variables con
   valores de mentira, para que cualquier integrante (o el profesor) sepa
   qué configurar.
4. En el servidor gratuito de la v4, los secretos se configuran en el
   panel de variables de entorno del servicio — jamás en el código
   desplegado.
5. **Si un secreto se subió por error**: cambiarlo (rotarlo) de inmediato;
   borrarlo del último commit no basta — quedó en la historia.

En la rúbrica: un secreto quemado en el código **anula el criterio de
seguridad de la versión**.

## 6. Reglas técnicas del sistema (aplican a todos los módulos)

- **API REST**: JSON siempre; códigos HTTP correctos (200/201, 400, 401,
  403, 404, 422, 500); endpoints por tabla:
  `GET /api/{tabla}` · `GET /api/{tabla}/{id}` · `POST` · `PUT /{id}` ·
  `DELETE /{id}` (borrado **lógico**: `activo = 0`; los listados filtran
  los inactivos).
- **Separación estricta**: el frontend consume la API; si el frontend toca
  la BD, la arquitectura está rota (criterio de rúbrica).
- **v3 — seguridad**: `POST /api/login` entrega el JWT; middleware de
  autenticación y de autorización por roles; el frontend guarda el token,
  lo envía en `Authorization: Bearer`, arma el menú según roles, y solo el
  administrador ve el CRUD de usuarios/roles. Contraseñas de usuarios
  **hasheadas** (bcrypt o equivalente), nunca en texto plano.
- **v4 — cierre**: 10 consultas multitabla (mínimo 4 tablas cada una)
  expuestas como endpoints y presentadas en el dashboard con gráficos;
  páginas corporativas (Home, Productos/Servicios, Soporte, Contacto,
  Sobre Nosotros) con imagen corporativa de la empresa hipotética; diseño
  responsive (PWA si es posible); publicación en servidor gratuito según
  el stack (las opciones están en el documento de su módulo original y
  las valida el profesor).
- **Datos iniciales**: las tablas de catálogo se cargan con los datos de
  referencia del Excel del `Mapa_conocimiento/` (los conteos por tabla
  están en el documento del módulo).
- **Stack**: cada equipo elige su lenguaje/framework con aprobación del
  profesor — la metodología y los contratos son los mismos en cualquier
  stack (esa es la gracia).

## 7. Rúbrica de evaluación

Aplica en cada versión; el profesor asigna el peso por criterio.

| Criterio | Excelente (5.0) | Insuficiente (< 3.0) |
|---|---|---|
| **Especificación (SDD)** | Spec kit de la versión completo ANTES del código; criterios de aceptación verificables; lo construido coincide con la spec | No hay spec, se escribió después "para cumplir", o contradice lo construido |
| **Funcionalidad de la API** | Todos los endpoints de la versión funcionan con JSON y códigos correctos | Endpoints caídos o sin JSON |
| **Funcionalidad del Frontend** | Todas las interfaces consumen la API y son usables | No funcionan o van directo a la BD |
| **Separación API/Front** | Total: el front jamás toca la BD | No hay separación |
| **Seguridad (v3+) y secretos (todas)** | JWT + roles funcionando; contraseñas hasheadas; **cero secretos en el código**, `.env.example` presente | Sin autenticación, contraseñas o secretos quemados/en texto plano |
| **Borrado lógico** | En todas las tablas, con inactivos filtrados | Borrado físico |
| **Git y GitHub** | Repos privados con el profesor invitado; cada estudiante en su rama; TODO por PR; solo el encargado hace merge; tags v1…vN; commits descriptivos | Commits directos a main, repo público o sin el profesor, "un solo commit con todo" |
| **Dashboard y consultas (v4)** | 10+ consultas de 4+ tablas con gráficos claros | Menos de 4 o sin dashboard |
| **Imagen corporativa y responsive (v4)** | Identidad coherente; todo responsive | Sin identidad o no responsive |
| **Publicación (v4)** | Publicado, funcional, con secretos en variables de entorno del servidor | No publicado o con secretos expuestos |

**Entregar en cada versión:** enlaces a los 2 repos (con el tag `vN`
puesto) + evidencia del quickstart de su spec pasando. En la v4, además:
URL del sitio publicado.
