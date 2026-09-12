# Pruebas y calidad de las pruebas

> **Documento conceptual del curso.** Va en dos partes, y en este orden a
> propósito:
>
> **Primero, qué es una prueba** y cómo se escribe una que sirva.
> **Después, quién prueba a las pruebas** — porque una prueba también puede
> estar mal hecha, y eso casi nadie lo cuenta.
>
> La segunda parte se volvió urgente con la IA: si un agente escribe el
> código **y las pruebas**, alguien tiene que poder verificar, de forma
> determinista, que esa red de seguridad no es de mentiras. Ese alguien es
> usted.

---

# PARTE 1 — Las pruebas

## 1. Qué es una prueba automática

Es **código que ejecuta su código y comprueba que hizo lo que debía**.

La diferencia con probar a mano no es la comodidad: es que **una prueba
automática se puede volver a correr**. La comprobación manual se hace una
vez, el lunes, y el jueves ya nadie sabe si sigue funcionando.

Una prueba responde siempre a la misma pregunta:

> **Dado** este estado de partida, **cuando** hago esto, **entonces** debe
> pasar aquello.

Si usted no puede llenar esos tres huecos, todavía no sabe qué va a probar.

---

## 2. La forma de toda prueba: preparar, ejecutar, comprobar

Se llama **AAA** (*Arrange, Act, Assert*) o, en español, **preparar,
ejecutar, comprobar**. Toda prueba tiene esas tres partes, aunque no estén
separadas por comentarios.

Esto es de la prueba de capas de **este** repositorio, en
`api_facturas/pruebas/Programa.cs`:

```csharp
// PREPARAR (Arrange): el servicio, armado con un repositorio falso en memoria
var servicio = new ServicioProducto(new RepositorioFalsoEnMemoria());

// EJECUTAR (Act): la operación que se quiere probar
await servicio.CrearAsync(new Producto { Codigo = "T1", Nombre = "Test", Stock = 5, Valorunitario = 100m });

// COMPROBAR (Assert): la línea que PUEDE FALLAR — esta línea ES la prueba
Verificar((await servicio.ListarAsync(10))[0].Codigo == "T1", "crear + listar");
```

> **Los comentarios en mayúscula no están en el archivo:** los agregué
> aquí para señalar las partes. El código sí es el de su repositorio,
> línea por línea — vaya y compárelo.


**La tercera parte es la prueba.** Las dos primeras solo montan la escena. Si
borra el `Verificar`, el programa sigue corriendo, sigue sin dar error… y ya
no está probando nada. Vuelva a esta idea en la Parte 2, porque es el origen
de todo lo que viene.

### Probar que algo FALLA también es probar

Media aplicación es rechazar lo que no debe entrar. Eso se prueba al revés:
se provoca el error y se comprueba que **sí ocurrió**.

```csharp
try
{
    await servicio.ObtenerAsync("NOEXISTE");
    Verificar(false, "debió lanzar NoEncontradoExcepcion");   // si llega aquí, NO falló: mal
}
catch (NoEncontradoExcepcion)
{
    /* esperado: la regla funciona */
}
```

Fíjese en el `Verificar(false, …)`: está puesto **después** de la llamada
para el caso en que la excepción no ocurra. Sin esa línea, una prueba que
debía fallar y no falló pasaría en silencio.


### «verificar» es un `assert` hecho a mano

Si ha visto pruebas en otra parte, le va a faltar una palabra: **`assert`**.
Ese es el nombre estándar de **la línea que puede fallar**, y cada lenguaje
tiene la suya:

| Dónde | Cómo se escribe |
|---|---|
| Python (pytest) | la palabra reservada `assert` |
| C# (xUnit) | `Assert.Equal(esperado, obtenido)` |
| PHP (PHPUnit) | `$this->assertSame(...)` |
| **Este curso** | `Verificar(condición, "descripción")` |

**Es lo mismo.** En este proyecto está escrito a mano:

```csharp
// Con xUnit, un framework de pruebas:
Assert.Equal("T1", (await servicio.ListarAsync(10))[0].Codigo);

// En este curso, sin framework:
Verificar((await servicio.ListarAsync(10))[0].Codigo == "T1", "crear + listar");
```

### ¿Por qué a mano, y no con xUnit?

Porque la prueba de capas es **un solo archivo que corre sin instalar nada**.
Se ejecuta con el mismo comando del lenguaje, sin agregar un framework al
proyecto, sin configurarlo y sin que haya que aprenderlo en la versión 1.

| | A mano | Con framework |
|---|---|---|
| Dependencias | **Ninguna** | Una más, y su configuración |
| Ver qué hace un `assert` por dentro | **Sí**: son cuatro líneas, ahí están | No: es una caja negra |
| Descubrir y correr pruebas sueltas | No | **Sí** |
| Reporte con nombres, tiempos y fallos | No | **Sí** |
| Preparación compartida (*fixtures*) | No | **Sí** |

