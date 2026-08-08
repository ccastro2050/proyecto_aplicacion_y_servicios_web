# El paradigma de Programación Orientada a Objetos (P.O.O.) — en C#

> Documento conceptual del curso: qué es un paradigma, qué propone la
> P.O.O., y dónde se ve cada idea EN el código de este proyecto.

---

## 1. ¿Qué es un paradigma de programación?

Un **paradigma** es una forma de pensar y organizar los programas: qué
piezas existen, cómo se combinan y qué se considera "buen diseño".
Ejemplos: el imperativo/estructurado (secuencia, decisión, ciclo), el
funcional (funciones puras, sin estado) y el **orientado a objetos**, que
propone organizar el programa en **objetos**: unidades que juntan DATOS
(propiedades) y COMPORTAMIENTO (métodos).

C# es un lenguaje **orientado a objetos de nacimiento**: todo el código
vive en clases, y el framework (ASP.NET Core) está construido sobre estas
ideas — por eso este curso ES un curso de P.O.O. aplicada.

## 2. Los 4 pilares, con su ejemplo en este proyecto

### Encapsulamiento
Juntar datos y comportamiento, y **controlar el acceso**. En C#, la
herramienta central son las **propiedades** — `{ get; set; }` — que SON los
getters y setters del lenguaje (C# los escribe por usted):

```csharp
public class Producto
{
    public required string Codigo { get; set; }   // propiedad: get/set automáticos
    public int Stock { get; set; }
}
```

Y en las capas: `RepositorioProductoSqlServer` guarda su cadena de conexión
como `private readonly` — nadie más en el sistema sabe que existe.

### Herencia
Una clase extiende a otra y recibe lo suyo. En la v1:
`NoEncontradoExcepcion : Exception` — hereda todo lo que una excepción sabe
hacer (llevar mensaje, lanzarse, atraparse) y solo aporta su NOMBRE, que es
lo que permite el `catch` selectivo (404 vs 500).

### Polimorfismo
**El requisito central del proyecto**: piezas intercambiables tras una
interfaz. `ServicioProducto` funciona igual con
`RepositorioProductoSqlServer` (el real) que con `RepositorioFalsoEnMemoria`
(el de la prueba de capas) — porque ambos firman `: IRepositorioProducto`.
Cuando la v3 agregue PostgreSQL, será OTRA clase con la misma interfaz.

### Abstracción
Quedarse con lo esencial y esconder el detalle. Las **interfaces**
(`IServicioProducto`, `IRepositorioProducto`) son abstracción pura: declaran
QUÉ se puede hacer sin una línea de CÓMO. El controlador depende de la
abstracción, no del detalle.

## 3. Ideas de P.O.O. que C# trae "de fábrica" (y la v1 usa)

- **Tipos estrictos**: `int Stock` rechaza texto; `decimal` para dinero
  (exacto, sin errores de redondeo de los float).
- **Propiedades con `required`**: no se puede construir un `Producto` sin
  código o sin nombre — el compilador lo exige.
- **Inyección de dependencias integrada**: el "ensamblador" de Program.cs
  (los `AddScoped`) entrega las implementaciones concretas a quien pida la
  interfaz por constructor. Composición sobre herencia.
- **El modelo declara y el framework valida**: los modelos por verbo
  (`ProductoCrear`, `ProductoReemplazo`, `ProductoActualizar`) llevan sus
  reglas como ANOTACIONES (`[Required]`, `[Range]`) — objetos que se
  autodescriben, y ASP.NET hace cumplir la descripción (el 422).

## 4. Justificación: por qué P.O.O. para este proyecto

1. **El dominio se modela solo:** producto, factura, cliente… son objetos
   naturales con datos y reglas propias.
2. **El polimorfismo es EL requisito:** la meta del proyecto (cambiar de
   motor de BD sin tocar código) es literalmente un ejercicio de
   polimorfismo — repositorios intercambiables tras una interfaz.
3. **Probabilidad de prueba:** el criterio de aceptación 6 de la v1 (probar
   el servicio con un repositorio falso en memoria) solo es posible porque
   el servicio depende de una abstracción, no de SQL Server.
4. **Puente a SOLID:** los principios SOLID
   ([SOLID_Y_CAPAS.md](SOLID_Y_CAPAS.md)) son reglas de diseño **dentro**
   del paradigma orientado a objetos — sin P.O.O. no hay SOLID que aplicar.

## 5. Ejemplo resumido: la v1 vista con lentes de P.O.O.

```
Producto (el modelo)             ← la clase entidad: el dato con tipos
ProductoCrear / Reemplazo / Actualizar ← la frontera: declaran reglas por verbo
ProductoController               ← objeto HTTP; compone un IServicioProducto
ServicioProducto                 ← objeto de NEGOCIO; compone un IRepositorioProducto
IRepositorioProducto             ← contrato (interface): abstracción pura
RepositorioProductoSqlServer     ← implementación concreta (encapsula ADO.NET y SQL)
RepositorioFalsoEnMemoria        ← otra implementación (¡polimorfismo!) para probar sin BD
NoEncontradoExcepcion            ← herencia: una Exception con nombre propio
```

## 6. Referencias

1. Microsoft — *Object-Oriented programming (C#)*:
   <https://learn.microsoft.com/dotnet/csharp/fundamentals/tutorials/oop>
2. Microsoft — Propiedades en C#:
   <https://learn.microsoft.com/dotnet/csharp/programming-guide/classes-and-structs/properties>
3. Microsoft — Interfaces en C#:
   <https://learn.microsoft.com/dotnet/csharp/fundamentals/types/interfaces>
4. En este repositorio: [SOLID_Y_CAPAS.md](SOLID_Y_CAPAS.md) y el código
   de `api_facturas/` (comentado línea a línea).
