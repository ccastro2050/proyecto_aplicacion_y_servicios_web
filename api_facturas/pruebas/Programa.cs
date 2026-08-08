// ============================================================
// Programa.cs — Prueba de capas (criterio 6 de la v1).
//
// Verifica que ServicioProducto funciona con un repositorio
// FALSO en memoria que implementa IRepositorioProducto — sin
// SQL Server corriendo.
//
// Si esto pasa, las capas quedaron bien cortadas (polimorfismo +
// inversión de dependencias): el servicio depende de la INTERFAZ,
// no del motor.
//
// Este archivo usa "instrucciones de nivel superior" de C#: el
// programa se escribe directo, sin envolverlo en una clase Main.
// Regla del lenguaje: esas instrucciones van PRIMERO y las clases
// de apoyo (el repositorio falso) se declaran AL FINAL del archivo.
// ============================================================

using ApiFacturas.Excepciones;
using ApiFacturas.Modelos;
using ApiFacturas.Repositorios;
using ApiFacturas.Servicios;

// ------------------------------------------------------------
// La prueba: el MISMO ServicioProducto de la API, pero armado con
// el repositorio falso (polimorfismo). Un guion de verificaciones.
// ------------------------------------------------------------

var servicio = new ServicioProducto(new RepositorioFalsoEnMemoria());

// El ciclo completo contra el repositorio falso. Las lecturas
// devuelven OBJETOS Producto: se pregunta por sus propiedades.
await servicio.CrearAsync(new Producto { Codigo = "T1", Nombre = "Test", Stock = 5, Valorunitario = 100m });
Verificar((await servicio.ListarAsync(10))[0].Codigo == "T1", "crear + listar");
Verificar((await servicio.ObtenerAsync("T1")).Nombre == "Test", "obtener por código");
Verificar(await servicio.ActualizarAsync("T1", new() { ["stock"] = 9 }) == 1, "actualizar");
Verificar((await servicio.ObtenerAsync("T1")).Stock == 9, "el stock quedó en 9");
Verificar(await servicio.EliminarAsync("T1") == 1, "eliminar");

// Las excepciones de negocio también funcionan sin BD:
try { await servicio.ObtenerAsync("NOEXISTE"); Verificar(false, "debió lanzar NoEncontradoExcepcion"); }
catch (NoEncontradoExcepcion) { /* esperado */ }

try { await servicio.ActualizarAsync("T1", new()); Verificar(false, "debió lanzar ArgumentException"); }
catch (ArgumentException) { /* esperado */ }

try { await servicio.ListarAsync(0); Verificar(false, "debió lanzar ArgumentException"); }
catch (ArgumentException) { /* esperado */ }

Console.WriteLine("CRITERIO 6 OK: el servicio funciona con el repositorio falso, sin SQL Server");

// Mini-verificador (función local): si la condición es falsa, reporta
// y sale con error (terminar con 0 = pasó; con 1 = falló).
static void Verificar(bool condicion, string descripcion)
{
    if (!condicion)
    {
        Console.Error.WriteLine($"FALLÓ: {descripcion}");
        Environment.Exit(1);
    }
}

// ------------------------------------------------------------
// El REPOSITORIO FALSO: cumple el mismo contrato que el de SQL
// Server, pero guarda los Producto en un diccionario en memoria —
// cero SQL, cero red. Como el servicio depende de la INTERFAZ,
// no nota la diferencia.
// ------------------------------------------------------------
class RepositorioFalsoEnMemoria : IRepositorioProducto
{
    // El "almacén": código → Producto.
    private readonly Dictionary<string, Producto> _datos = new();

    // Los métodos del contrato son async (devuelven Task); como aquí
    // no hay nada que esperar, se responde con Task.FromResult
    // ("promesa ya cumplida con este valor"):

    public Task<List<Producto>> ObtenerTodosAsync(int limite)
    {
        // Ordenar por código y tomar los primeros 'limite' (como el TOP):
        var lista = _datos.Values.OrderBy(p => p.Codigo).Take(limite).ToList();
        return Task.FromResult(lista);
    }

    public Task<Producto?> ObtenerPorCodigoAsync(string codigo)
    {
        // TryGetValue busca la llave; si no está, producto queda null:
        _datos.TryGetValue(codigo, out var producto);
        return Task.FromResult(producto);
    }

    public Task CrearAsync(Producto producto)
    {
        _datos[producto.Codigo] = producto;
        return Task.CompletedTask;   // promesa cumplida, sin valor
    }

    public Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos)
    {
        if (!_datos.TryGetValue(codigo, out var producto))
        {
            return Task.FromResult(0);   // 0 filas = no existía
        }
        // Se escriben SOLO los campos que llegaron, con los setters
        // de las propiedades del modelo:
        if (datos.TryGetValue("nombre", out var nombre)) { producto.Nombre = (string)nombre; }
        if (datos.TryGetValue("stock", out var stock)) { producto.Stock = (int)stock; }
        if (datos.TryGetValue("valorunitario", out var valor)) { producto.Valorunitario = (decimal)valor; }
        return Task.FromResult(1);
    }

    public Task<int> EliminarAsync(string codigo)
    {
        // Remove devuelve true si la llave existía; se traduce a 1/0 filas:
        return Task.FromResult(_datos.Remove(codigo) ? 1 : 0);
    }
}
