# Calidad de las pruebas — cobertura, CRAP y mutation testing

> Documento conceptual del curso. Pregunta que responde: **¿cómo sé que
> mis pruebas de verdad protegen el código?** — la pregunta se volvió
> urgente en la era de la IA: si un agente escribe el código (y hasta las
> pruebas), alguien tiene que poder verificar, de forma DETERMINISTA, que
> esa red de seguridad no es de mentiras. Ese alguien es usted: la
> responsabilidad no se delega.

---

## 1. Cobertura (coverage): la métrica famosa — y la más malinterpretada

**Qué es:** el porcentaje del código que sus pruebas EJECUTAN. Si los
tests recorren 80 de 100 líneas, hay 80% de cobertura de línea (también
existe la de rama: ¿se probaron el `if` Y el `else`?).

**La trampa:** ejecutar una línea NO es verificarla. Esta prueba sube la
cobertura y no protege nada:

```
# Prueba HUECA: ejecuta el método... y no verifica NADA
resultado = servicio.crear_producto(datos)
# (sin assert: si crear_producto guarda mal, esta prueba PASA)
```

**Cómo leerla bien:** cobertura BAJA sí es una alarma confiable (hay
código que nadie ejecuta jamás en pruebas); cobertura ALTA, sola, no
garantiza nada. Es un termómetro necesario pero no suficiente.

## 2. Complejidad ciclomática y la métrica CRAP

**Complejidad ciclomática:** cuántos caminos independientes tiene un
método (cada `if`, `for`, `case`, `&&` suma caminos). Un método de
complejidad 1 es una línea recta; uno de complejidad 15 es un laberinto.

**CRAP** (*Change Risk Anti-Patterns*, de Alberto Savoia y Bob Evans)
combina las dos cosas que hacen peligroso un método — qué tan enredado
está y qué tan desprotegido está:

```
CRAP(m) = complejidad(m)² × (1 − cobertura(m))³ + complejidad(m)
```

| Método | Complejidad | Cobertura | CRAP | Lectura |
|---|---|---|---|---|
| simple y probado | 3 | 100% | 3 | tranquilo |
| simple sin probar | 3 | 0% | 12 | aceptable |
| enredado y probado | 15 | 100% | 15 | vigilable |
| enredado SIN probar | 15 | 0% | **240** | 🚨 bomba: nadie lo quiere tocar |

**Para qué sirve:** es un detector de zonas de miedo. Un CRAP alto dice
"simplifique este método o escríbale pruebas ANTES de volverlo a tocar".
El umbral clásico es 30.

## 3. Mutation testing: la prueba de las pruebas

**Qué es:** en vez de medir cuánto código ejecutan sus pruebas, mide si
sus pruebas SE DAN CUENTA cuando el código se daña. La herramienta
introduce bugs pequeños a propósito — los **mutantes** — y corre sus
pruebas contra cada uno:

```
original:   if (limite > 0)  { ... }
mutante 1:  if (limite >= 0) { ... }     ← ¿algún test falla?
mutante 2:  if (limite < 0)  { ... }     ← ¿algún test falla?
```

- Si algún test **falla** → el mutante "murió" → esa regla SÍ está
  vigilada. ✅
- Si todos los tests **pasan** con el bug adentro → el mutante
  "sobrevivió" → esa prueba es decorativa: ejecuta el código pero no lo
  verifica. ❌

**El ejemplo que duele:** en este curso, `?limite=0` debe responder 400
(regla de negocio). Si su prueba solo llama al endpoint con `limite=3` y
verifica el 200, el mutante `> 0 → >= 0` SOBREVIVE: acaba de descubrir
que la regla del límite no la vigila nadie. Eso es exactamente "ir
cambiando cositas para ver si los tests realmente son valiosos".

**La métrica:** el *mutation score* = mutantes muertos / mutantes
creados. Un proyecto puede tener 90% de cobertura y 40% de mutation
score: pruebas que pasean por el código sin mirarlo.

**Por qué importa con IA:** un agente genera con gusto pruebas que
PARECEN serias. La mutación no se puede fingir: o el test mata al
mutante o no lo mata. Es el "ecosistema del cual el agente no se puede
escapar" del que habla Uncle Bob.

## 4. Herramientas para el stack de ESTE repositorio

| Qué medir | Herramienta (C#/.NET) | Cómo se ve |
|---|---|---|
| Cobertura | **coverlet** (`dotnet test /p:CollectCoverage=true`) + ReportGenerator | % por línea y por rama, reporte HTML |
| Complejidad / CRAP | los analizadores de Visual Studio o **SonarQube** | complejidad ciclomática por método |
| Mutación | **Stryker.NET** (`dotnet stryker`) | mutantes creados / matados / sobrevivientes, con reporte HTML |

## 5. ¿Esto es alcance del proyecto del curso? (sugerencia honesta)

**Hoy NO es alcance.** La validación oficial de cada versión ya tiene su
mecanismo, y es deliberadamente más simple: los **criterios de
aceptación** de `2_spec.md`, el **smoke test** de `7_quickstart.md` y la
**prueba de capas** con repositorios falsos. Ese trío es determinista,
se corre en minutos y es lo que se evalúa. Meter cobertura mínima,
umbrales CRAP y mutación como criterios de cierre agregaría una carga de
herramienta que le quitaría tiempo al objetivo del semestre
(arquitectura + SDD).

**Pero la puerta queda señalada.** Si el proyecto siguiera creciendo (o
para un estudiante que quiera ir más lejos), el lugar natural sería:

1. Correr la herramienta de **cobertura** sobre la prueba de capas al
   cerrar cada versión — costo casi cero, da el mapa de lo no ejecutado.
2. Correr **mutación** solo sobre servicios (la capa de reglas): es
   donde los mutantes sobrevivientes duelen y enseñan.
3. Los **sobrevivientes** encontrados se anotan como deuda en
   `4_research.md` — igual que cualquier decisión.

Es un reto opcional excelente para sustentar: llegar a la clase
mostrando qué mutantes sobrevivieron a la prueba de capas (y qué prueba
nueva los mató) demuestra más dominio que cualquier porcentaje.

## 6. Referencias

1. El video que motiva este documento — *Cómo está cambiando la
   ingeniería de software* (Karpathy, Uncle Bob, delegación y control):
   <https://youtu.be/YzZhL324BmM>
2. Savoia, A. & Evans, B. — la métrica CRAP (*Change Risk
   Anti-Patterns*), presentada originalmente en el proyecto crap4j.
3. Stryker Mutator (C#/.NET y JS): <https://stryker-mutator.io/>
4. mutmut (Python): <https://mutmut.readthedocs.io/>
5. Infection (PHP): <https://infection.github.io/>
6. En este repositorio: los criterios de `2_spec.md`, el smoke de
   `7_quickstart.md` y la prueba de capas — la red de seguridad ACTUAL
   del curso, que estas técnicas ampliarían.
