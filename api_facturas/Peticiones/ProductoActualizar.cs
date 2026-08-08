// ============================================================
// ProductoActualizar — la PETICIÓN del PATCH (actualización parcial).
//
// PATCH modifica SOLO lo que llegue: por eso aquí NINGÚN campo
// es obligatorio (no hay [Required]) — pero el que llegue SÍ se
// valida con sus reglas. El contraste con ProductoReemplazo es
// la lección del verbo: el MISMO body {"stock": 7} falla en PUT
// (le faltan campos) y pasa en PATCH.
//
// Si el body llega vacío ({}), eso NO es problema de forma sino
// de negocio: lo decide el servicio con un 400.
// ============================================================

using System.ComponentModel.DataAnnotations;

namespace ApiFacturas.Peticiones;

public class ProductoActualizar
{
    // Sin [Required]: el campo puede no venir (queda null = "no enviado").
    [MinLength(1, ErrorMessage = "El campo nombre no puede estar vacío.")]
    public string? Nombre { get; set; }

    [Range(0, int.MaxValue,
        ErrorMessage = "El campo stock debe ser un entero mayor o igual a 0.")]
    public int? Stock { get; set; }

    [Range(0, double.MaxValue,
        ErrorMessage = "El campo valorunitario debe ser un número mayor o igual a 0.")]
    public decimal? Valorunitario { get; set; }
}
