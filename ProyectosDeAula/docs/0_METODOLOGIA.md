# Proyecto de aula — Metodología de trabajo (SDD, versiones, Git y secretos)

> **Léame primero.** Este documento define CÓMO se trabaja el proyecto de
> aula — la misma metodología del ejemplo que construimos en clase. Lo QUE
> construye cada equipo está en el documento de su módulo:
> [Gestión Profesoral](modulo_gestion_profesoral.md) ·
> [Investigación](modulo_investigacion.md) ·
> [Innovación Curricular](modulo_innovacion_curricular.md) ·
> [Mapa de Conocimiento](modulo_mapa_conocimiento.md) ·
> [Proyecto Completo](proyecto_completo.md).

> ### Y lo que más sube y baja la nota no es el código: es poder explicarlo
>
> Desde la **v2**, **4 de los 20 puntos de cada versión —el 20 %— son
> INTERPRETABILIDAD**: el profesor abre un archivo que **él** elige y usted lo
> cuenta en voz alta. Qué hace, por qué está así, qué pasa si falla y qué
> cambiaría.
>
> **Un equipo puede pasar todos los criterios técnicos y sacar 2.9 ahí.** Es
> el único criterio que **no se puede delegar** —ni a un compañero ni a una
> IA—, y está desarrollado en la §2.2.

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
6. **Lo que usted entrega, usted lo explica**: desde la v2 se califica en voz
   alta, sobre el archivo que el profesor elija, y **cuenta el 20 % de la
   versión** (§2.2). Código que nadie del equipo puede explicar es código que
   no se entregó: se recibió.

## 2. Las 4 versiones del proyecto de aula

Las antiguas "entregas" ahora son **versiones** con spec kit propio:

| Versión | Qué agrega (acumulativo) | Cierre |
|---|---|---|
| **v1** | CRUD de las **tablas sin FK** del módulo — API REST + Frontend funcionando | Criterios en verde + tag `v1` |
| **v2** | CRUD de **TODAS las tablas** (FK con listas desplegables cargadas desde la API; tablas puente) | Regresión v1 + criterios + tag `v2` |
| **v3** | **JWT + sesiones + control de acceso por roles** + CRUD de usuario/rol/rol_usuario (solo admin) | Regresión v1-v2 + criterios + tag `v3` |
| **v4** | Aplicativo completo: **10 consultas multitabla** (4+ tablas c/u), **dashboard**, **imagen corporativa con su manual de marca**, páginas corporativas, responsive/PWA y **publicación** en servidor gratuito | Regresión total + criterios + tag `v4` |

### 2.1 Calendario y evaluación del semestre (100%)

Las fechas generales aplican a todos los grupos; la **fecha exacta** de su
grupo la fija el profesor en clase (anótela en el espacio en blanco).

| Momento | Fecha general | Fecha exacta (su grupo) | Evaluación |
|---|---|---|---|
| **Evaluación individual teórico-práctica** | Segunda semana de **septiembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** individual |
| **Entrega versión 1** | Última semana de **septiembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 2** | Última semana de **octubre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 3** | Segunda semana de **noviembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |
| **Entrega versión 4** | Última semana de **noviembre** | \_\_\_\_/\_\_\_\_/\_\_\_\_\_\_\_\_ | **20%** — 10% sustentación individual (incluidos los commits) + 10% entrega en equipo |

> **"Incluidos los commits"** significa que en la sustentación individual
> cada estudiante responde por SU rama: qué hizo, por qué, y sus commits
> lo respaldan (frecuentes, descriptivos, propios). Una rama sin commits —
> o con un solo commit gigante la noche anterior — es una sustentación
> sin evidencia.

**Y así se reparten los 20 puntos de cada versión**, para que nadie se entere
el día de la entrega:

| | Puntos | Quién responde |
|---|---|---|
| **Entrega en equipo** | **10** | El equipo: lo que el sistema hace, contra los criterios de aceptación |
| **Sustentación individual** | **10**, y de esos **4 son INTERPRETABILIDAD** (desde la v2) | **Cada uno por separado**, sobre lo que entregó |

