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
| v5 | Frontend **Blazor Server**: CRUD de las 12 entidades (una página por tabla), **login y control de acceso con JWT**, selects de llaves foráneas, y la **facturación maestro-detalle** usando los procedimientos almacenados | Sin especificar |

> **El destino del curso:** la API específica queda COMPLETA y
> multi-motor; la última versión le pone encima un front **Blazor**
> completo, con login y control de acceso. Cada versión intermedia es un paso deliberado de ese camino.

**Reglas del mapa** (constitución, Artículo 1): no se anticipa nada de una
versión futura; una versión cerrada no se reabre (los ajustes van en la
siguiente); el repositorio siempre muestra la versión en curso funcionando.
