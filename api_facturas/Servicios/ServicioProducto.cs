// ============================================================
// ServicioProducto — la capa de NEGOCIO de la v1.
//
// Recibe POR CONSTRUCTOR la interfaz del repositorio (inversión
// de dependencias): no sabe si detrás hay SQL Server o un falso
// en memoria para pruebas — y así debe ser.
//
// No conoce HTTP: comunica los problemas con excepciones de
// negocio que el controlador traduce a códigos.
// ============================================================

using ApiFacturas.Excepciones;
using ApiFacturas.Modelos;
using ApiFacturas.Repositorios;

namespace ApiFacturas.Servicios;

// ": IServicioProducto" = esta clase FIRMA el contrato de la interfaz:
// el compilador verifica que tenga TODOS los métodos prometidos.
public class ServicioProducto : IServicioProducto
{
    // El campo donde se guarda la dependencia. "readonly" = se asigna
    // una vez (en el constructor) y nadie la cambia después.
    // Fíjese en el TIPO: la INTERFAZ, no una clase concreta.
    private readonly IRepositorioProducto _repositorio;

    // El constructor recibe el repositorio YA CONSTRUIDO (se lo inyecta
    // el ensamblador de Program.cs) y lo guarda:
    public ServicioProducto(IRepositorioProducto repositorio)
    {
        _repositorio = repositorio;
    }

    // ------------------------------------------------------------
    // Validación pequeña y compartida
    // ------------------------------------------------------------

    private static string ValidarCodigo(string codigo)
    {
        // Trim() quita espacios a los lados; "   " queda como "".
        codigo = codigo.Trim();
        if (codigo == "")
        {
            // throw corta la ejecución AQUÍ y lanza la excepción hacia
            // arriba; el controlador la atrapará y responderá 400.
            throw new ArgumentException("El código del producto no puede estar vacío.");
        }
        return codigo;
    }

    // ------------------------------------------------------------
    // Operaciones de negocio
    // ------------------------------------------------------------

    // "async Task<...>" = método asíncrono; "await" = "espera este
    // resultado sin bloquear el servidor".

    public async Task<List<Producto>> ListarAsync(int limite)
    {
        // El contrato dice 400 (no 422) para límites inválidos:
        // es una REGLA DE NEGOCIO, no un problema de forma del body.
        if (limite <= 0)
        {
            throw new ArgumentException("El límite debe ser un entero mayor que cero.");
        }
        return await _repositorio.ObtenerTodosAsync(limite);
    }

    public async Task<Producto> ObtenerAsync(string codigo)
    {
        codigo = ValidarCodigo(codigo);
        var producto = await _repositorio.ObtenerPorCodigoAsync(codigo);
        // El repositorio devuelve null cuando no hay fila; el NEGOCIO
        // decide que eso es un error y lo dice con SU excepción:
        if (producto == null)
        {
            throw new NoEncontradoExcepcion($"No existe un producto con codigo = {codigo}");
        }
        return producto;
    }

    public async Task CrearAsync(Producto producto)
    {
        // El body ya pasó por la petición ProductoCrear (tipos y rangos):
        // aquí solo se delega. Si la BD rechaza (código duplicado →
        // viola la PK), la SqlException sube tal cual y el controlador
        // la convierte en 500.
        await _repositorio.CrearAsync(producto);
    }

    public async Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos)
    {
        codigo = ValidarCodigo(codigo);
        // Un PATCH con body {} pasó la validación de la petición (nada
        // inválido)… pero no tiene sentido de negocio: no hay nada que
        // actualizar → 400.
        if (datos.Count == 0)
        {
            throw new ArgumentException("No se envió ningún campo para actualizar.");
        }
        var filasAfectadas = await _repositorio.ActualizarAsync(codigo, datos);
        // 0 filas afectadas = ese código no existe en la tabla:
        if (filasAfectadas == 0)
        {
            throw new NoEncontradoExcepcion($"No existe un producto con codigo = {codigo}");
        }
        return filasAfectadas;
    }

    public async Task<int> EliminarAsync(string codigo)
    {
        codigo = ValidarCodigo(codigo);
        var filasEliminadas = await _repositorio.EliminarAsync(codigo);
        if (filasEliminadas == 0)
        {
            throw new NoEncontradoExcepcion($"No existe un producto con codigo = {codigo}");
        }
        return filasEliminadas;
    }
}