> **Los 4 puntos de interpretabilidad salen de los 10 individuales, no de los
> del equipo**, y es a propósito: si salieran de los del equipo, uno que
> entienda salvaría a cuatro que no.

### 2.2 La interpretabilidad — 4 de los 20 puntos de cada versión

Todo lo demás de la rúbrica se comprueba **corriendo el sistema**. Esto no: se
comprueba **hablando**, y es lo que separa haber construido de haber recibido.

| | |
|---|---|
| **Desde cuándo** | **La v2.** En la v1 se está aprendiendo a mover las piezas; en la v2 ya hay **código heredado** y decisiones que alguien tomó, y ahí se ve quién entendió |
| **Cuánto vale** | **4 de los 20 puntos de la versión**, o sea el **20 %** de la nota, en **todas** las versiones de la v2 en adelante |
| **De dónde salen** | De los **10 individuales**. No de los del equipo |
| **Cómo** | El profesor abre **un archivo del repositorio, elegido por él**, y le pide a quien lo entregó que lo cuente |
| **Dónde** | **En voz alta y presencial.** No se recibe por escrito |
| **A quién** | A **cada integrante por separado**, sobre **lo que ese integrante entregó** |

**Y en puntos, para que no haya dudas:**

| | |
|---|---|
| Cada versión vale **20 %** del semestre | 10 % individual + 10 % en equipo |
| La interpretabilidad es **20 % de esa versión** | **4 de los 20 puntos** |
| Y es **individual**, no de equipo | esos 4 puntos salen de **sus 10 puntos individuales** |
| Son **tres versiones** con interpretabilidad (v2, v3 y v4) | **12 % de la nota final del semestre** |

> **En la versión 1 ese 20 % no se evalúa** —se está aprendiendo a mover las
> piezas— y se reparte entre los demás criterios.
>
> **Por qué pesa tanto, dicho sin rodeos:** es el único criterio que **no se
> puede delegar**. La API puede funcionar porque una IA la escribió bien; el
> front puede verse bien por lo mismo. **Explicar por qué está así solo lo
> puede hacer quien entendió.** Un equipo puede entregar un sistema perfecto y
> sacar 2.9 en este criterio — y es correcto que así sea.

**Las cuatro preguntas son siempre las mismas**, así que no hay sorpresa:

| | Qué se pregunta |
|---|---|
| **Qué hace** | Cuénteme este archivo sin leérmelo línea por línea |
| **Por qué así** | ¿Por qué esta decisión y no la otra? ¿Qué se gana y qué se pierde? |
| **Qué pasa si falla** | Si esto se cae o la base de datos rechaza, ¿qué recibe quien llamó y qué ve la persona en la pantalla? |
| **Qué cambiaría** | Si mañana hay que agregar X, ¿dónde se toca? ¿Y dónde NO? |

#### Comentar no es entender, y aquí está la diferencia

La guía de IA exige que **la IA comente lo que genera**, y eso ayuda. Pero:

> **El comentario FACILITA la interpretabilidad; no es la nota.** Un
> comentario se recita sin entenderlo. Y hay algo peor: **puede estar
> equivocado** —la IA comenta lo que *cree* que hizo—. Lo que se califica es
> que usted pueda decir **si es cierto**.

Un comentario que sirve dice **por qué**, no **qué**:

| Comentario que no vale nada | Comentario que sí |
|---|---|
| `// recorre la lista de productos` | `// el detalle viaja en un solo envío y el procedimiento lo abre: UN viaje a la base de datos y UNA transacción — si fuera un INSERT por renglón, un fallo a mitad dejaría media factura` |
| `// valida el stock` | `// el stock lo valida el DISPARADOR y no el servicio, porque también tiene que valer para quien entre por el administrador de la base de datos` |

> **La prueba de fuego de un comentario:** tápele el código y pregúntese si el
> comentario sigue diciendo algo. Si solo repite el nombre del método, no
> aporta; si dice la razón, usted acaba de dejarle escrito a su propio futuro
> —y al profesor— lo que estaba pensando.

