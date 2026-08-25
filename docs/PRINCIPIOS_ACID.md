# Principios ACID — por qué una facturación los exige

> Documento conceptual del curso. La BD del proyecto (`bdfacturas`, en SQL
> Server) es un sistema de facturación — el ejemplo clásico de por qué las
> bases de datos relacionales ofrecen garantías ACID.

---

## 1. ¿Qué es una transacción?

Una **transacción** es un grupo de operaciones que la BD trata como UNA
sola unidad: o pasan TODAS, o no pasa NINGUNA. El ejemplo de este proyecto:
registrar una factura implica insertar la factura, insertar sus renglones y
descontar stock — tres operaciones que deben comportarse como una.

## 2. Las 4 garantías, con el ejemplo del proyecto

### A — Atomicidad
> Todo o nada.

Si al registrar una factura de 3 renglones el tercero falla porque no hay
stock, **todo** se revierte: no puede quedar una factura sin renglones ni
stock descontado sin factura. El dinero no acepta "casi".

### C — Consistencia
> La BD pasa de un estado válido a otro estado válido: las reglas
> declaradas (PK, FK, triggers) se cumplen SIEMPRE.

**Ejemplo desde la v1:** las **llaves foráneas** de bdfacturas — `cliente`
apunta a `persona`, `factura` apunta a `cliente`. Aunque la API validara
mal, el motor rechaza eliminar una persona que es cliente. Es la doble
muralla: las peticiones del verbo cuidan la forma de lo que entra; las FK
cuidan las relaciones entre tablas.

### I — Aislamiento (*Isolation*)
> Transacciones simultáneas no se pisan: cada una ve un estado coherente.

Dos cajeros facturando el MISMO producto al tiempo no pueden descontar el
mismo stock dos veces. SQL Server aísla las transacciones (con niveles
configurables) para que el resultado sea como si hubieran pasado una
después de la otra.

### D — Durabilidad
> Lo confirmado, confirmado está: sobrevive a un corte de luz.

Cuando la BD dice "factura registrada", esa factura está en disco (en el
log de transacciones) — no en memoria esperando a que algo la guarde.

## 3. Dónde vive esto en el proyecto

- Los **triggers** de `productosporfactura` (ver `db/bdfacturas.sql`)
  mantienen `factura.total` y `producto.stock` — y corren DENTRO de la
  transacción del INSERT/UPDATE/DELETE que los disparó: si algo falla,
  todo se revierte junto (atomicidad + consistencia).
- Las **FK** entre las 12 tablas hacen cumplir las relaciones (consistencia)
  — las usará a fondo la v2.
- La v1 solo toca `producto`, pero ya se apoya en ACID: la PK de `codigo`
  es la que convierte un código duplicado en error del motor (el 500 del
  contrato).

## 4. El contraste: BASE (para saber que existe)

Algunos sistemas NoSQL relajan ACID a cambio de escala: BASE (*Basically
Available, Soft state, Eventually consistent*) — "eventualmente
consistente". Sirve para un feed de red social; NO sirve para facturación:
nadie acepta que su pago sea "eventualmente" registrado. Por eso este
curso usa un motor relacional.

## 5. Ejercicio (véalo usted mismo)

Conéctese a la BD (SQLTools a `localhost,11467`, usuario `sa`) y pruebe:

```sql
BEGIN TRANSACTION;
UPDATE producto SET stock = 0 WHERE codigo = 'PR001';
SELECT stock FROM producto WHERE codigo = 'PR001';   -- 0 (dentro de la transacción)
ROLLBACK;
SELECT stock FROM producto WHERE codigo = 'PR001';   -- 17 otra vez: atomicidad

DELETE FROM persona WHERE codigo = 'P001';
-- ERROR: viola la llave foránea (P001 es cliente) → consistencia:
-- el motor no acepta estados inválidos, aunque nadie lo valide antes
```

## 6. Referencias

1. Härder, T. & Reuter, A. — *Principles of Transaction-Oriented Database
   Recovery* (ACM Computing Surveys, 1983): el artículo que acuñó "ACID".
2. Microsoft — Transacciones en SQL Server:
   <https://learn.microsoft.com/sql/t-sql/language-elements/transactions-transact-sql>
3. Kleppmann, M. — *Designing Data-Intensive Applications* (O'Reilly,
   2017), cap. 7: la mejor discusión moderna de ACID.
4. En este repositorio: las tablas, FK y triggers de bdfacturas en el
   [modelo de datos de la v1](spec_kit/versiones/v1_producto_sqlserver/5_data_model.md).
