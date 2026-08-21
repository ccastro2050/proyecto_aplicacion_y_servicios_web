# Plan técnico — Versión 1: producto + SQL Server (C#/ASP.NET Core)

> **Versión 1** · CÓMO construir lo especificado en [2_spec.md](2_spec.md).
> El porqué de cada decisión: [4_research.md](4_research.md) · contratos
> exactos: [6_contracts.md](6_contracts.md) · orden: [8_tasks.md](8_tasks.md).

---

## 1. Stack

| Pieza | Elección | Por qué |
|---|---|---|
| Lenguaje / framework | **C# sobre ASP.NET Core (.NET 10)** | El stack del curso; controladores con atributos, DI integrada, async nativo |
| Acceso a datos | **Dapper** sobre `Microsoft.Data.SqlClient`, con SQL parametrizado a mano | SQL visible — Dapper mapea fila→objeto pero NO genera SQL (Art. 2, D1) |
| Validación | **Una petición por verbo** con anotaciones (`[Required]`, `[Range]`…) | El framework valida el body contra la petición y responde 422 — la petición ES la frontera |
| Motor (v1) | **SQL Server 2022** (contenedor oficial) | El motor natural del ecosistema .NET; los otros llegan en v3/v4 |
| Contenedor de la API | `mcr.microsoft.com/dotnet/sdk:10.0` + `dotnet watch` | Guardar un `.cs` recompila y reinicia solo (ciclo de desarrollo del curso) |

## 2. Estructura de carpetas

```
(raíz del proyecto)
├── docker-compose.yml                # UN comando: sqlserver + init + api (crece por versiones)
├── db/
│   ├── bdfacturas.sql                # la BD completa, PROVISTA (se copia, no se genera)
│   └── init.sh                       # el inicializador (SQL Server no auto-ejecuta scripts)
└── api_facturas/
    ├── ApiFacturas.csproj            # el proyecto .NET (paquetes: SqlClient y Swashbuckle)
    ├── Program.cs                    # punto de entrada: ENSAMBLADOR (DI) + 422 + rutas
    ├── appsettings.json              # cadena de conexión (default localhost:11463)
    ├── Dockerfile                    # sdk:10.0 + dotnet watch (puerto 8032)
    ├── Modelos/
    │   └── Producto.cs               # el MODELO = la ENTIDAD: 4 propiedades tipadas
    ├── Peticiones/
    │   ├── ProductoCrear.cs          # petición del POST (todo obligatorio)
    │   ├── ProductoReemplazo.cs      # petición del PUT (todo obligatorio, sin código)
    │   └── ProductoActualizar.cs     # petición del PATCH (todo opcional)
    ├── Controllers/
    │   └── ProductoController.cs     # HTTP: atributos de verbo, try/catch → códigos
    ├── Servicios/
    │   ├── IServicioProducto.cs      # interface del servicio
    │   └── ServicioProducto.cs       # reglas de negocio; recibe IRepositorioProducto
    ├── Repositorios/
    │   ├── IRepositorioProducto.cs   # interface: 5 métodos de datos (async)
    │   └── RepositorioProductoSqlServer.cs   # Dapper + SQL a mano parametrizado
    ├── Excepciones/
    │   └── NoEncontradoExcepcion.cs  # la excepción de negocio que el controller vuelve 404
    └── pruebas/
        ├── PruebaCapas.csproj        # proyecto de consola aparte (criterio 6)
        └── Programa.cs               # el servicio con un repositorio falso, sin BD
```

## 3. Arquitectura en capas (flujo de una petición)

```
HTTP → ASP.NET routing        (los atributos [HttpGet]/[HttpPost]… deciden el método)
     → validación de la PETICIÓN (anotaciones de la petición del verbo → 422 automático)
     → ProductoController     (try/catch: traduce excepciones a códigos HTTP)
     → IServicioProducto      (interfaz — reglas de negocio)
     → IRepositorioProducto   (interfaz — el servicio no sabe qué motor hay detrás)
     → RepositorioProductoSqlServer (Dapper + parámetros @)
     → SQL Server
```

**Regla de dependencias:** controller → servicio → interfaz de repositorio.
Solo el ENSAMBLADOR (la sección de DI de `Program.cs`) conoce clases
concretas.

## 4. Decisiones de diseño clave

### 4.1 Interfaces de C# desde v1
```csharp
public interface IRepositorioProducto
{
    Task<List<Producto>> ObtenerTodosAsync(int limite);   // lista de objetos Producto
    Task<Producto?> ObtenerPorCodigoAsync(string codigo); // el modelo, o null
    Task CrearAsync(Producto producto);                   // recibe el modelo
    Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos); // PUT y PATCH
    Task<int> EliminarAsync(string codigo);
}
```
El servicio recibe **la interfaz** por constructor (la inyecta el
ensamblador). Esto es lo que compra la v3: un segundo motor será otra clase
con `: IRepositorioProducto`. Las lecturas devuelven **objetos del modelo**;
`ActualizarAsync` va con diccionario porque un PATCH puede traer solo
algunos campos.

