# Proyecto Aplicación y Servicios Web — construcción por versiones

Proyecto de curso (ITM). Aquí NO se descarga un sistema terminado:
**se construye un sistema real por versiones en C# / ASP.NET Core**, guiado
por especificaciones. El repositorio siempre contiene la **versión en
curso, funcionando** — usted la ejecuta, la estudia y luego la
**reconstruye desde cero** en su propio proyecto.

---

## 1. Cómo le trabaja el estudiante (léame primero)

### Qué necesita instalado (una sola vez)

| Herramienta | Para qué |
|---|---|
| **Git** | Clonar el repositorio y traer versiones nuevas |
| **Docker Desktop** | La BD y la API corren en contenedores (no se instala SQL Server ni .NET) |
| **VS Code** | El editor — y su terminal integrada (*Terminal → New Terminal*) |

> El SDK de .NET local es **opcional** (solo para desarrollar fase a fase
> sin Docker): .NET 10.

### Primera vez: cargar y EJECUTAR la versión (un solo comando)

En la terminal integrada de VS Code (*Terminal → New Terminal*, PowerShell):

> ⚠️ **ANTES de clonar — solo si usted ya corrió OTRO proyecto de estos
> cursos en este PC:** puede quedar un contenedor viejo encendido ocupando
> el puerto 8036 (pasa al reiniciar el PC: la API vieja revive sin su
> base de datos y "secuestra" el puerto — el contenedor huérfano). El
> síntoma: Swagger abre, pero todo responde 500 con *"No address
> associated with hostname"*, y usted cree que el error es de ESTE
> proyecto cuando en realidad está hablando con el viejo. Verifíquelo y
> apáguelo primero:
>
> ```powershell
> docker ps --filter "name=proyecto_"
> # ↑ VERIFICAR: ¿aparece algún proyecto del curso todavía encendido?
> docker ps --filter "name=proyecto_" -q | ForEach-Object { docker stop $_ }
> # ↑ LIMPIAR: apaga TODOS los contenedores del curso de una sola vez
> ```
>
> La limpieza no borra nada (los datos quedan en sus volúmenes) y
> funciona aunque ya no tenga la carpeta vieja. También sirve el botón
> Stop de Docker Desktop. Solo entonces continúe.

```powershell
git clone https://github.com/ccastro2050/proyecto_aplicacion_y_servicios_web.git
cd proyecto_aplicacion_y_servicios_web
docker compose up -d --build
```

**Eso es todo.** La primera vez tarda varios minutos (descarga imágenes,
el inicializador crea la BD, y la primera compilación de la API toma
~1 minuto más). Al terminar quedan corriendo la base de datos (bdfacturas
completa en SQL Server) y la API:

| Qué | Dónde |
|---|---|
| **API Facturas** — diagnóstico | http://localhost:8036/ |
| **Swagger** (documentación interactiva: ver y probar los endpoints) | http://localhost:8036/swagger |
| Listar productos | http://localhost:8036/api/producto |
| SQL Server (para SQLTools/SSMS, opcional) | `localhost,11467` · `sa`/`Paradigmas123!` |

Pruebe la joya didáctica de la v1: PUT con solo `{"stock": 99}` → 422; el
mismo body en PATCH → 200. Esa diferencia es parte de lo que enseña la
versión (contratos exactos en el spec kit).

> ℹ️ Este proyecto usa los puertos 8036 y 11467: si alguno ya está ocupado
> en su máquina, cámbielo en `docker-compose.yml` (el lado izquierdo del
> `"puerto:puerto"`).
>
> ⚠️ SQL Server necesita ~2 GB de RAM libres en Docker Desktop.

### Los días siguientes (volver a encender)

```powershell
docker compose up -d        # segundos; los datos se conservan
```

### Cuando hay cambios

| Qué cambió | Qué hacer |
|---|---|
| **Usted edita un `.cs`** | **Nada** — el código está montado como volumen y `dotnet watch` recompila y reinicia solo (espere unos segundos) |
| **El profesor publicó una versión nueva** | `git pull` y `docker compose up -d --build` |
| **Cambió el `Dockerfile` o el `.csproj`** | `docker compose up -d --build` (reconstruye la imagen) |
| **Quiere resetear la BD** a sus datos originales | `docker compose down -v` y luego `docker compose up -d` (⚠️ borra los datos) |
| **Apagar todo** | `docker compose down` (los datos se conservan) |

