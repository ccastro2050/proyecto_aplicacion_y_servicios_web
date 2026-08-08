// ============================================================
// ProductoController — la capa HTTP de la v1.
//
// Su único trabajo: recibir la petición (ASP.NET ya validó el
// body contra la PETICIÓN del verbo → 422 automático), delegar al
// servicio, y responder JSON con el código correcto.
// Aquí NO hay SQL ni reglas de negocio.
//
// ¿DÓNDE ESTÁ EL GET, EL POST...? En los ATRIBUTOS sobre cada
// método: [HttpGet], [HttpPost], [HttpPut], [HttpPatch],
// [HttpDelete]. ASP.NET lee el verbo y la ruta de la petición
// que llegó y llama al método cuyo atributo coincida — la misma
// comparación que en otros stacks se escribe a mano, aquí la
// hace el framework por dentro.
//
// Traducción a códigos HTTP (contrato de 6_contracts.md §0):
//   Body con errores de forma → 422 (lo arma Program.cs con la
//                                    lista de errores de la petición)
//   ArgumentException         → 400 (regla de negocio)
//   NoEncontradoExcepcion     → 404
//   SqlException y demás      → 500 (mensaje del motor en detalle)
// ============================================================

using ApiFacturas.Excepciones;
using ApiFacturas.Modelos;
using ApiFacturas.Peticiones;
using ApiFacturas.Servicios;
using Microsoft.AspNetCore.Mvc;

namespace ApiFacturas.Controllers;

// [ApiController] activa la validación automática del body contra el
// body contra su petición (el 422) y el enlace de parámetros.
// [Route("api/producto")] = TODAS las rutas de esta clase cuelgan de ahí.
[ApiController]
[Route("api/producto")]
public class ProductoController : ControllerBase
{
    // La dependencia: LA INTERFAZ del servicio (no una clase concreta).
    // readonly = se asigna una vez, en el constructor.
    private readonly IServicioProducto _servicio;

    // El constructor la recibe YA CONSTRUIDA (la inyecta el ensamblador
    // registrado en Program.cs):
    public ProductoController(IServicioProducto servicio)
    {
        _servicio = servicio;
    }