**No estamos haciendo otra cosa: estamos haciendo lo mismo sin la
herramienta.** Cuando el proyecto crezca, xUnit entra y `Verificar` se retira — y para
entonces usted ya sabrá qué es lo que hace, porque lo escribió.

> **Lo esencial no cambia nunca:** una prueba es una línea que **puede
> fallar**. Se llame `assert`, `Assert.Equal` o `Verificar`.

---

## 3. Los tipos de prueba, y cuál cuesta cuánto

| Tipo | Qué prueba | Necesita | Velocidad |
|---|---|---|---|
| **Unitaria** | Una pieza sola: un método, una regla | Nada más | Milisegundos |
| **De integración** | Dos o más piezas juntas: el servicio **con** la base | La base corriendo | Segundos |
| **De extremo a extremo** | El sistema completo, como lo usa una persona | Todo levantado | Minutos |

La **pirámide de pruebas** —la idea la popularizó Mike Cohn— dice que
conviene tener **muchas de las baratas y pocas de las caras**: base ancha de
unitarias, menos de integración, unas pocas de extremo a extremo.

**La razón no es la velocidad, es el diagnóstico.** Cuando una prueba
unitaria falla, usted sabe exactamente qué método está mal. Cuando falla una
de extremo a extremo, sabe que *algo* de veinte piezas está mal.

> **En este proyecto:** la prueba de capas es **unitaria** (el servicio con un
> repositorio falso), y el *smoke test* del `7_quickstart.md` es de **extremo
> a extremo** (la API de verdad, contra la base de verdad).

---

## 4. El doble de prueba: por qué existe el repositorio falso

Para probar el **servicio** —donde viven las reglas— no hace falta la base de
datos. Se le pasa en su lugar una pieza falsa que cumple la misma interfaz:

```csharp
var servicio = new ServicioProducto(new RepositorioFalsoEnMemoria());
```

Eso es un **doble de prueba** (*test double*), y aquí es posible **porque el
servicio depende de `IRepositorioProducto`, no del motor**. Es el
polimorfismo haciendo su trabajo.

**Qué se gana:**

| | Con la base | Con el doble |
|---|---|---|
| Tiempo | Segundos | Milisegundos |
| ¿Hay que levantar algo? | Sí | No |
| Si falla, ¿de quién es la culpa? | Puede ser de la base, de la red o del código | **Del código** |

Y hay algo más importante: **si su servicio NO se puede probar sin la base,
las capas están mal cortadas.** La prueba de capas no solo verifica reglas —
verifica la arquitectura. Por eso es el criterio 6 de la v1.

---

## 5. Qué hace buena a una prueba

| Cualidad | Qué significa | Cómo se ve cuando falta |
|---|---|---|
| **Comprueba algo** | Tiene una línea que puede fallar | La prueba pasa siempre, hasta con el código roto |
| **Un solo motivo para fallar** | Prueba una cosa | Falla y hay que adivinar cuál de las cinco cosas se rompió |
| **Nombre que dice qué se espera** | «el stock quedó en 9», no «prueba 3» | El reporte no dice nada |
| **Independiente** | No depende de que otra corriera antes | Pasa sola y falla en grupo, o al revés |
| **Determinista** | Da el mismo resultado siempre | Falla los viernes y nadie sabe por qué |
| **Rápida** | Corre en milisegundos | Nadie la corre |

> **La que más se incumple es la primera**, y es de la que trata toda la
> Parte 2.

---

## 6. La red de seguridad que este proyecto YA tiene

Antes de irse a herramientas grandes, sepa lo que ya hay. Son tres, y las
tres se corren en minutos:

| | Dónde está | Qué protege |
|---|---|---|
| **Criterios de aceptación** | `2_spec.md` de cada versión | Que lo construido sea lo que se pidió |
| **Smoke test** | `7_quickstart.md` | Que el sistema levante y responda de punta a punta |
| **Prueba de capas** | `api_facturas/pruebas/` | Que las reglas funcionen **y** que las capas estén cortadas |

**Eso es lo que se evalúa.** Lo que viene ahora es para entender qué tan
buena es esa red — y para cuando el proyecto crezca.

---

# PARTE 2 — La calidad de las pruebas

## 7. La pregunta incómoda: ¿quién prueba a las pruebas?

Usted escribió veinte pruebas. Todas pasan. **¿Eso qué garantiza?**

Menos de lo que parece. Una prueba puede:

- ejecutar el código **sin comprobar nada**;
- comprobar algo que siempre es cierto (`Verificar(true, …)`);
- probar el caso fácil y no el que de verdad falla.