### Y ahora, SU trabajo: reconstruirla desde cero

Ejecutar la versión del repo es solo el punto de partida. Lo que se evalúa
es **reconstruirla usted mismo, en una carpeta propia (fuera del clon)**,
siguiendo las especificaciones — con o sin ayuda de IA:

> 🤖 ¿Va a trabajar con IA? Siga la **[Guía para construir la versión con
> IA](docs/GUIA_IA.md)** — cubre los dos caminos con su prompt exacto listo
> para copiar: **chat web** (Gemini, DeepSeek, ChatGPT: qué archivos
> subirle) e **IDE agéntico** (Antigravity, Cursor, Claude Code: cómo
> supervisar al agente).

### Conceptos resumidos (los que acaba de usar)

| Concepto | En una frase |
|---|---|
| **Clonar** | Descargar el repositorio con su historial; `git pull` trae lo nuevo |
| **Contenedor** | BD y API corren en "cajas" de Docker: nada que instalar, se borran y recrean sin miedo |
| **docker compose** | UN archivo declara todo el sistema y UN comando lo levanta (`up -d`) |
| **Volumen** | Donde viven los datos: `down` los conserva, `down -v` los borra (reset) |
| **dotnet watch** | El vigilante del código: guardar un `.cs` recompila y reinicia la API sola |
| **Spec kit** | Los documentos que dicen QUÉ/CÓMO/EN QUÉ ORDEN — la fuente de verdad |
| **Versión / tag** | Un incremento cerrado y verificado (`v1`, `v2`, …): se avanza solo en verde |

> Detalle de los conceptos Docker: [docs/CONCEPTOS_DOCKER.md](docs/CONCEPTOS_DOCKER.md).

---

## 2. Estructura del repositorio

Qué es cada carpeta y cada archivo, y para qué sirve:

```
proyecto_aplicacion_y_servicios_web/
├── docker-compose.yml           # TODO el sistema declarado: SQL Server + inicializador
│                                #   + API (el "un solo comando" del proyecto)
├── db/
│   ├── bdfacturas.sql           # Crea bdfacturas COMPLETA (12 tablas, triggers, SPs,
│   │                            #   datos) — dialecto SQL Server
│   └── init.sh                  # El inicializador: SQL Server no auto-ejecuta scripts;
│                                #   este contenedor los corre UNA vez y termina
│
├── backupdb/                    # Respaldos (.bak) de la BD — su README explica
│                                #   cómo hacer el backup y cómo restaurarlo
│
├── postman/                     # La colección de Postman lista para importar:
│                                #   los 13 endpoints en orden didáctico (alternativa a Swagger)
│
├── api_facturas/                # LA API DE LA v1 — C#/ASP.NET Core (puerto 8036)
│   ├── ApiFacturas.csproj       # El proyecto .NET (paquetes: SqlClient, Dapper y Swashbuckle)
│   ├── Program.cs               # Punto de entrada: ENSAMBLADOR (DI) + 422 + rutas
│   ├── appsettings.json         # Cadena de conexión (default localhost,11467)
│   ├── Dockerfile               # Imagen sdk:10.0 + dotnet watch
│   ├── Controllers/             # Capa 1 — HTTP: atributos de verbo y try/catch → códigos
│   ├── Modelos/                 # Los MODELOS = las clases ENTIDAD (v1: Producto)
│   ├── Peticiones/              # Los body por verbo (Crear/Reemplazo/Actualizar):
│   │                            #   sus anotaciones validan la entrada → 422
│   ├── Servicios/               # Capa 2 — negocio: interfaz + reglas
│   ├── Repositorios/            # Capa 3 — datos: interfaz + ADO.NET/SQL Server
│   ├── Excepciones/             # NoEncontradoExcepcion (el servicio la lanza → 404)
│   └── pruebas/                 # Proyecto de consola: el servicio con repositorio
│                                #   FALSO en memoria (criterio 6, corre sin BD)
├── docs/
│   ├── spec_kit/                # LAS ESPECIFICACIONES: constitución permanente +
│   │                            #   una carpeta de specs por versión (v1, v2, …)
│   ├── GUIA_IA.md               # Cómo reconstruir la versión desde 0 con ayuda de una IA
│   ├── FLUJO_DE_UNA_PETICION.md # Dónde "está" el GET, dónde se captura el POST
│   ├── TUTORIAL_SSMS.md         # Administrar la BD con SQL Server Management Studio
│   ├── TUTORIAL_VSCODE_SQLTOOLS.md # Administrar la BD desde VS Code (SQLTools)
│   ├── PARADIGMA_POO.md         # Material conceptual: POO, SOLID+capas, ACID,
│   ├── SOLID_CAPAS_PATRONES.md         #   Docker y SDD (un .md por tema)
│   ├── PRINCIPIOS_ACID.md       #
│   ├── CONCEPTOS_DOCKER.md      #
│   └── SDD_SPECKIT.md           #
│
├── .gitignore / .gitattributes  # Higiene del repo (bin/, obj/, .session.sql; .sh con LF)
└── README.md                    # Este archivo
```

