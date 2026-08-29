# SDD y Spec Kit — la metodología de este curso

> Documento conceptual: qué es el desarrollo dirigido por especificaciones
> (SDD), qué es un "spec kit", y cómo se usa EN este proyecto.

---

## 🎬 Antes de leer: el video del método

[![Video: Spec Kit de GitHub — el desarrollo guiado por especificaciones está matando al vibe coding](https://img.youtube.com/vi/_MmsQMLg6yU/maxresdefault.jpg)](https://youtu.be/_MmsQMLg6yU)

> **▶️ [Spec Kit de GitHub: cómo el SDD está matando al "vibe coding"](https://youtu.be/_MmsQMLg6yU)**
> — episodio del podcast *BIM Praxis* (~16 min; voces generadas con
> NotebookLM). Cuenta, con otras palabras, EXACTAMENTE el método de este
> repositorio. **Resumen:**
>
> 1. **El "vibe coding" no tiene cimientos:** pedirle a la IA "hazme una
>    app" en dos líneas parece magia las primeras iteraciones, pero a la
>    tercera o cuarta el proyecto colapsa — dependencias circulares,
>    lógica destrozada. La causa técnica es la **degradación del
>    contexto**: el modelo prioriza lo último que usted dijo y pierde la
>    estrategia global.
> 2. **La constitución es el ancla:** un archivo con las leyes
>    innegociables del proyecto que se inyecta en CADA llamada a la IA.
>    Neutraliza el sesgo estadístico del modelo ("a la mínima te quiere
>    meter un React y una base de datos") y bloquea lo prohibido aunque
>    la conversación sea larga.
> 3. **La spec define el QUÉ sin tecnología** (historias de usuario y
>    criterios de aceptación), y la IA no asiente como un ejecutor
>    servicial: busca ambigüedades y casos límite que usted no pensó —
>    se pone la gorra de arquitecto.
> 4. **El plan y las tareas** convierten la spec en arquitectura técnica
>    y en un grafo de dependencias (qué depende de qué, qué puede ir en
>    paralelo), con la disciplina de escribir la prueba ANTES del código.
> 5. **El código pasa a ser un subproducto:** si toda la lógica vive en
>    los `.md`, cambiar de stack es regenerar — lo que vale oro es la
>    especificación. La competencia clave del profesional deja de ser
>    memorizar sintaxis y pasa a ser **claridad de pensamiento
>    estructural**: definir arquitecturas y comunicarse sin ambigüedades.
>
> **La traducción a este repositorio:** la "constitución" del video es
> nuestro `1_constitution.md`; su *specify* es `2_spec.md` (con historias
> y criterios de aceptación); su *plan* es `3_plan.md`; sus *tasks* son
> `8_tasks.md` con las fases verificables. Usted ya está trabajando así.

## 1. El problema que ataca SDD

El vicio clásico: escribir código primero y documentar después (o nunca).
Resultado: nadie sabe qué DEBERÍA hacer el sistema, las decisiones viven en
la cabeza de alguien, y cada cambio es arqueología.

**SDD (Spec-Driven Development)** lo invierte: primero se escribe la
**especificación** — QUÉ construir, CÓMO, con qué criterios de aceptación —
y el código viene después, A CUMPLIRLA. La spec es la fuente de verdad; el
código es su implementación.

La era de la IA lo volvió urgente: una IA puede escribir el código, pero
solo escribe EL CORRECTO si alguien le da una especificación precisa. En
este curso usted lo vive: la [GUIA_IA.md](GUIA_IA.md) construye la versión
entregándole a una IA el spec kit — y nada más.

## 2. El spec kit de este proyecto (8 documentos numerados)

| # | Documento | Pregunta que responde | Qué encuentra adentro |
|---|---|---|---|
| 1 | `1_constitution.md` | ¿Qué reglas NUNCA se negocian? | Los artículos permanentes del proyecto (capas, SQL parametrizado, sin ORM, "un solo comando", cierre por tags). Es UNO solo para todas las versiones: nada de aquí cambia al pasar de versión. |
| 2 | `2_spec.md` | ¿QUÉ se construye en esta versión y cómo se sabe que quedó bien? | El propósito, el alcance (incluye / NO incluye), los requisitos funcionales y los **criterios de aceptación** medibles que definen "terminada". |
| 3 | `3_plan.md` | ¿CÓMO: stack, estructura, diseño de capas? | El inventario de archivos (los nuevos y los que CRECEN), la estructura de carpetas y el diseño ya aterrizado a código: qué clase va dónde y por qué. |
| 4 | `4_research.md` | ¿POR QUÉ así y no de otra forma? | Las decisiones numeradas (D1, D2…) con las **alternativas descartadas** y su razón — la memoria del proyecto, para no re-discutir lo ya decidido. |
| 5 | `5_data_model.md` | ¿Qué datos hay y qué puede tocar esta versión? | Tablas, columnas, llaves y datos semilla; y las fronteras: qué calcula la BD (triggers, defaults, SPs) y qué tiene PROHIBIDO escribir la API. |
| 6 | `6_contracts.md` | ¿Cuáles son los endpoints EXACTOS (verbos, códigos, formatos)? | Cada endpoint con su verbo, URL, body de ejemplo y TODOS sus códigos de respuesta con el JSON exacto — lo que un cliente puede exigir sin leer el código. |
| 7 | `7_quickstart.md` | ¿Cómo se arranca y se valida rápido? | El comando de arranque y el **smoke test**: la lista de curl que recorre los criterios de aceptación en minutos, con los valores esperados al lado. |
| 8 | `8_tasks.md` | ¿En qué ORDEN se construye, por fases verificables? | Las fases de construcción, cada una con sus tareas y su "**Verificar:**" — la regla es NO avanzar con una fase en rojo. |

- **La constitución es una y permanente**; los documentos 2 a 8 se escriben
  POR VERSIÓN, en `versiones/vN_nombre/`.
- **La versión en curso:**
  [spec_kit/versiones/v1_producto_sqlserver/](spec_kit/versiones/v1_producto_sqlserver/2_spec.md)
  — la spec de la v1 ES el documento que se le entrega a la IA (o al
  estudiante) para construirla.

Un fragmento real de la spec de la v1 (note el estilo: verificable, con
criterios medibles):

```markdown
### RF5 — Actualizar parcialmente (PATCH + body parcial)
`PATCH /api/producto/{codigo}` con body de la petición ProductoActualizar:
campos opcionales — solo se modifican los enviados. Devuelve
filasAfectadas; inexistente → 404; body vacío → 400.

## Criterios de aceptación
4. … un `PUT` sin el campo `nombre` responde 422 (reemplazo completo)
   mientras el mismo body en `PATCH` responde 200 (parcial).
```

### 2.1 Los 8 documentos: qué es, para qué sirve y cómo se hace cada uno

**1. `1_constitution.md` — la ley permanente.**
**Qué es:** los artículos innegociables del proyecto; se escribe UNA vez y
rige TODAS las versiones (en Spec Kit lo genera `/speckit.constitution`;
aquí se escribe a mano).
**Para qué sirve:** ancla el proyecto — y a la IA. Cuando alguien (humano o
agente) proponga "metamos tal cosa", la constitución responde ANTES de
discutir; por eso neutraliza el sesgo del modelo hacia lo que más vio en su
entrenamiento.
**Cómo se hace:** liste las decisiones que NO van a cambiar en el semestre
(capas, seguridad, idioma, forma de cerrar versiones); redáctelas como
artículos numerados, cortos y verificables; si un artículo no se puede
violar "por accidente", no necesita estar.

```markdown
## Artículo 3 — SQL siempre parametrizado
Los valores viajan como @parametros de Dapper; JAMÁS se concatenan
en el SQL. `$"WHERE codigo = '{codigo}'"` es inyección esperando turno.
```

**2. `2_spec.md` — el QUÉ.**
**Qué es:** la especificación funcional de UNA versión: propósito, alcance,
requisitos funcionales (RF numerados) y criterios de aceptación.
**Para qué sirve:** define "terminada" de forma MEDIBLE — es el documento
que se le entrega a la IA o al estudiante para construir la versión, y el
que decide si pasó o no.
**Cómo se hace:** propósito en dos frases; RFs numerados SIN tecnología
(qué, no cómo); por cada RF, criterios con valores concretos (cuántas
filas, qué código HTTP, qué mensaje); y un "NO incluye" explícito — frena
la anticipación, que es el vicio favorito de la IA.

```markdown
### RF5 — Actualizar parcialmente (PATCH + body parcial)
PATCH /api/producto/{codigo} con campos opcionales: solo se
modifican los enviados. Inexistente → 404; body vacío → 400.

## Criterios de aceptación
4. Un PUT sin el campo nombre responde 422 (reemplazo completo)
   mientras el MISMO body en PATCH responde 200 (parcial).
```

**3. `3_plan.md` — el CÓMO.**
**Qué es:** la traducción técnica de la spec: stack, inventario de archivos
y diseño de capas ya aterrizado a código.
**Para qué sirve:** que la arquitectura no se decida "sobre la marcha"
mientras se programa; una IA con plan no inventa estructura.
**Cómo se hace:** estructura de carpetas; tabla de archivos NUEVOS con su
papel; tabla de archivos que CRECEN y qué les crece (los intocables también
se declaran); y las decisiones de diseño de la versión — en la familia
diseño, con sus diagramas Mermaid.

```markdown
**Crecen (los únicos existentes que se tocan):**
| Archivo | Qué crece |
|---|---|
| `Program.cs` | ★ dos AddScoped nuevos (la rebanada persona) |
| `ApiFacturas.csproj` | ★ un paquete nuevo, si la versión lo exige |
```

**4. `4_research.md` — el PORQUÉ.**
**Qué es:** el registro de decisiones (D1, D2…) con sus alternativas
descartadas — lo que la industria llama ADRs (Architecture Decision
Records).
**Para qué sirve:** memoria del proyecto: no se re-discute lo decidido, y
quien llegue después (incluida la IA) entiende por qué el sistema es así y
no de otra forma.
**Cómo se hace:** por cada decisión: contexto (el problema) → opciones
consideradas (a, b, c) → decisión con su razón → consecuencias que se
aceptan. Se escribe CUANDO se decide, no semanas después.

```markdown
## D4 — ¿Por qué PUT y PATCH separados?
**Alternativas:** (a) un solo endpoint "actualizar" · (b) PUT
(reemplazo completo) y PATCH (parcial) con peticiones distintas.
**Decisión: (b)** — la pareja enseña la semántica HTTP: el MISMO
body da 422 en PUT y 200 en PATCH.
```

**5. `5_data_model.md` — los datos y sus fronteras.**
**Qué es:** las tablas, columnas, llaves y semillas que ESTA versión usa, y
la frontera de responsabilidades entre la API y la BD.
**Para qué sirve:** evita el clásico "la API recalcula lo que la BD ya
calcula" — deja escrito qué columnas tiene PROHIBIDO tocar la API.
**Cómo se hace:** tabla por tabla (columna, tipo, regla); anote qué escribe
la BD sola (defaults, autonuméricos, triggers); semillas con valores
EXACTOS, porque el smoke test depende de ellas.

```markdown
| Tabla | PK | Semilla |
|---|---|---|
| producto | codigo | 8 filas (PR001 "Laptop…", stock 17, …) |

El stock lo mueve el TRIGGER al facturar: la API tiene PROHIBIDO
escribirlo directamente.
```

**6. `6_contracts.md` — el contrato HTTP exacto.**
**Qué es:** endpoint por endpoint: verbo, URL, body de ejemplo y TODOS los
códigos de respuesta con su JSON exacto.
**Para qué sirve:** es lo que un cliente (el front futuro, Postman, el
profesor) puede EXIGIR sin leer el código; al cerrar la versión, estos
contratos se congelan.
**Cómo se hace:** un bloque por endpoint; incluya los desenlaces de ERROR
(404, 422, 500) con su formato — el error también es contrato; los valores
de ejemplo salen de las semillas del 5_data_model.

```markdown
POST /api/producto
body { "codigo": "PR009", "nombre": "Webcam", "stock": 10,
       "valorunitario": 350000 }
→ 200 {estado, mensaje} · 422 si falta un campo o stock < 0 (con
  errores[]) · 500 si el código ya existe (PK duplicada, en detalle)
```

**7. `7_quickstart.md` — la validación en minutos.**
**Qué es:** el arranque en un comando más el smoke test: la lista de
comandos que recorre los criterios de aceptación con el valor esperado al
lado de cada uno.
**Para qué sirve:** "me funciona" deja de ser una opinión — cualquiera
valida la versión en minutos; y en las versiones siguientes se convierte en
la REGRESIÓN (lo viejo debe seguir pasando).
**Cómo se hace:** el comando de arranque; un comando por criterio, en
orden, con el resultado esperado como comentario; y una tabla "Si algo
falla" con las causas probables.

```bash
curl http://localhost:8036/api/producto        # total: 8
curl -i http://localhost:8036/api/producto/PR999   # → 404
```

**8. `8_tasks.md` — el orden, por fases verificables.**
**Qué es:** el plan de construcción dividido en fases, cada una con su
lista de tareas y su compuerta "**Verificar:**".
**Para qué sirve:** convierte el plan en un camino sin saltos: la compuerta
impide avanzar con una fase rota — es la versión artesanal del grafo de
dependencias que `/speckit.tasks` genera.
**Cómo se hace:** ordene de lo que no depende de nada hacia lo que depende
de todo (modelo → repositorio → servicio → controlador); cada fase termina
en un estado COMPROBABLE (`dotnet build`); la verificación se escribe
como comando concreto, no como "revisar que funcione".

```markdown
## Fase 2 — El modelo y las peticiones
- [ ] Modelos/Producto.cs (la entidad: 4 propiedades tipadas)
- [ ] Peticiones/ProductoCrear.cs (todo obligatorio, con [Required])

**Verificar:** `dotnet build` compila sin errores.
```

**La regla que une a los ocho:** si está en la spec y no en el código, el
código está incompleto; si está en el código y no en la spec, sobra — o
falta especificarlo.

**El ciclo de una versión:** leer la spec → seguir las tareas fase por
fase → correr el quickstart → si los criterios pasan, commit + tag (`v1`) →
solo entonces se escribe la spec de la siguiente versión.

## 3. Las reglas de juego del curso

1. **La spec manda sobre el código.** Si el código hace algo que la spec no
   dice, sobra; si la spec pide algo que el código no hace, falta.
2. **No se anticipa** (YAGNI): la v1 no construye nada de la v3 "por si
   acaso". Cada versión introduce SU contenido cuando le toca.
   **YAGNI** son las siglas de *You Aren't Gonna Need It* — "no lo vas a
   necesitar": no se agrega una funcionalidad ni una línea de código hasta
   que hoy haga falta. No es pereza: lo que se escribe "por si acaso" hay
   que mantenerlo, probarlo y explicarlo desde el primer día, casi siempre
   adivinando mal la necesidad futura. Aquí la disciplina tiene además una
   consecuencia práctica: es lo que hace que cada versión sea pequeña y
   verificable — y es la regla que una IA rompe primero, porque su sesgo
   es agregar de más.
3. **Cerrado es cerrado:** una versión con tag no se reabre; los ajustes
   van a la siguiente (y se anotan como "deuda de spec" si aplica).
4. **Autocontenido:** el spec kit debe bastar para reconstruir la versión
   desde cero sin leer el código existente — esa es la prueba de calidad
   de la spec (y el experimento de la GUIA_IA).

## 4. Referencias

1. GitHub — *Spec Kit* (la herramienta que popularizó el término):
   <https://github.com/github/spec-kit>
2. Especificación por el ejemplo: Adzic, G. — *Specification by Example*
   (Manning, 2011).
3. En este repositorio: el [spec kit completo](spec_kit/1_constitution.md)
   y la [GUIA_IA.md](GUIA_IA.md) que lo pone a prueba.
