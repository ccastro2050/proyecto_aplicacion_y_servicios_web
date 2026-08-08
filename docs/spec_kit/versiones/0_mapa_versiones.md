# Mapa de versiones del curso

> La ruta completa del proyecto. Cada versión se especifica SOLO cuando la
> anterior está cerrada (commit + tag). Este mapa da la dirección; las
> specs de cada versión dan el detalle.

| Versión | Qué agrega | Estado |
|---|---|---|
| **v1** | `api_facturas` (C#/ASP.NET Core): CRUD completo de `producto` contra **SQL Server** — capas + interfaces + peticiones por verbo | **En curso** ([spec](v1_producto_sqlserver/2_spec.md)) |
| v2 | Más entidades (persona, factura maestro-detalle…) aprovechando los triggers y SPs de la BD | Sin especificar |
| v3 | Segundo motor (**PostgreSQL**) — nace la fábrica de repositorios real | Sin especificar |
| v4 | Tercer motor (**MariaDB**) + compose completo | Sin especificar |
| v5 | **API genérica de plataforma**: CRUD sobre CUALQUIER tabla (`/api/{tabla}` con filas como diccionario columna→valor descubierto en runtime), selección de motor por configuración, **autenticación JWT**, encriptación BCrypt de campos, consultas SELECT parametrizadas, ejecución de **procedimientos almacenados** y exploración de estructuras de la BD | Sin especificar |
| v6 | Frontend **Blazor Server**: CRUD de las 12 entidades (una página por tabla), **login y control de acceso con JWT**, selects de llaves foráneas, y la **facturación maestro-detalle** usando los procedimientos almacenados | Sin especificar |

> **El destino del curso:** la v5 es el punto de llegada de la API — de la
> API específica de la v1 (un endpoint por entidad, peticiones con
> validación) se evoluciona hasta una API **genérica** que opera cualquier
> tabla sin conocerla de antemano. Y la v6 le pone encima un front Blazor
> completo. Cada versión intermedia es un paso deliberado de ese camino.

**Reglas del mapa** (constitución, Artículo 1): no se anticipa nada de una
versión futura; una versión cerrada no se reabre (los ajustes van en la
siguiente); el repositorio siempre muestra la versión en curso funcionando.
