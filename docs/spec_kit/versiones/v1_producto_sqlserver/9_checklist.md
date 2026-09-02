# Lista de chequeo de requisitos — Versión 1

> **La compuerta 3** del método (ver [SDD_SPECKIT §2.2](../../../SDD_SPECKIT.md)).
> Esta lista revisa **la ESPECIFICACIÓN, no el código**: se corre cuando los
> documentos 2 a 8 están escritos y ANTES de programar la primera línea.
> Es el equivalente a mano de `checklists/requirements.md`, que en Spec Kit
> genera `/speckit.checklist`.

## Cómo se usa

- **Las casillas las marca una persona.** Una IA puede ayudar a evaluar y a
  señalar dudas, pero **no puede auto-aprobarse**: quien firma es quien
  responde por la versión.
- Se marca `[x]` solo cuando el criterio se cumple **hoy, en el documento**
  — no "cuando lo arregle".
- **Con una sola casilla en rojo no se escribe código.** Se vuelve al
  documento que la causó, se corrige, y se pasa la lista otra vez.
- Trabaja bien en pareja: un estudiante revisa la spec del otro. Las
  ambigüedades que uno no ve, el otro las tropieza de una.

---

## A. Claridad — ¿dice UNA sola cosa?

- [ ] Ningún requisito usa palabras sin definir: *rápido, amigable,
      eficiente, correcto, adecuado, robusto*.
- [ ] No queda ningún marcador `[NECESITA ACLARACIÓN: …]` sin resolver en
      la sección de Clarificaciones de `2_spec.md`.
- [ ] Cada RF explica UNA cosa. Si uno necesita un "y" para entenderse, se
      partió en dos.
- [ ] Los RF no mencionan tecnología (ni Dapper, ni SqlClient, ni nombres
      de clase). El QUÉ está separado del CÓMO.

## B. Medible — ¿se puede verificar?

- [ ] Cada uno de los 6 criterios de aceptación dice un **valor concreto**:
      un número de filas, un código HTTP o un texto exacto.
- [ ] Cada criterio se puede comprobar con **un comando** del
      `7_quickstart.md`. Si no hay comando posible, no es criterio.
- [ ] Los códigos de error están dichos por su número (404, 422, 500), no
      como "responde con un error".
- [ ] El contraste didáctico del curso está escrito como criterio: mismo
      body → `PUT` 422 y `PATCH` 200.

## C. Completitud — ¿falta algo?

- [ ] Los 7 RF cubren los 5 verbos más el diagnóstico: nada de lo que
      promete el propósito quedó sin requisito.
- [ ] `2_spec.md` tiene su **NO incluye** explícito.
- [ ] Cada endpoint de `6_contracts.md` documenta sus desenlaces de
      **ERROR**, no solo el camino feliz.
- [ ] `5_data_model.md` trae las **semillas exactas** (los 8 productos con
      sus valores) de las que dependen los comandos del smoke test.
- [ ] Cada decisión de `4_research.md` tiene al menos una alternativa
      descartada con su razón.

## D. Coherencia — ¿los documentos dicen lo mismo?

- [ ] Todo RF de `2_spec.md` tiene su endpoint en `6_contracts.md`.
- [ ] Todo endpoint de `6_contracts.md` tiene una tarea que lo construye en
      `8_tasks.md`.
- [ ] Todo criterio de aceptación tiene su comando en `7_quickstart.md`,
      **con el mismo número**.
- [ ] Los ejemplos de `6_contracts.md` usan datos que existen en las
      semillas de `5_data_model.md` (PR001 existe; PR999 no).
- [ ] `3_plan.md` no nombra ningún archivo que ninguna tarea construya, y
      ninguna tarea construye un archivo que el plan no liste.
- [ ] El **chequeo de constitución** de `3_plan.md` está completo: artículo
      por artículo, sin saltarse ninguno.

## E. Alcance — ¿no se está anticipando?

- [ ] Ningún documento nombra tablas fuera de `producto` (Artículo 5 de la
      constitución).
- [ ] Ningún documento introduce la fábrica de repositorios, un segundo
      motor ni el front: eso llega en versiones futuras (YAGNI, Artículo 1).
- [ ] Los paquetes que nombra `3_plan.md` son exactamente los que permite
      el Artículo 2 de la constitución.

---

## Resultado

| | |
|---|---|
| **Revisada por** | *(nombre de quien firma)* |
| **Fecha** | |
| **Casillas en rojo** | |
| **Veredicto** | ⬜ En verde: puede empezar el código · ⬜ En rojo: vuelve a la spec |

> Si el veredicto es rojo, anote aquí qué documento hay que corregir y
> por qué. Esa nota es la que evita repetir el mismo error en la versión
> siguiente.