    // ------------------------------------------------------------
    // GET /api/producto[?limite=N]  →  listar
    // ------------------------------------------------------------
    // [FromQuery] = el parámetro viene del query string; si no viene,
    // vale 1000 (el valor por defecto declarado).
    [HttpGet]
    public async Task<IActionResult> Listar([FromQuery] int limite = 1000)
    {
        try
        {
            var productos = await _servicio.ListarAsync(limite);

            if (productos.Count == 0)
            {
                // 204 = éxito SIN contenido: tabla vacía.
                return NoContent();
            }
            // Ok(...) = 200 con el objeto como JSON. La "envoltura" de
            // las lecturas: metadatos + datos.
            return Ok(new
            {
                tabla = "producto",
                limite,
                total = productos.Count,
                datos = productos,
            });
        }
        catch (ArgumentException e)
        {
            // Regla de negocio rota (ej. límite <= 0) → 400.
            // StatusCode(código, objeto) = responde ese JSON con ese código:
            return StatusCode(400, new { estado = 400, mensaje = "Parámetros inválidos.", detalle = e.Message });
        }
        catch (Exception e)
        {
            // Exception atrapa TODO lo demás (ej. la BD no responde) → 500:
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }

    // ------------------------------------------------------------
    // GET /api/producto/{codigo}  →  obtener uno
    // ------------------------------------------------------------
    // El {codigo} de la ruta llega como parámetro del método:
    [HttpGet("{codigo}")]
    public async Task<IActionResult> Obtener(string codigo)
    {
        try
        {
            // Si existe → 200 con el Producto (el serializador lo vuelve
            // JSON solo). Si no existe, el servicio LANZA la excepción y
            // este método salta directo al catch del 404.
            var producto = await _servicio.ObtenerAsync(codigo);
            return Ok(producto);
        }
        catch (ArgumentException e)
        {
            return StatusCode(400, new { estado = 400, mensaje = "Parámetros inválidos.", detalle = e.Message });
        }
        catch (NoEncontradoExcepcion e)
        {
            return StatusCode(404, new { estado = 404, mensaje = "Producto no encontrado.", detalle = e.Message });
        }
        catch (Exception e)
        {
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }

    // ------------------------------------------------------------
    // POST /api/producto  →  crear (body completo, con código)
    // ------------------------------------------------------------
    // [FromBody] ProductoCrear body = ASP.NET toma el JSON, lo vuelca en
    // la PETICIÓN del verbo y lo VALIDA contra sus anotaciones. Si algo no
    // cumple, este método NI SE EJECUTA: Program.cs ya respondió 422 con
    // la lista de errores. Aquí solo entra data limpia.
    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] ProductoCrear body)
    {
        try
        {
            // El NEGOCIO construye el objeto del MODELO entidad: desde
            // este punto el producto viaja tipado. Los "!" le dicen al
            // compilador "confía: no es null" (lo garantizó [Required]).
            var producto = new Producto
            {
                Codigo = body.Codigo!,
                Nombre = body.Nombre!,
                Stock = body.Stock!.Value,
                Valorunitario = body.Valorunitario!.Value,
            };

            await _servicio.CrearAsync(producto);
            return Ok(new { estado = 200, mensaje = "Producto creado exitosamente." });
        }
        catch (Exception e)
        {
            // Ej.: código duplicado — la BD rechaza por llave primaria:
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }

    // ------------------------------------------------------------
    // PUT /api/producto/{codigo}  →  reemplazo COMPLETO
    // ------------------------------------------------------------
    // La petición ProductoReemplazo exige TODOS los campos: un PUT con
    // body parcial muere en 422 ANTES de llegar aquí — esa es la
    // semántica de PUT, escrita en la petición.
    [HttpPut("{codigo}")]
    public async Task<IActionResult> Reemplazar(string codigo, [FromBody] ProductoReemplazo body)
    {
        try
        {
            // Armar el diccionario columna→valor con los 3 campos (en
            // PUT siempre vienen los 3 — la petición lo garantizó):
            var datos = new Dictionary<string, object>
            {
                ["nombre"] = body.Nombre!,
                ["stock"] = body.Stock!.Value,
                ["valorunitario"] = body.Valorunitario!.Value,
            };

            var filas = await _servicio.ActualizarAsync(codigo, datos);
            return Ok(new { estado = 200, mensaje = "Producto reemplazado exitosamente.", filasAfectadas = filas });
        }
        catch (ArgumentException e)
        {
            return StatusCode(400, new { estado = 400, mensaje = "Parámetros inválidos.", detalle = e.Message });
        }
        catch (NoEncontradoExcepcion e)
        {
            return StatusCode(404, new { estado = 404, mensaje = "Producto no encontrado.", detalle = e.Message });
        }
        catch (Exception e)
        {
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }

    // ------------------------------------------------------------
    // PATCH /api/producto/{codigo}  →  actualización PARCIAL
    // ------------------------------------------------------------
    // ProductoActualizar no exige campos: valida SOLO los que llegaron.
    // El MISMO body {"stock": 99} que en PUT da 422, aquí pasa — la
    // diferencia entre PUT y PATCH queda escrita en las peticiones.
    [HttpPatch("{codigo}")]
    public async Task<IActionResult> Actualizar(string codigo, [FromBody] ProductoActualizar body)
    {
        try
        {
            // Armar el diccionario SOLO con lo que vino (lo que quedó
            // null en la petición = no fue enviado). Esta es la lista
            // blanca: solo estas 3 columnas pueden viajar al SQL.
            var datos = new Dictionary<string, object>();
            if (body.Nombre != null) { datos["nombre"] = body.Nombre; }
            if (body.Stock != null) { datos["stock"] = body.Stock.Value; }
            if (body.Valorunitario != null) { datos["valorunitario"] = body.Valorunitario.Value; }

            // El body vacío NO es 422: es una regla de negocio (400) que
            // decide el servicio — forma vs negocio, cada cosa en su capa.
            var filas = await _servicio.ActualizarAsync(codigo, datos);
            return Ok(new { estado = 200, mensaje = "Producto actualizado exitosamente.", filasAfectadas = filas });
        }
        catch (ArgumentException e)
        {
            return StatusCode(400, new { estado = 400, mensaje = "Parámetros inválidos.", detalle = e.Message });
        }
        catch (NoEncontradoExcepcion e)
        {
            return StatusCode(404, new { estado = 404, mensaje = "Producto no encontrado.", detalle = e.Message });
        }
        catch (Exception e)
        {
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }

    // ------------------------------------------------------------
    // DELETE /api/producto/{codigo}  →  eliminar
    // ------------------------------------------------------------
    [HttpDelete("{codigo}")]
    public async Task<IActionResult> Eliminar(string codigo)
    {
        try
        {
            var filas = await _servicio.EliminarAsync(codigo);
            return Ok(new { estado = 200, mensaje = "Producto eliminado exitosamente.", filasEliminadas = filas });
        }
        catch (ArgumentException e)
        {
            return StatusCode(400, new { estado = 400, mensaje = "Parámetros inválidos.", detalle = e.Message });
        }
        catch (NoEncontradoExcepcion e)
        {
            return StatusCode(404, new { estado = 404, mensaje = "Producto no encontrado.", detalle = e.Message });
        }
        catch (Exception e)
        {
            return StatusCode(500, new { estado = 500, mensaje = "Error interno.", detalle = e.Message });
        }
    }
}
