// ============================================================
// ProductoCrear — el modelo del BODY del POST (crear producto).
//
// LA FRONTERA DE ENTRADA de la API: hay UN modelo por semántica
// HTTP (este para POST, ProductoReemplazo para PUT y
// ProductoActualizar para PATCH), y cada uno DECLARA sus reglas
// con anotaciones. ASP.NET valida el body contra el modelo ANTES
// de que el controlador lo toque: si algo no cumple, responde
// 422 con la lista de errores (configurado en Program.cs) y el
// dato malo jamás llega al servicio ni a la BD.
// ============================================================

// Las anotaciones de validación ([Required], [Range]...) viven aquí:
using System.ComponentModel.DataAnnotations;

namespace ApiFacturas.Modelos;

public class ProductoCrear
{
    // Cada anotación es UNA regla, con su mensaje de error en español.
    // Se apilan: un campo puede tener varias.

    [Required(ErrorMessage = "El campo codigo es obligatorio.")]
    [StringLength(10, MinimumLength = 1,
        ErrorMessage = "El campo codigo debe tener entre 1 y 10 caracteres.")]
    public string? Codigo { get; set; }
    // ↑ El "?" (nullable) es a propósito: si el campo NO viene en el
    //   JSON queda null, y es [Required] quien reporta el error con
    //   mensaje claro (en vez de reventar antes de validar).

    [Required(ErrorMessage = "El campo nombre es obligatorio.")]
    [MinLength(1, ErrorMessage = "El campo nombre no puede estar vacío.")]
    public string? Nombre { get; set; }

    [Required(ErrorMessage = "El campo stock es obligatorio.")]
    [Range(0, int.MaxValue,
        ErrorMessage = "El campo stock debe ser un entero mayor o igual a 0.")]
    public int? Stock { get; set; }
    // ↑ Al ser int?, un JSON con "stock": "texto" o 7.5 NO encaja en el
    //   tipo y el binder lo reporta como error → 422. El TIPO es regla.

    [Required(ErrorMessage = "El campo valorunitario es obligatorio.")]
    [Range(0, double.MaxValue,
        ErrorMessage = "El campo valorunitario debe ser un número mayor o igual a 0.")]
    public decimal? Valorunitario { get; set; }
}
