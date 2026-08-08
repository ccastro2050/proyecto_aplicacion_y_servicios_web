# SOLID y programación por capas — en este proyecto

> Documento conceptual del curso: los 5 principios SOLID y la arquitectura
> por capas, cada uno con su ejemplo REAL en el código de la versión en
> curso — y en qué versión futura se termina de demostrar.

---

## 1. Programación por capas (la arquitectura del proyecto)

```
HTTP → Controller   (capa 1: presentación — códigos de estado y JSON)
     → Servicio     (capa 2: negocio — reglas y decisiones)
     → Repositorio  (capa 3: datos — SQL y conexión)
     → BD
```

**La regla:** cada capa solo habla con la siguiente, y siempre **a través
de una interfaz**. El controller no toca SQL; el servicio no conoce HTTP ni
el motor; el repositorio no conoce HTTP.

**¿Para qué?** Cada capa se puede cambiar, probar y entender POR SEPARADO.
La prueba viviente en la v1: `pruebas/` corre el servicio real con un
repositorio falso en memoria — sin BD. Eso solo es posible porque las capas
están bien cortadas.

## 2. Los 5 principios SOLID, uno por uno

### S — Responsabilidad única (Single Responsibility)
Cada clase tiene UNA razón para cambiar: el controller si cambia el
protocolo HTTP; el servicio si cambian las reglas de negocio; el
repositorio si cambia el SQL; los modelos del verbo si cambian las reglas
de forma del body. Ninguna clase hace dos de esas cosas.

### O — Abierto/Cerrado (Open/Closed)
Abierto a extensión, cerrado a modificación. **El examen será la v3**:
agregar PostgreSQL debe ser AGREGAR una clase
(`RepositorioProductoPostgreSql : IRepositorioProducto`) y tocar SOLO el
ensamblador — sin modificar controller, servicio ni la interfaz.

### L — Sustitución de Liskov
Cualquier implementación de la interfaz puede ocupar el lugar de otra sin
romper nada. Ya pasa en la v1: `RepositorioFalsoEnMemoria` sustituye a
`RepositorioProductoSqlServer` en las pruebas y el servicio ni se entera.

### I — Segregación de interfaces
Interfaces pequeñas y específicas: `IRepositorioProducto` tiene SOLO los 5
métodos de datos de producto — no un "IRepositorioDeTodo" que obligue a
implementar métodos que no se usan.

### D — Inversión de dependencias
Las capas de arriba dependen de ABSTRACCIONES, no de clases concretas:

```csharp
public ServicioProducto(IRepositorioProducto repositorio)  // ← interfaz, no clase
```

Solo el **ensamblador** (la sección de DI en `Program.cs`) conoce las
clases concretas. Eso es literalmente "invertir" la dependencia: el detalle
(SQL Server) depende del contrato, no al revés.

## 3. El mapa SOLID ↔ versiones del curso

| Principio | Se ve desde | Se termina de demostrar en |
|---|---|---|
| S | v1 (una clase por responsabilidad) | v2 (más entidades, mismas responsabilidades) |
| O | v1 (la interfaz existe) | **v3** (segundo motor sin tocar lo construido) |
| L | v1 (el repositorio falso de las pruebas) | v3/v4 (motores intercambiables de verdad) |
| I | v1 (interfaces mínimas) | v5 (la API genérica separa contratos por capacidad) |
| D | v1 (constructores reciben interfaces) | v3 (la fábrica reemplaza al ensamblador simple) |

## 4. Referencias

1. Martin, R. — *Design Principles and Design Patterns* (el texto original
   de SOLID).
2. Microsoft — Inyección de dependencias en .NET:
   <https://learn.microsoft.com/dotnet/core/extensions/dependency-injection>
3. En este repositorio: [PARADIGMA_POO.md](PARADIGMA_POO.md) (los pilares
   sobre los que SOLID se apoya) y el spec kit de la versión en curso.
