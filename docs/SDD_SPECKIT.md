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

| # | Documento | Pregunta que responde |
|---|---|---|
| 1 | `1_constitution.md` | ¿Qué reglas NUNCA se negocian? (permanente, para todas las versiones) |
| 2 | `2_spec.md` | ¿QUÉ se construye en esta versión y cómo se sabe que quedó bien? |
| 3 | `3_plan.md` | ¿CÓMO: stack, estructura, diseño de capas? |
| 4 | `4_research.md` | ¿POR QUÉ así y no de otra forma? (alternativas descartadas) |
| 5 | `5_data_model.md` | ¿Qué datos hay y qué puede tocar esta versión? |
| 6 | `6_contracts.md` | ¿Cuáles son los endpoints EXACTOS (verbos, códigos, formatos)? |
| 7 | `7_quickstart.md` | ¿Cómo se arranca y se valida rápido? |
| 8 | `8_tasks.md` | ¿En qué ORDEN se construye, por fases verificables? |

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