Y en los tres casos **el reporte se ve igual de verde**.

### La prueba hueca

Esta ejecuta el método y no verifica nada:

```csharp
// PRUEBA HUECA: corre el código… y no comprueba NADA
await servicio.CrearAsync(peticion);
// (sin Verificar: si CrearAsync guarda mal, esto "pasa")
```

La que sí protege lleva **una línea que puede fallar**:

```csharp
await servicio.CrearAsync(peticion);
Verificar((await servicio.ObtenerAsync(peticion.Codigo)).Nombre == peticion.Nombre,
          "el nombre quedó guardado");
```

**Las dos ejecutan exactamente las mismas líneas del código.** Para cualquier
herramienta que mida «cuánto código tocaron mis pruebas», valen lo mismo. Ahí
empieza el problema de la sección siguiente.

---

## 8. Cobertura: la métrica famosa, y la más malinterpretada

**Qué es:** el porcentaje del código que sus pruebas **ejecutan**. Si
recorren 80 de 100 líneas, hay 80 % de cobertura de línea. También existe la
**de rama**: ¿se probaron el `if` **y** el `else`?

**La trampa:** *ejecutar* una línea no es *verificarla*. La prueba hueca de
arriba **sube la cobertura igual** que la buena.

**Cómo leerla bien:**

| Lectura | ¿Confiable? |
|---|---|
| Cobertura **baja** | **Sí.** Hay código que nadie ejecuta jamás en pruebas. Alarma real |
| Cobertura **alta** | **No, por sí sola.** Puede ser código paseado, no verificado |

Es un termómetro **necesario pero no suficiente**.

---

## 9. Complejidad ciclomática y la métrica CRAP

**Complejidad ciclomática:** cuántos caminos independientes tiene un método.
Cada `if`, `for`, `case`, `&&` suma uno. Complejidad 1 es una línea recta;
complejidad 15 es un laberinto.

**CRAP** (*Change Risk Anti-Patterns*) combina las dos cosas que hacen
peligroso un método: **qué tan enredado está** y **qué tan desprotegido**:

```
CRAP(m) = complejidad(m)² × (1 − cobertura(m))³ + complejidad(m)
```

| Método | Complejidad | Cobertura | CRAP | Lectura |
|---|---|---|---|---|
| simple y probado | 3 | 100 % | 3 | tranquilo |
| simple sin probar | 3 | 0 % | 12 | aceptable |
| enredado y probado | 15 | 100 % | 15 | vigilable |
| enredado **sin probar** | 15 | 0 % | **240** | 🚨 nadie lo quiere tocar |

**Para qué sirve:** es un detector de zonas de miedo. Un CRAP alto dice
«simplifique este método, o escríbale pruebas **antes** de volverlo a tocar».
El umbral clásico es **30**.

---

## 10. *Mutation testing*: la prueba de las pruebas

Esta es la parte que sorprende, así que va despacio.

### La idea, en una frase

> **Si yo daño su código a propósito, ¿alguna prueba suya se da cuenta?**

Si ninguna se entera, esas pruebas no lo están protegiendo — por más verdes
que se vean.

### Cómo funciona, paso a paso

**Paso 1.** Usted tiene una regla en su servicio. Esta es real, de este
proyecto: el límite del listado debe ser mayor que cero.

```csharp
if (limite <= 0)
    throw new ArgumentException("El límite debe ser un entero mayor que cero.");
```

**Paso 2.** La herramienta hace copias de su código **con un cambio pequeño
en cada una**. Cada copia es un **mutante**:

| | El código | Qué se cambió |
|---|---|---|
| Original | `if (limite <= 0)` | — |
| Mutante 1 | `if (limite < 0)` | `<=` por `<` |
| Mutante 2 | `if (limite >= 0)` | `<=` por `>=` |
| Mutante 3 | *(la línea que lanza el error, borrada)* | se quitó el efecto |

**Paso 3.** Corre **sus pruebas** contra cada mutante.

**Paso 4.** Se mira quién se murió:

| Resultado | Qué significa |
|---|---|
| Alguna prueba **falla** | El mutante **murió** ✅ — esa regla **sí** está vigilada |
| Todas las pruebas **pasan** | El mutante **sobrevivió** ❌ — nadie vigila esa regla |

### El ejemplo que duele

Suponga que su única prueba del listado es esta:

```csharp
Verificar((await servicio.ListarAsync(10)).Count >= 0, "listar funciona");
```

Pasa. Da cobertura. Y contra el **mutante 1** (`limite < 0`) **también pasa**,
porque usted nunca llamó con `0`. El mutante sobrevive, y acaba de
descubrir que **la regla del límite no la vigila nadie**.

La prueba que lo mata es la que provoca el caso:

