// ============================================================
// ProductoReemplazo — la PETICIÓN del PUT (reemplazo COMPLETO).
//
// PUT reemplaza el recurso entero: por eso aquí TODOS los campos
// son obligatorios (el código no viene — viaja en la URL). Un PUT
// al que le falte un campo muere en 422: esa es la semántica del
// verbo, escrita en la petición.
// ============================================================

using System.ComponentModel.DataAnnotations;

namespace ApiFacturas.Peticiones;

public class ProductoReemplazo
{
    [Required(ErrorMessage = "El campo nombre es obligatorio.")]
    [MinLength(1, ErrorMessage = "El campo nombre no puede estar vacío.")]
    public string? Nombre { get; set; }

    [Required(ErrorMessage = "El campo stock es obligatorio.")]
    [Range(0, int.MaxValue,
        ErrorMessage = "El campo stock debe ser un entero mayor o igual a 0.")]
    public int? Stock { get; set; }

    [Required(ErrorMessage = "El campo valorunitario es obligatorio.")]
    [Range(0, double.MaxValue,
        ErrorMessage = "El campo valorunitario debe ser un número mayor o igual a 0.")]
    public decimal? Valorunitario { get; set; }
}
