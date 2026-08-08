// ============================================================
// Program.cs — el PUNTO DE ENTRADA de la API (el "main" de .NET).
//
// Aquí se arma la aplicación: se registran los servicios (el
// ENSAMBLADOR de las capas), se configura cómo responder cuando
// una petición no valida (422), y se encienden las rutas.
//
// El recorrido completo de una petición está explicado en
// docs/FLUJO_DE_UNA_PETICION.md.
// ============================================================

// "using" trae tipos de otros espacios de nombres para poder usarlos:
using ApiFacturas.Repositorios;
using ApiFacturas.Servicios;
using Microsoft.AspNetCore.Mvc;

// El "builder" es el constructor de la aplicación: a él se le
// registra TODO antes de arrancar.
var builder = WebApplication.CreateBuilder(args);

// ------------------------------------------------------------
// 1. EL ENSAMBLADOR — el único lugar que conoce clases concretas
// ------------------------------------------------------------
// Aquí se le dice al contenedor de dependencias de .NET qué clase
// concreta entregar cuando alguien pida una INTERFAZ:
//   - pide IRepositorioProducto → recibe RepositorioProductoSqlServer
//   - pide IServicioProducto    → recibe ServicioProducto
// El controlador y el servicio JAMÁS hacen "new" de clases concretas:
// las reciben por constructor (inyección de dependencias).
// Cuando la v3 agregue otro motor, SOLO estas líneas cambiarán.

// La cadena de conexión: viene de appsettings.json, y en Docker la
// sobreescribe la variable de entorno ConnectionStrings__SqlServer.
var cadenaConexion = builder.Configuration.GetConnectionString("SqlServer")
    ?? throw new InvalidOperationException("Falta la cadena de conexión 'SqlServer'.");

// AddScoped = "una instancia por petición HTTP" (cada request estrena la suya):
builder.Services.AddScoped<IRepositorioProducto>(
    _ => new RepositorioProductoSqlServer(cadenaConexion));
builder.Services.AddScoped<IServicioProducto, ServicioProducto>();

// ------------------------------------------------------------
// 2. Los controladores y la validación de la petición (el 422)
// ------------------------------------------------------------
// AddControllers activa el sistema de controladores ([ApiController]).
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(opciones =>
    {
        // Cuando un body NO cumple las reglas de su petición (las anotaciones
        // [Required], [Range]... de Peticiones/), ASP.NET arma solo la
        // respuesta de error. Aquí la personalizamos para que sea un
        // 422 con la lista de errores — el formato del contrato:
        opciones.InvalidModelStateResponseFactory = contexto =>
        {
            // Recorrer el ModelState y sacar cada mensaje de error:
            var errores = new List<string>();
            foreach (var campo in contexto.ModelState)
            {
                foreach (var error in campo.Value.Errors)
                {
                    errores.Add(error.ErrorMessage);
                }
            }
            // ObjectResult = "responde este objeto como JSON, con este código":
            return new ObjectResult(new
            {
                estado = 422,
                mensaje = "Datos inválidos.",
                errores
            })
            { StatusCode = 422 };
        };
    });

// ------------------------------------------------------------
// 2b. Swagger — la documentación interactiva de la API
// ------------------------------------------------------------
// Swashbuckle lee los controladores y sus clases de datos y genera una página
// donde se ven TODOS los endpoints y se pueden probar desde el
// navegador (http://localhost:8032/swagger).
builder.Services.AddEndpointsApiExplorer();   // descubre los endpoints
builder.Services.AddSwaggerGen();             // arma el documento OpenAPI

// Construir la aplicación con todo lo registrado:
var app = builder.Build();

// Encender Swagger: el JSON (OpenAPI) y la página interactiva:
app.UseSwagger();
app.UseSwaggerUI();

// ------------------------------------------------------------
// 3. Las rutas
// ------------------------------------------------------------

// GET / — diagnóstico (usable como healthcheck). MapGet registra una
// ruta directa sin necesidad de un controlador:
app.MapGet("/", () => Results.Json(new
{
    mensaje = "API Facturas funcionando",
    version = "v1",
    contratos = "docs/spec_kit/versiones/v1_producto_sqlserver/6_contracts.md"
}));

// MapControllers enciende las rutas declaradas con atributos en los
// controladores ([Route], [HttpGet], [HttpPost]...):
app.MapControllers();

// Arrancar y quedarse escuchando (el puerto lo fija ASPNETCORE_URLS
// en el Dockerfile: 8032):
app.Run();