#### Y lo que esto implica para cómo se trabaja con IA

| | |
|---|---|
| **Se puede usar IA** | Sí, y está dicho en la guía. Nadie va a preguntar quién escribió la línea |
| **Lo que NO se puede** | Entregar algo que usted no pueda contar. Si la IA lo escribió y usted no lo entendió, **todavía no está entregado**: está pegado |
| **La consecuencia práctica** | Pídale a la IA que **explique** lo que genera, y después **compruébelo**: haga que falle, mire el error, bórrele una línea y vea qué se rompe. Eso es lo que no se puede recitar |


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

\* La `GUIA_IA<N>.md` es **obligatoria en cada versión**, y lleva **los
prompts que de verdad usaron** para generar el código a partir de la spec —el
del chat, el del IDE agéntico, o los dos—, **con lo que tuvieron que
corregirle a la IA**. Copien la estructura de las guías del curso y adáptenla;
eso ES el ejercicio.

**No es burocracia: es el eslabón del medio.** El spec kit dice **qué**
construir, el código es **lo construido**, y el prompt es **cómo se pasó de uno
al otro**. Entregar los dos extremos y no el medio es entregar un resultado sin
su procedimiento.

**Y lo que más vale es la corrección.** Si pidieron algo y salió mal, lo que
escribieron para arreglarlo dice más del equipo que el código final — y en la
sustentación individual es lo que distingue a quien dirigió el trabajo de quien
pegó una respuesta.

**La spec y los prompts son parte de la nota**: en cada versión se evalúa que
el spec kit exista, esté completo y **coincida con lo construido** (si el
código hace algo que la spec no dice, uno de los dos está mal), y que los
prompts que llevaron de la spec al código estén entregados.

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
  403, 404, 422, 500); y **un juego de endpoints ESPECÍFICO por cada tabla**:

  ```
  GET /api/sede          GET /api/sede/{id}          POST /api/sede
  PUT /api/sede/{id}     PATCH /api/sede/{id}        DELETE /api/sede/{id}

  GET /api/modalidad     GET /api/modalidad/{id}     POST /api/modalidad
  ...  y así con cada tabla del módulo
  ```

  El borrado es **lógico** (`activo = 0` / `activo = FALSE`) y los listados
  filtran los inactivos.

### 6.1 Por qué el proyecto pide endpoints específicos y no una API genérica

Al ver ocho o diez tablas parecidas, la idea aparece sola: **una sola ruta con
el nombre de la tabla como parámetro** —`GET /api/{tabla}`, `POST
/api/{recurso}`— atendida por un controlador, un servicio y un repositorio
únicos que sirven para todo.

Es una buena idea en su lugar, y **en este proyecto no es el lugar**. Vale la
pena explicar por qué, porque el argumento sirve mucho más allá del curso.

#### La distinción que hay que entender: prototipo contra producción

Una API genérica **sirve para un prototipo**. Es más corta, se escribe en una
tarde y demuestra que la idea funciona. El problema no es que esté mal escrita:
es que **un prototipo y un sistema en producción se optimizan para cosas
distintas**.

| | Un prototipo | Producción |
|---|---|---|
| **¿Cuántas veces se escribe?** | Una | Una |
| **¿Cuántas veces se LEE y se cambia?** | Casi ninguna: se tira | Durante años, y casi siempre por alguien que no lo escribió |
| **¿Quién lo consume?** | Quien lo escribió, ese mismo día | Otro equipo, otro sistema, y usted mismo seis meses después |

Genérico es **barato de escribir y caro de vivir**. Específico es **caro de
escribir una vez y barato de vivir**. En un prototipo gana el primero porque
no hay «vivir». En producción gana el segundo, y por goleada.

De ahí salen seis consecuencias concretas:

