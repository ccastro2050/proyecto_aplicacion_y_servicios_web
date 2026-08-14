# postman — la colección de la API, lista para importar

Esta API ya trae documentación interactiva propia: **Swagger en
http://localhost:8032/swagger** (ASP.NET Core la genera con Swashbuckle).
Esta colección es el **camino alternativo**: los mismos endpoints como un
recorrido guiado y numerado, útil para quien prefiere Postman/Thunder
Client, para presentar la API sin abrir el código, y para comparar con los
proyectos gemelos del curso (Python y PHP tienen la misma colección).

## Cómo usarla (3 pasos)

1. Instale **Postman** (postman.com/downloads). Si le pide cuenta, puede
   usar la opción de cliente ligero sin registrarse.
2. **Import** (botón arriba a la izquierda) → arrastre el archivo
   `coleccion_v1.postman_collection.json` de esta carpeta.
3. Con el proyecto corriendo (`docker compose up -d`), abra cualquier
   petición y dele **Send**.

## El orden cuenta una historia

Las 13 peticiones están numeradas para recorrerlas de arriba a abajo:
diagnóstico → lecturas (con query string y parámetro de ruta) → el ciclo
de escritura (POST/PUT/PATCH/DELETE) → **la pareja didáctica** (9 y 10: el
mismo body da 422 en PUT y 200 en PATCH) → los errores (404, el 422 con
`errores[]`, el 500 del código duplicado). Cada petición trae su
explicación en la pestaña de descripción.

## La variable {{base}}

La colección usa la variable `base` = `http://localhost:8032` (el proyecto
del curso). Si está probando **SU reconstrucción** (la de la
[GUIA_IA](../docs/GUIA_IA.md), que corre en el puerto 8132): clic en la
colección → pestaña **Variables** → cambie `base` a
`http://localhost:8132`. Una sola edición y las 13 peticiones apuntan a su
proyecto.
