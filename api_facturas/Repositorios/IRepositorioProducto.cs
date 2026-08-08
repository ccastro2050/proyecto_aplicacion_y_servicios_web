// ============================================================
// IRepositorioProducto — el CONTRATO de la capa de datos.
//
// Una interface de C# define QUÉ operaciones existen sobre
// producto, sin decir CÓMO ni CONTRA QUÉ motor. Cualquier clase
// que declare ": IRepositorioProducto" puede ocupar este lugar:
// el SQL Server real de la v1, el falso en memoria de las
// pruebas, o el PostgreSQL que llegará en la v3 (polimorfismo).
//
// El servicio depende de ESTA interfaz, nunca de una clase
// concreta (inversión de dependencias — la D de SOLID).
//
// Todos los métodos son ASÍNCRONOS (devuelven Task): mientras la
// BD responde, el servidor atiende otras peticiones. "async/await"
// es la norma en ASP.NET.
// ============================================================

using ApiFacturas.Modelos;

namespace ApiFacturas.Repositorios;

public interface IRepositorioProducto
{
    /// <summary>Hasta 'limite' productos ordenados por código.
    /// Task&lt;List&lt;Producto&gt;&gt; = "promesa de una lista de Producto".</summary>
    Task<List<Producto>> ObtenerTodosAsync(int limite);

    /// <summary>El Producto con ese código, o null si no existe
    /// (el "?" en Producto? = puede venir null).</summary>
    Task<Producto?> ObtenerPorCodigoAsync(string codigo);

    /// <summary>Inserta el producto (llega como objeto del modelo).</summary>
    Task CrearAsync(Producto producto);

    /// <summary>Escribe los campos del diccionario (los usan PUT y PATCH).
    /// Va como diccionario columna→valor porque un PATCH puede traer
    /// SOLO algunos campos. Devuelve filas afectadas (0 = no existe).</summary>
    Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos);

    /// <summary>Elimina el producto. Devuelve filas eliminadas (0 = no existía).</summary>
    Task<int> EliminarAsync(string codigo);
}
