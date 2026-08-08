// ============================================================
// IServicioProducto — el CONTRATO de la capa de negocio.
//
// El controlador depende de esta interfaz: no sabe (ni debe
// saber) qué hay detrás. Los métodos comunican problemas con
// excepciones de NEGOCIO que el controlador traduce a HTTP:
//   ArgumentException        → 400
//   NoEncontradoExcepcion    → 404
//   SqlException y demás     → 500
// ============================================================

using ApiFacturas.Modelos;

namespace ApiFacturas.Servicios;

public interface IServicioProducto
{
    /// <summary>Hasta 'limite' productos. ArgumentException si limite &lt;= 0.</summary>
    Task<List<Producto>> ListarAsync(int limite);

    /// <summary>El Producto con ese código. NoEncontradoExcepcion si no existe.</summary>
    Task<Producto> ObtenerAsync(string codigo);

    /// <summary>Crea el producto (el body ya fue validado por la petición
    /// ProductoCrear; el servicio construye la entidad).</summary>
    Task CrearAsync(Producto producto);

    /// <summary>Escribe los campos enviados (PUT manda todos, PATCH un
    /// subconjunto). ArgumentException si no llegó ningún campo ·
    /// NoEncontradoExcepcion si el código no existe · devuelve filas afectadas.</summary>
    Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos);

    /// <summary>Elimina. NoEncontradoExcepcion si no existe · devuelve filas eliminadas.</summary>
    Task<int> EliminarAsync(string codigo);
}