| # | Lo que pasa en producción | Por qué el molde genérico no aguanta |
|---|---|---|
| 1 | **El contrato hay que LEERLO, no recordarlo** | Swagger muestra `/api/{tabla}`: un hueco. Quien abre la API no sabe qué recursos hay ni qué campos lleva cada uno. Y este proyecto se sustenta proyectando Swagger: **si no dice qué hay, no hay qué sustentar** |
| 2 | **Las tablas se van diferenciando** | Toda tabla que sobrevive acumula reglas propias: una no se borra, otra audita, otra tiene un campo calculado. El molde obliga a meter condiciones «si la tabla es X…», y ahí el ahorro se acabó: queda un intérprete escrito a mano, peor que los diez controladores que se querían evitar |
| 3 | **Los permisos son POR RECURSO** | «El coordinador ve sedes pero no roles» no cabe en una ruta única: o se autoriza de más, o se agrega un mapa de reglas por tabla — que es la lista de controladores otra vez, hecha a mano y sin ayuda del compilador |
| 4 | **Hay que operar el sistema** | Métricas, registros, límites de tasa, alertas: todo se agrupa por ruta. Con `/api/{tabla}` todo el tráfico es **una sola línea** en el tablero, y nunca se puede decir «el endpoint de sedes está lento» |
| 5 | **Hay que cambiar un recurso sin tocar los demás** | Agregar un campo, cambiar una validación, deprecar algo. Con un molde compartido, **cada cambio pequeño toca las diez tablas**: el riesgo se multiplica por diez |
| 6 | **Los errores en ejecución cuestan incidentes** | Con clases de petición tipadas, un campo mal escrito no compila. Con un diccionario genérico, se descubre en la sustentación o, peor, en producción |

#### Y la excepción honesta, para que esto no sea dogma

**Sí existen APIs genéricas en producción**, y buenas: PostgREST, Hasura, los
paneles de administración que exponen tablas. La diferencia es que en esos
casos **lo genérico es el producto entero**: publican un esquema completo
—generado de la base—, tienen su modelo de permisos por fila y por columna, y
su contrato *es* «esto expone la base de datos».

Lo que no funciona es **la mitad**: una API de dominio, escrita a mano, con un
pedazo genérico adentro. Ahí se pagan los costos de las dos formas y no se
cobra la ventaja de ninguna.

> **De dónde sale esto.** No es una preferencia de nadie: sale de haberlo
> hecho de las dos formas. El ejemplo de referencia del curso se construyó
> primero con una ruta genérica — quedó más corto, funcionaba y pasaba sus
> pruebas —, y al abrir Swagger para sustentarlo no se veía un solo recurso
> con nombre. Se rehízo con endpoints específicos.
>
> Se cuenta aquí para que usted no tenga que pagar la misma tarde.
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
  Sobre Nosotros) con imagen corporativa de la empresa hipotética **respaldada
  por un manual de marca** (ver abajo); diseño
  responsive (PWA si es posible); publicación en servidor gratuito según
  el stack (las opciones están en el documento de su módulo original y
  las valida el profesor).
- **Datos iniciales**: las tablas de catálogo se cargan con los datos de
  referencia del Excel del `Mapa_conocimiento/` (los conteos por tabla
  están en el documento del módulo).
- **Stack**: cada equipo elige su lenguaje/framework con aprobación del
  profesor — la metodología y los contratos son los mismos en cualquier
  stack (esa es la gracia).

### El manual de marca de la v4

La imagen corporativa no se improvisa el último día: **se escribe antes en un
manual, y después la pantalla lo cumple.** Eso es lo que se evalúa.

**El equipo escoge:**

| Opción | Qué implica |
|---|---|
| **Adoptar el manual del ejemplo** | Usar el que viene en el repositorio del proyecto (`MANUAL_DE_MARCA.md`), con sus colores, su logosímbolo y sus reglas |
| **Hacer el suyo** | Inventar la marca de su empresa hipotética y escribir su propio manual |

**Es libre.** Lo que **no** es libre es que exista:

> **Tiene que haber un manual de marca en el repositorio, como `.pdf` y/o
> `.md`.** Sin él no hay contra qué comparar la pantalla, y el criterio de
> imagen corporativa no se puede calificar.

**Lo mínimo que ese manual debe fijar:**

