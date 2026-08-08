// ============================================================
// Producto — el MODELO (la clase entidad) de la v1.
//
// Representa UNA fila de la tabla producto como un objeto con
// tipos. En C#, las "propiedades" ({ get; set; }) SON los getters
// y setters del lenguaje: C# los escribe por nosotros y se usan
// como si fueran campos (producto.Stock = 5; leer producto.Stock),
// pero por debajo pasan por un método get y un método set.
// ============================================================

// namespace = el "apellido" de la clase: agrupa el código por carpetas
// lógicas y evita choques de nombres entre proyectos.
namespace ApiFacturas.Modelos;

public class Producto
{
    // Cada propiedad lleva su TIPO. El compilador garantiza que un
    // Stock jamás sea texto.
    //
    // "required" (C# moderno) = obligatorio al construir el objeto:
    // no se puede crear un Producto sin código o sin nombre.

    /// <summary>Identificador único, ej. "PR001" (la llave primaria).</summary>
    public required string Codigo { get; set; }

    /// <summary>Nombre del producto, ej. "Laptop Lenovo IdeaPad".</summary>
    public required string Nombre { get; set; }

    /// <summary>Unidades disponibles (entero).</summary>
    public int Stock { get; set; }

    /// <summary>Precio unitario. "decimal" es el tipo para dinero en C#:
    /// exacto, sin los errores de redondeo de los float.</summary>
    public decimal Valorunitario { get; set; }

    // Nota: no necesita un método "toArray" ni nada especial para el
    // JSON — el serializador de ASP.NET convierte las propiedades
    // públicas automáticamente: {"codigo":"PR001","nombre":...}.
}
