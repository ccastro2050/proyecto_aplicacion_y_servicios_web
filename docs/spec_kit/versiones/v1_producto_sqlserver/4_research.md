# Investigación y decisiones — Versión 1: producto + SQL Server (C#/ASP.NET Core)

> **Versión 1** · **Lectura opcional** (el porqué de las decisiones del plan,
> con las alternativas que se evaluaron y descartaron). Complementa a
> [3_plan.md](3_plan.md); el orden de trabajo está en [8_tasks.md](8_tasks.md).

---

## D1 — ADO.NET crudo: sin Entity Framework (ni Dapper)

**Alternativas descartadas:** Entity Framework Core (el ORM de .NET) y
Dapper (micro-ORM).
**Decisión:** `SqlConnection` + `SqlCommand` con SQL parametrizado a mano.
**Por qué:** el objetivo es aprender **SQL y arquitectura**, no un ORM. EF
esconde exactamente lo que el curso quiere mostrar (el SQL, el mapeo, las
transacciones); Dapper es razonable pero igual tapa el ciclo
conexión→comando→lector que un estudiante debe ver una vez en la vida.
**Precio asumido:** más líneas por método del repositorio — cada una es
lección.

## D2 — Capas completas desde el día 1 (y no un MVP en un solo archivo)

**Alternativa descartada:** v1 = todo en `Program.cs` con minimal APIs y
refactorizar a capas después.
**Decisión:** controller → servicio → repositorio con interfaces desde v1.
**Por qué:** el valor de la v1 es el **esqueleto** sobre el que crecen las
demás versiones sin reescribir. El criterio de aceptación 6 (probar el
servicio con un repositorio falso, sin SQL Server) **solo es posible** si el
servicio depende de una `interface` — la prueba objetiva de que las capas
quedaron bien cortadas.

## D3 — Sin fábrica ni selección de motor: el ensamblador es la DI de Program.cs

**Alternativa descartada:** escribir de una vez la fábrica multi-motor.
**Decisión:** dos registros `AddScoped` que instancian la única combinación
existente (YAGNI con dirección).
**Por qué:** una fábrica con un solo producto es código muerto. La interfaz
`IRepositorioProducto` SÍ se escribe hoy — es la puerta por la que entrará
el segundo motor — pero el mecanismo de selección llega cuando exista algo
que seleccionar (v3). El examen del principio abierto/cerrado será ese: en
v3, solo el ensamblador cambia.

## D4 — La BD completa desde la v1 (la API solo toca `producto`)

**Alternativa descartada:** una BD mínima que crece con cada versión.
**Decisión:** `db/bdfacturas.sql` crea `bdfacturas` COMPLETA (12 tablas,
triggers, SPs); la regla es que el código de v1 solo puede nombrar
`producto`.
**Por qué:** los estudiantes ya vieron bases de datos — la BD es
**infraestructura dada**; lo que se construye por versiones es la API. Evita
migraciones entre versiones y deja los triggers y SPs de facturación
esperando a la v2. Costo asumido: 11 tablas a la vista que aún no se usan —
por eso la regla se declara explícita en la spec.

## D5 — La validación vive en los MODELOS (un modelo por verbo)

**Alternativas descartadas:** validar con ifs dentro del controlador, una
clase validadora aparte, o no validar y dejar que la BD rechace.
**Decisión:** tres modelos de body (`ProductoCrear`, `ProductoReemplazo`,
`ProductoActualizar`) que DECLARAN sus reglas con anotaciones; ASP.NET
valida y responde 422 con la lista de errores (formato personalizado en
`Program.cs`).
**Por qué:** es la manera idiomática del framework — el modelo declara, el
framework hace cumplir — y materializa la semántica de cada verbo: el mismo
body `{"stock": 7}` falla en PUT (le faltan campos) y pasa en PATCH. Bono
didáctico: **el tipo es regla** — `stock` es `int?`, así que un `7.5` o un
`"texto"` caen en 422 sin escribir ni un if.

## D6 — SQL Server como primer motor (y su inicializador)

**Alternativas descartadas:** empezar con un motor liviano y dejar SQL
Server para después.
**Decisión:** v1 arranca con SQL Server 2022 en contenedor (edición
Developer, gratuita) + un contenedor `sqlserver-init` que crea la BD la
primera vez.
**Por qué:** es el motor del ecosistema del curso (C#/.NET) y el que los
estudiantes encontrarán en las empresas del mundo Microsoft. El precio es
doble: pide ~2 GB de RAM, y **no ejecuta scripts montados automáticamente**
— de ahí el inicializador, que además es lección de Docker (un contenedor
que hace su trabajo y termina, con `service_completed_successfully` como
semáforo para la API).

## D7 — dotnet watch dentro del contenedor (imagen SDK, no runtime)

**Alternativa descartada:** imagen multi-stage con publish (más pequeña,
estilo producción).
**Decisión:** la imagen del SDK corriendo `dotnet watch`, con el código
montado como volumen y `bin/`+`obj/` en volúmenes anónimos.
**Por qué:** el ciclo del curso es guardar → recompila solo → refrescar.
Una imagen de producción optimizada no enseña nada en v1 y rompe ese ciclo.
El matiz de los volúmenes anónimos importa: los compilados de Linux (los
del contenedor) no deben mezclarse con los de Windows (los del IDE del
estudiante).

## D8 — Docker compose desde la v1 (tres servicios)

**Alternativa descartada:** `docker run` a mano y la API por fuera.
**Decisión:** `docker-compose.yml` con `sqlserver` + `sqlserver-init` +
`api-facturas` desde v1 — `docker compose up -d --build` deja todo
funcionando.
**Por qué:** el Artículo 4 de la constitución ("un solo comando") es
permanente — y la constitución gana. El compose de v1 **crece por
versiones** (v3 suma PostgreSQL, v4 MariaDB, v6 el front): la
infraestructura también se construye por incrementos.
