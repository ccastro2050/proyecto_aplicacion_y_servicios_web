// ============================================================
// NoEncontradoExcepcion — la excepción de negocio "el recurso no existe".
//
// La lanza el SERVICIO cuando un código no corresponde a ningún
// producto, y el CONTROLADOR la traduce al código HTTP 404. Así el
// servicio comunica problemas sin saber nada de HTTP (separación
// de capas).
//
// ": Exception" = HEREDA de la excepción base de .NET: ya sabe
// llevar mensaje, lanzarse y atraparse. Lo único que aporta esta
// clase es su NOMBRE, que permite atraparla por separado:
//   catch (NoEncontradoExcepcion e) → 404
//   catch (Exception e)             → 500
// ============================================================

namespace ApiFacturas.Excepciones;

public class NoEncontradoExcepcion : Exception
{
    // El constructor recibe el mensaje y se lo pasa a la clase padre
    // con "base(mensaje)" — Exception ya sabe guardarlo en .Message:
    public NoEncontradoExcepcion(string mensaje) : base(mensaje)
    {
    }
}