La regla de lectura: **el sistema vive en `docker-compose.yml`**, la API
vive en `api_facturas/` (una carpeta por capa), y **todo lo que explica**
vive en `docs/`. Cuando lleguen las versiones siguientes, aquí aparecerán
más carpetas de componentes (y el compose crecerá con ellas).

## 3. La ruta de versiones

```
v1  api_facturas (C#/ASP.NET Core): CRUD de producto, solo SQL Server   ← USTED ESTÁ AQUÍ
v2  más tablas (persona, factura maestro-detalle…)
v3  segundo motor (PostgreSQL) — nace la fábrica de repositorios
v4  tercer motor (MariaDB) + compose completo
v5  frontend BLAZOR: CRUD de las 12 entidades + login + facturación
```

La regla del juego: la **constitución** es permanente, cada versión tiene
su propia spec, y una versión está TERMINADA solo cuando pasa sus criterios
de aceptación (commit + tag). Mapa completo:
[docs/spec_kit/versiones/0_mapa_versiones.md](docs/spec_kit/versiones/0_mapa_versiones.md).

## 4. Las especificaciones de la versión actual (v1)

| Documento | Contenido |
|---|---|
| [1_constitution.md](docs/spec_kit/1_constitution.md) | Las reglas permanentes del proyecto |
| [2_spec.md](docs/spec_kit/versiones/v1_producto_sqlserver/2_spec.md) | QUÉ construir y los criterios de aceptación |
| [3_plan.md](docs/spec_kit/versiones/v1_producto_sqlserver/3_plan.md) | CÓMO: stack, estructura y diseño de las capas |
| [4_research.md](docs/spec_kit/versiones/v1_producto_sqlserver/4_research.md) | Decisiones y alternativas (el porqué) |
| [5_data_model.md](docs/spec_kit/versiones/v1_producto_sqlserver/5_data_model.md) | La BD completa (dada) y la tabla producto |
| [6_contracts.md](docs/spec_kit/versiones/v1_producto_sqlserver/6_contracts.md) | Los 7 endpoints con formatos exactos |
| [7_quickstart.md](docs/spec_kit/versiones/v1_producto_sqlserver/7_quickstart.md) | Arranque y smoke test |
| [8_tasks.md](docs/spec_kit/versiones/v1_producto_sqlserver/8_tasks.md) | Orden de construcción por fases verificables |

## 5. Material conceptual del curso

| Documento | Qué cubre |
|---|---|
| [El flujo de una petición](docs/FLUJO_DE_UNA_PETICION.md) | **Léalo primero:** dónde está el GET, dónde se captura el POST, y el viaje completo por las capas |
| [Colección de Postman](postman/README.md) | Los 13 endpoints de la v1 listos para importar y probar con clics — incluida la pareja PUT=422 vs PATCH=200 |
| [SDD y Spec Kit](docs/SDD_SPECKIT.md) | La metodología con la que se trabaja este curso: la spec manda sobre el código |
| [El paradigma P.O.O. en C#](docs/PARADIGMA_POO.md) | Qué es un paradigma, los 4 pilares, y las propiedades e interfaces de C# |
| [SOLID, capas y patrones de diseño](docs/SOLID_CAPAS_PATRONES.md) | Los 5 principios y las capas — y en qué versión se demuestra cada uno |
| [Principios ACID](docs/PRINCIPIOS_ACID.md) | Las 4 garantías transaccionales, por qué una facturación las exige |
| [Conceptos de Docker](docs/CONCEPTOS_DOCKER.md) | Imagen, contenedor, volumen, compose (con el del proyecto explicado línea por línea) y por qué NO se necesita Kubernetes |

---

*Proyecto Aplicación y Servicios Web · ITM · Base de datos bdfacturas
(facturación + RBAC).*