1. El **logosímbolo** y sus versiones.
2. La **paleta**, con los valores en hexadecimal.
3. Las **tipografías** autorizadas.
4. El **tamaño mínimo** del logo y su **área de reserva**.
5. Los **usos incorrectos**.

Y una exigencia que sale del propio curso: **los valores del manual van en un
archivo aparte** —un `marca.css` o equivalente— y los estilos de la
aplicación usan la variable, nunca el valor. Así el manual es una
restricción, y no una preferencia de quien programa.

> **El contraste se calcula, no se opina.** Si un color del manual no alcanza
> la relación que pide el nivel AA de las WCAG para el texto, el manual debe
> decir para qué sirve ese color y cuál se usa en su lugar. Hay un documento
> del curso con la fórmula y las referencias: `CONCEPTOS_IDENTIDAD_VISUAL.md`.


## 7. Rúbrica de evaluación

Aplica en cada versión; el profesor asigna el peso por criterio. Cada
criterio se califica en una de dos franjas: **Cumple (de 3.0 a 5.0**,
según la calidad de lo entregado**)** o **No cumple (de 0 a 2.9)**.

| Criterio | Cumple (3.0 – 5.0) | No cumple (0 – 2.9) |
|---|---|---|
| **Especificación (SDD)** | Spec kit de la versión completo ANTES del código; criterios de aceptación verificables; lo construido coincide con la spec | No hay spec, se escribió después "para cumplir", o contradice lo construido |
| **Funcionalidad de la API** | Los endpoints de la versión funcionan con JSON y códigos correctos | Endpoints caídos o sin JSON |
| **Funcionalidad del Frontend** | Las interfaces consumen la API y son usables | No funcionan o van directo a la BD |
| **Separación API/Front** | El front jamás toca la BD | No hay separación |
| **Seguridad (v3+) y secretos (todas)** | JWT + roles funcionando; contraseñas hasheadas; **cero secretos en el código**, `.env.example` presente | Sin autenticación, contraseñas o secretos quemados/en texto plano |
| **Borrado lógico** | En las tablas de la versión, con inactivos filtrados | Borrado físico |
| **Git y GitHub** | Repos privados con el profesor invitado; cada estudiante en su rama; TODO por PR; solo el encargado hace merge; tags v1…vN; commits descriptivos | Commits directos a main, repo público o sin el profesor, "un solo commit con todo" |
| **Dashboard y consultas (v4)** | 10 consultas de 4+ tablas con gráficos claros | Menos de 10 consultas, consultas de menos de 4 tablas, o sin dashboard |
| **Imagen corporativa y responsive (v4)** | **Existe un manual de marca** —propio o el del ejemplo— y la pantalla lo cumple: los colores y las tipografías salen de él, no de un gusto; todo responsive | No hay manual, o lo hay y la pantalla no lo respeta, o no es responsive |
| **Publicación (v4)** | Publicado, funcional, con secretos en variables de entorno del servidor | No publicado o con secretos expuestos |
| **INTERPRETABILIDAD (v2+)** · *4 de los 20 puntos* | Cada integrante **cuenta en voz alta** el archivo que el profesor elija de lo que ÉL entregó: qué hace, por qué así, qué pasa si falla y qué cambiaría. Y los comentarios del código dicen **por qué**, no qué | No puede explicar lo que entregó, o lo recita; los comentarios repiten el nombre del método —o están equivocados y no se dio cuenta— (§2.2) |

Dentro de la franja "Cumple", la nota (3.0 a 5.0) refleja la calidad:
completitud, solidez ante errores, claridad del código y de la spec, y la
sustentación individual.

> **Y una advertencia sobre la fila de interpretabilidad, porque es la que más
> sorprende:** un equipo puede tener los otros criterios en verde y esa en
> 2.9. No es un descuido de la rúbrica —es el único criterio que no se puede
> delegar—. Ver la §2.2.

**Entregar en cada versión:** enlaces a los 2 repos (con el tag `vN`
puesto) + evidencia del quickstart de su spec pasando. En la v4, además:
URL del sitio publicado.
