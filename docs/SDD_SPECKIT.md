# SDD y Spec Kit — la metodología de este curso

> Documento conceptual: qué es el desarrollo dirigido por especificaciones
> (SDD), qué es un "spec kit", y cómo se usa EN este proyecto.

---

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

### 2.1 Cada documento por dentro (un ejemplo corto de cada uno)

**`1_constitution.md` — la ley.** Artículos numerados que ninguna versión
puede violar; si algo "exige" romper uno, esa es una discusión mayor que
queda registrada:

```markdown
## Artículo 3 — SQL siempre parametrizado
Los valores viajan como @parametros; JAMÁS se concatenan en el SQL.
```

**`2_spec.md` — el QUÉ.** Requisitos y criterios que se pueden VERIFICAR
(nada de "debe ser fácil de usar"):

```markdown
## Criterios de aceptación
2. GET /api/producto responde los 8 productos semilla (total: 8).
3. GET /api/producto/PR999 responde 404 con {estado, mensaje, detalle}.
```

**`3_plan.md` — el CÓMO.** El inventario y el diseño ANTES de escribir
código — incluida la lista de archivos existentes que crecen:

```markdown
**Crecen (los únicos existentes que se tocan):**
| Archivo | Qué crece |
|---|---|
| `Program.cs` | ★ dos AddScoped nuevos (la rebanada persona) |
```

**`4_research.md` — el PORQUÉ.** Cada decisión con lo que se descartó:

```markdown
## D4 — ¿Por qué PUT y PATCH separados?
**Alternativas:** (a) un solo endpoint de "actualizar" · (b) PUT
(reemplazo completo) y PATCH (parcial) con peticiones distintas.
**Decisión: (b)** — la pareja enseña la semántica HTTP: el MISMO
body da 422 en PUT y 200 en PATCH.
```

**`5_data_model.md` — los datos y sus fronteras.** Qué hay, y qué es
territorio de la BD:

```markdown
| Tabla | PK | Semilla |
|---|---|---|
| producto | codigo | 8 filas (PR001 "Laptop…", stock 17, …) |

El stock lo mueve el TRIGGER al facturar: la API tiene PROHIBIDO
escribirlo directamente.
```

**`6_contracts.md` — el contrato exacto.** Endpoint por endpoint, con
todos los desenlaces posibles:

```markdown
POST /api/producto
body { "codigo": "PR009", "nombre": "Webcam", "stock": 10,
       "valorunitario": 350000 }
→ 200 {estado, mensaje} · 422 si falta un campo o stock < 0 (con
  errores[]) · 500 si el código ya existe (PK duplicada, en detalle)
```

**`7_quickstart.md` — la validación en minutos.** Arrancar y comprobar,
con el valor esperado al lado de cada comando:

```powershell
docker compose up -d --build
curl.exe http://localhost:8032/api/producto              # total: 8
curl.exe -i http://localhost:8032/api/producto/PR999     # → 404
```

**`8_tasks.md` — el orden, por fases verificables.** Cada fase termina
en un estado comprobable:

```markdown
## Fase 2 — El modelo y las peticiones
- [ ] Modelos/Producto.cs (la entidad: 4 propiedades tipadas)
- [ ] Peticiones/ProductoCrear.cs (todo obligatorio, con [Required])
**Verificar:** `dotnet build` compila sin errores.
```

La regla que une a los ocho: **si está en la spec y no en el código, el
código está incompleto; si está en el código y no en la spec, sobra — o
falta especificarlo.**

**El ciclo de una versión:** leer la spec → seguir las tareas fase por
fase → correr el quickstart → si los criterios pasan, commit + tag (`v1`) →
solo entonces se escribe la spec de la siguiente versión.

## 3. Las reglas de juego del curso

1. **La spec manda sobre el código.** Si el código hace algo que la spec no
   dice, sobra; si la spec pide algo que el código no hace, falta.
2. **No se anticipa** (YAGNI): la v1 no construye nada de la v3 "por si
   acaso". Cada versión introduce SU contenido cuando le toca.
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