```csharp
try { await servicio.ListarAsync(0); Verificar(false, "debió rechazar límite 0"); }
catch (ArgumentException) { /* esperado */ }
```

**Esa línea es la que hay en la prueba de capas de este repositorio.** No
está por adorno: es la que mata ese mutante.

### La métrica

**Mutation score** = mutantes muertos ÷ mutantes creados.

Un proyecto puede tener **90 % de cobertura y 40 % de mutation score**:
pruebas que pasean por el código sin mirarlo.

| Métrica | Qué mide | Se puede fingir |
|---|---|---|
| Cobertura | Cuánto código **se ejecutó** | **Sí**: basta llamar los métodos |
| Mutation score | Cuánto código **se verificó** | **No**: o la prueba falla con el bug adentro, o no falla |

### Por qué esto importa ahora

Un agente de IA genera con gusto pruebas que **parecen** serias: nombres
largos, estructura impecable, y ni un `Verificar` que pueda fallar. La
mutación no se deja convencer por la apariencia: **o el test mata al mutante
o no lo mata**.

> **Y usted puede hacer esto a mano, hoy, sin instalar nada.** Abra su
> servicio, cambie un `<=` por un `<`, corra la prueba de capas y mire si
> falla. Si pasa, encontró un hueco. Devuelva el cambio.
>
> Eso es *mutation testing* con las manos. La herramienta solo lo hace mil
> veces y más rápido.

---

## 11. Herramientas para el stack de ESTE repositorio

| Qué medir | Herramienta (C#/.NET) | Cómo se ve |
|---|---|---|
| Cobertura | **coverlet** (`dotnet test /p:CollectCoverage=true`) + ReportGenerator | % por línea y por rama, reporte HTML |
| Complejidad / CRAP | los analizadores de Visual Studio o **SonarQube** | complejidad ciclomática por método |
| Mutación | **Stryker.NET** (`dotnet stryker`) | mutantes creados / matados / sobrevivientes, con reporte HTML |

---

## 12. ¿Esto es alcance del proyecto del curso?

**Hoy no.** La validación de cada versión ya tiene su mecanismo, y es
deliberadamente más simple: los **criterios de aceptación**, el **smoke test**
y la **prueba de capas** (sección 6). Ese trío es determinista, corre en
minutos y es lo que se evalúa. Meter umbrales de cobertura y de mutación
como criterios de cierre agregaría una carga de herramienta que le quitaría
tiempo al objetivo del semestre: **arquitectura y SDD**.

**Pero la puerta queda señalada.** Si el proyecto creciera —o si usted quiere
ir más lejos—, el orden natural sería:

1. **Cobertura** sobre la prueba de capas al cerrar cada versión. Costo casi
   cero, y da el mapa de lo que nadie ejecuta.
2. **Mutación solo sobre los servicios**, que es donde viven las reglas y
   donde los sobrevivientes duelen y enseñan.
3. Los **sobrevivientes** se anotan como deuda en `4_research.md`, igual que
   cualquier otra decisión.

Llegar a sustentar mostrando **qué mutantes sobrevivieron y qué prueba nueva
los mató** demuestra más dominio que cualquier porcentaje.

---

## 13. Referencias

1. **Beck, Kent.** *Test-Driven Development: By Example.* Addison-Wesley,
   2002. — De aquí sale el ciclo rojo-verde-refactor y la disciplina de
   escribir primero la comprobación.
2. **Cohn, Mike.** *Succeeding with Agile: Software Development Using Scrum.*
   Addison-Wesley, 2009. — Donde se populariza la **pirámide de pruebas**.
3. **Meszaros, Gerard.** *xUnit Test Patterns: Refactoring Test Code.*
   Addison-Wesley, 2007. — El catálogo de los **dobles de prueba** y de los
   olores de las pruebas mal hechas.
4. **Fowler, Martin** — *Test Double* y *Test Pyramid*, en su bliki:
   `https://martinfowler.com/bliki/TestDouble.html` ·
   `https://martinfowler.com/bliki/TestPyramid.html`
5. **Savoia, A. y Evans, B.** — la métrica **CRAP** (*Change Risk
   Anti-Patterns*), presentada en el proyecto crap4j.
6. **Stryker Mutator** (C#/.NET y JS): `https://stryker-mutator.io/`
7. **mutmut** (Python): `https://mutmut.readthedocs.io/`
8. **Infection** (PHP): `https://infection.github.io/`
9. El video que motivó la Parte 2 — *Cómo está cambiando la ingeniería de
   software* (Karpathy, Uncle Bob, delegación y control):
   `https://youtu.be/YzZhL324BmM`
10. En este repositorio: los criterios de `2_spec.md`, el smoke de
    `7_quickstart.md` y la prueba de capas de `api_facturas/pruebas/` — la
    red de seguridad **actual**, que estas técnicas ampliarían.