### 4.2 La validación vive en las PETICIONES (una por verbo)
ASP.NET valida el body contra la petición del verbo ANTES de ejecutar el
método del controlador — el 422 sale solo (personalizado en `Program.cs`
para responder `{estado, mensaje, errores:[…]}`):

- `ProductoCrear`      → POST: todos obligatorios (con código)
- `ProductoReemplazo`  → PUT: todos obligatorios (el código va en la URL)
- `ProductoActualizar` → PATCH: todos opcionales (se valida lo que llegue)

Reglas: `codigo` 1–10 caracteres · `nombre` no vacío · `stock` entero ≥ 0 ·
`valorunitario` numérico ≥ 0. **El tipo también es regla**: `stock` es
`int?` — un `7.5` o un `"texto"` no encajan y caen en 422. (El body vacío
en PATCH es 400 y lo decide el **servicio**: no es un problema de forma
sino de regla de negocio.)

### 4.3 El ensamblador: la sección de DI de Program.cs
```csharp
builder.Services.AddScoped<IRepositorioProducto>(
    _ => new RepositorioProductoSqlServer(cadenaConexion));
builder.Services.AddScoped<IServicioProducto, ServicioProducto>();
```
Sin fábrica multi-motor ni selección: v1 tiene UN motor y el código lo dice.
Cuando v3 agregue PostgreSQL, **solo esta sección** se convierte en la
fábrica real — controllers y servicios no se tocan (ese es el examen de la
v3).

### 4.4 SQL del repositorio (Dapper, siempre parametrizado)
```sql
SELECT TOP (@limite) codigo, nombre, stock, valorunitario FROM producto ORDER BY codigo
SELECT … WHERE codigo = @codigo
INSERT INTO producto (codigo, nombre, stock, valorunitario) VALUES (@codigo, @nombre, @stock, @valorunitario)
UPDATE producto SET … WHERE codigo = @codigo_clave   -- los campos que lleguen (PUT: los 3; PATCH: los enviados)
DELETE FROM producto WHERE codigo = @codigo
```
- `TOP (@limite)` es el "LIMIT" del dialecto SQL Server (y acepta parámetro).
- Dapper ejecuta ese SQL tal cual: `QueryAsync<Producto>` para lecturas
  (mapea columna→propiedad por nombre) y `ExecuteAsync` para escrituras
  (devuelve filas afectadas). Conexión por operación con `await using`;
  todo `async`.
- El SET del UPDATE se arma solo con columnas que salen de las PETICIONES
  (lista blanca), nunca con claves del cliente.
- Detalle amable del motor: en SQL Server, las filas afectadas de un UPDATE
  cuentan las que CUMPLIERON el WHERE (aunque el valor nuevo sea igual al
  viejo) — un PATCH con el mismo valor reporta 1 fila, sin trucos.

### 4.5 Traducción de excepciones a HTTP (en el controller)
| Situación | HTTP |
|---|---|
| (Body con errores de forma — lo responde el framework con la lista) | 422 |
| `ArgumentException` (regla de negocio: límite ≤ 0, body vacío en PATCH) | 400 |
| `NoEncontradoExcepcion` (código inexistente) | 404 |
| `SqlException` y cualquier otra | 500 (mensaje del motor en `detalle`) |

Cada método del controller lleva su propio `try/catch` plano, de arriba a
abajo — sin indirecciones.

### 4.6 SQL Server necesita un INICIALIZADOR
A diferencia de otros motores, SQL Server no ejecuta automáticamente los
scripts que se le monten. Por eso el compose trae un segundo contenedor
(`sqlserver-init`) que espera a que el motor esté sano, corre `db/init.sh`
(crea la BD si no existe y ejecuta `bdfacturas.sql`) y termina. La API
arranca con `depends_on: condition: service_completed_successfully` — solo
cuando la BD ya existe con sus datos.

## 5. Docker: un solo comando desde v1

La constitución (Artículo 4) manda: `docker compose up -d --build` deja TODO
funcionando. En v1 eso son **tres servicios**: `sqlserver` (11463 al host),
`sqlserver-init` (corre una vez) y `api-facturas` (8032, código montado +
`dotnet watch`, `bin/` y `obj/` en volúmenes anónimos para no mezclar
compilados de Linux con los de Windows). El detalle línea por línea está en
el `docker-compose.yml` de la raíz, comentado.
