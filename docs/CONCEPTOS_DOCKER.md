# Conceptos de Docker — imagen, contenedor, volumen, compose y Kubernetes

> Documento conceptual del curso. En la v1 usted ya usó Docker (el
> `docker compose up -d --build` que levanta la BD y la API); aquí está el
> mapa completo de conceptos, con los ejemplos de este proyecto.

---

## 1. ¿Qué problema resuelve Docker?

"En mi máquina sí funciona." Cada estudiante tiene un PC distinto (Windows,
versiones, configuraciones) y un software como SQL Server instalado a mano
se comporta distinto en cada uno. Docker empaqueta el software **con todo
su entorno** en una unidad estándar que corre igual en cualquier máquina.
En este curso: nadie instala SQL Server ni .NET — todos corren **los mismos
contenedores**.

## 2. Imagen

Una imagen es una **plantilla inmutable y empaquetada**: un sistema de
archivos congelado (SO base + programa + librerías + configuración) más
metadatos (qué comando arrancar, qué puerto expone).

- **Inmutable**: una vez construida, no cambia. Cambiar algo = construir
  OTRA imagen.
- Se construye en **capas** (cada instrucción de un `Dockerfile` es una
  capa que se cachea — por eso las reconstrucciones son rápidas).
- Viene de un **registro** o se construye localmente. Este proyecto usa de
  ambas: `mcr.microsoft.com/mssql/server:2022-latest` viene del registro de
  Microsoft; la de la API **se construye** con el `Dockerfile` de
  `api_facturas/` (base: `dotnet/sdk:10.0`).

**Analogía:** la imagen es el **molde de la galleta**.

### 2.1 El `Dockerfile`: la receta de la imagen

Una imagen no aparece sola: **alguien escribe cómo se arma**. Ese «cómo»
va en un archivo llamado `Dockerfile` (sin extensión), y este proyecto
tiene uno: `./api_facturas`.

Este es el de `api-facturas`, sin los comentarios para verlo de un vistazo:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0
WORKDIR /app
ENV DOTNET_USE_POLLING_FILE_WATCHER=1 ASPNETCORE_URLS=http://0.0.0.0:8036
EXPOSE 8036
CMD ["dotnet", "watch", "run", "--non-interactive", "--project", "ApiFacturas.csproj"]
```

Esto hace cada instrucción:

| Instrucción | Qué hace | Por qué está aquí |
|---|---|---|
| `FROM mcr.microsoft.com/dotnet/sdk:10.0` | **De dónde se parte.** Toma una imagen ya hecha | Nadie arma un sistema desde cero: se parte de una que ya trae lo básico |
| `WORKDIR /app` | La carpeta donde se trabaja dentro del contenedor | Para no repetir la ruta completa en cada instrucción siguiente |
| `ENV DOTNET_USE_POLLING_FILE_WATCHER=1 ASPNE…` | Define **variables de entorno** que quedan en la imagen | El programa las lee al arrancar |
| `EXPOSE 8036` | **Documenta** en qué puerto escucha el programa | No abre nada: quien publica el puerto es el `ports:` del compose |
| `CMD ["dotnet", "watch", "run", "--non-inter…` | **El comando que se ejecuta al encender** el contenedor | Si ese proceso termina, el contenedor se apaga |

**La diferencia entre `RUN` y `CMD`** es la que más se confunde:

| | Cuándo corre | Cuántas veces |
|---|---|---|
| `RUN` | Al **construir** la imagen (`--build`) | Una sola vez, y queda guardado |
| `CMD` | Al **encender** el contenedor | Cada vez que arranca |


### 2.2 ¿Por qué DOS archivos y no uno?

Es la pregunta que sigue, y la respuesta es que **responden preguntas
distintas**:

| | `Dockerfile` | `docker-compose.yml` |
|---|---|---|
| **Qué responde** | ¿Cómo se **arma** esta pieza? | ¿Cómo se **combinan** las piezas? |
| **De qué habla** | De **un** programa | Del **sistema completo** |
| **Cuántos hay** | Uno por cada imagen propia | **Uno solo** por proyecto |
| **Qué contiene** | Instalar, copiar, con qué comando arranca | Servicios, puertos, variables, volúmenes, orden |
| **Se usa con** | `docker build` | `docker compose up` |

**Es decir:** el `Dockerfile` describe **cómo se construye un artefacto**
—una imagen—, y el `docker-compose.yml` describe **cómo se despliega un
sistema** compuesto por varios de esos artefactos.

Son dos responsabilidades distintas y es deliberado que estén separadas:

| Responsabilidad | Archivo | Pregunta que resuelve |
|---|---|---|
| **Empaquetado** | `Dockerfile` | ¿Qué necesita este programa para ejecutarse en cualquier parte? |
| **Orquestación** | `docker-compose.yml` | ¿Cómo se conectan y en qué orden arrancan los programas de este sistema? |

Separarlas es lo que permite que **la misma imagen se use en otro sistema
sin arrastrar la configuración de este**: los puertos, las claves y las
dependencias entre servicios no están dentro de la imagen, sino afuera, en
el archivo que describe el montaje.

### Y por eso no todos los servicios tienen `Dockerfile`

En este proyecto:

| Servicio | ¿Tiene `Dockerfile`? | Por qué |
|---|---|---|
| `api-facturas` | **Sí**, en `./api_facturas` | Es código **suyo**: nadie más lo tiene, hay que armarlo |
| `sqlserver` | **No** | Usa `mcr.microsoft.com/mssql/server:2022-latest`, una imagen ya hecha: no hay nada que construir |
| `sqlserver-init` | **No** | Usa `mcr.microsoft.com/mssql/server:2022-latest`, una imagen ya hecha: no hay nada que construir |

**Un `Dockerfile` por imagen propia; un compose por sistema.** Si mañana
este proyecto sumara otro servicio propio, tendría su propio `Dockerfile`
y una entrada más en el mismo compose.

### Cuál se toca cuando algo cambia

| Lo que cambia | Se toca |
|---|---|
| Una librería o dependencia del programa | El `Dockerfile` (y toca `--build`) |
| La versión del lenguaje | El `Dockerfile` |
| Un puerto, una clave, una dirección | El `docker-compose.yml` |
| Agregar un servicio nuevo | El `docker-compose.yml` (y su `Dockerfile`, si es propio) |
| El orden en que arrancan | El `docker-compose.yml` |

> **Y hay una razón de fondo:** el `Dockerfile` es **portátil** — esa imagen
> sirve en este proyecto, en otro, o en un servidor de producción, sin
> cambiarle una línea. El compose, en cambio, describe **este** sistema:
> estos puertos, estas claves, esta red. Mezclarlos en un solo archivo
> amarraría la pieza reutilizable al montaje de un día.


## 3. Contenedor

Un contenedor es una **instancia viva de una imagen**: un proceso corriendo
con su propio sistema de archivos, red y espacio de procesos, aislado del
resto de su PC.

- De una imagen salen **muchos contenedores** (galletas del mismo molde).
  En este proyecto pasa de verdad: `sqlserver` y `sqlserver-init` son DOS
  contenedores de la MISMA imagen — uno es el motor, el otro solo ejecuta
  el script de la BD y termina.
- Es **efímero y desechable**: `docker compose down` los destruye sin
  drama, y `up -d` los recrea idénticos.
- **No es una máquina virtual**: comparte el kernel del host con
  aislamiento de procesos. Por eso arranca en segundos (la excepción de
  peso es SQL Server, que necesita ~2 GB de RAM por ser SQL Server, no por
  ser contenedor).

**Analogía:** el contenedor es la **galleta**.

## 4. Volumen (y el estado)

Si los contenedores son desechables… ¿dónde viven los datos? En
**almacenamiento que sobrevive al contenedor**:

| Mecanismo | Qué es | En este proyecto |
|---|---|---|
| **Volumen nombrado** | Espacio administrado por Docker, montado dentro del contenedor | `mssqldata` — los datos de SQL Server (por eso `down`/`up` los conserva) |
| **Bind mount** | Una carpeta de SU disco montada dentro del contenedor | `./api_facturas:/app` (el código entra al contenedor y `dotnet watch` lo vigila) · `./db:/scripts:ro` (los scripts del init, solo lectura) |
| **Volumen anónimo** | Un hueco sin nombre que "tapa" una subcarpeta del bind mount | `/app/bin` y `/app/obj` — los compilados de Linux quedan DENTRO del contenedor, sin mezclarse con los de Windows |

**La regla de oro que ata los tres conceptos:** *la imagen es inmutable, el
contenedor es desechable, y el volumen es lo único que debe importarte
perder.*

```
Dockerfile   →  IMAGEN      →  CONTENEDOR   →  VOLUMEN
(receta)        (molde)        (galleta)       (la memoria)
             docker build    docker run       -v / volumes
```

> **La sorpresa que confunde a todo el mundo:** el volumen sobrevive
> INCLUSO a borrar la carpeta del proyecto. Si usted borra la carpeta,
> vuelve a hacer `git clone` y ejecuta `docker compose up -d --build`,
> la BD arranca **con los datos de la última vez** — no con las semillas.
> ¿Por qué? El volumen no vive en la carpeta: vive en el área de Docker,
> identificado por el nombre del proyecto compose (= el nombre de la
> carpeta). Misma carpeta → mismo nombre → mismo volumen de siempre.
>
> | Comando | ¿Y los datos? |
> |---|---|
> | `docker compose up -d --build` | Se conservan |
> | `docker compose down` | Se conservan |
> | borrar la carpeta y re-clonar | **Se conservan** (el volumen no estaba ahí) |
> | `docker compose down -v` | **SE BORRAN** — el único que resetea |
>
> Para una demo con las semillas exactas:
> `docker compose down -v` y luego `docker compose up -d --build`.

### El despliegue de ESTE proyecto, dibujado (Mermaid)

Todo lo anterior, junto: lo que `docker compose up -d` levanta aquí es un
**sistema de servidores en miniatura** — cada contenedor es un servidor
con su propio hostname, unidos por la red interna del compose:

```mermaid
flowchart LR
    NAV["Navegador / curl / Swagger"]
    subgraph PC["Su PC — Docker Desktop (el 'centro de datos')"]
        subgraph RED["red interna del compose (LAN virtual, con DNS propio)"]
            APIFACTURAS["SERVIDOR DE APLICACIONES<br/>contenedor api-facturas<br/>hostname: api-facturas · escucha en 8036"]
            SQLSERVER[("SERVIDOR DE BASE DE DATOS<br/>SQL Server · contenedor sqlserver<br/>hostname: sqlserver · escucha en 1433")]
            SQLSERVERINIT["sqlserver-init<br/>siembra la BD UNA vez<br/>y muere: Exited(0) = éxito"]
        end
    end
    NAV -->|"localhost:8036"| APIFACTURAS
    APIFACTURAS -->|"sqlserver:1433 (DNS de Docker)"| SQLSERVER
    SQLSERVERINIT -->|"espera el healthcheck,<br/>siembra y termina"| SQLSERVER
    NAV -.->|"opcional (diagnóstico):<br/>localhost:11467"| SQLSERVER
```

**Guía de lectura:** los servicios se hablan entre sí **por nombre**
(el DNS interno de Docker resuelve `postgres`, `api-facturas`, etc. a la
IP del contenedor — jamás `localhost`, que dentro de un contenedor es él
mismo). Hacia su PC solo existen las puertas `localhost:PUERTO` que el
compose publica. Por eso este mismo diseño se despliega igual en un
servidor real: cambiar de máquina no cambia la arquitectura.

## 5. Docker Compose (el "un solo comando" del proyecto)

**Compose** es la respuesta **declarativa** a "¿cómo levanto varios
contenedores en orden, con sus puertos, volúmenes y dependencias?": un
archivo `docker-compose.yml` declara el estado deseado del sistema y
`docker compose up -d` lo materializa. Es **declarativo, no imperativo**:
usted no escribe los pasos, escribe el resultado (el mismo espíritu de SDD).

### El `docker-compose.yml` de ESTE proyecto, por piezas

**El motor (imagen del registro + volumen + healthcheck):**

```yaml
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: "Paradigmas123!"
    volumes:
      - mssqldata:/var/opt/mssql     # volumen nombrado: los datos sobreviven
    ports:
      - "11467:1433"                 # "puerto en su PC : puerto interno"
    healthcheck:                     # ¿la BD ya RESPONDE consultas?
      test: ["CMD-SHELL", "…sqlcmd… -Q 'SELECT 1'…"]
```

**El inicializador (la particularidad de SQL Server):**

```yaml
  sqlserver-init:
    image: mcr.microsoft.com/mssql/server:2022-latest   # la MISMA imagen
    depends_on:
      sqlserver:
        condition: service_healthy   # espera a que el motor RESPONDA
    volumes:
      - ./db:/scripts:ro             # init.sh + bdfacturas.sql, solo lectura
    entrypoint: ["/bin/bash", "/scripts/init.sh"]
    restart: "no"                    # corre UNA vez y termina
```

SQL Server no ejecuta automáticamente scripts montados (a diferencia de
otros motores): este contenedor se conecta, crea la BD si no existe, corre
el script y muere — un patrón de Docker que vale la pena conocer.

**La API (imagen construida + código montado + hot-reload):**

```yaml
  api-facturas:
    build: ./api_facturas            # se construye con SU Dockerfile
    volumes:
      - ./api_facturas:/app          # guardar un .cs → dotnet watch recompila
      - /app/bin                     # volúmenes anónimos: compilados de Linux
      - /app/obj                     #   sin mezclarse con los de Windows
    ports:
      - "8036:8036"
    environment:
      # El host es el NOMBRE del servicio (sqlserver), no localhost:
      ConnectionStrings__SqlServer: "Server=sqlserver,1433;…"
    depends_on:
      sqlserver-init:
        condition: service_completed_successfully
        # ↑ arranca cuando el init TERMINÓ BIEN: la BD ya existe
```

Las tres ideas que este archivo demuestra:

1. **Dos redes de nombres**: hacia su PC, puertos publicados
   (`localhost:8036`, `localhost,11467`); entre contenedores, nombres de
   servicio (`sqlserver,1433`). El mismo motor tiene dos "direcciones"
   según quién lo llame.
2. **Dependencias con condiciones**: `service_healthy` (el motor responde)
   y `service_completed_successfully` (el init terminó bien) — la API no
   arranca "por azar" sino cuando sus prerequisitos están listos.
3. **Desarrollo dentro del contenedor**: código montado + `dotnet watch` =
   guardar recompila, sin reconstruir la imagen. Solo se reconstruye
   (`--build`) cuando cambian el `.csproj` o el Dockerfile.

### Contenedores huérfanos y `--remove-orphans`

Compose recuerda qué contenedores creó para este proyecto (los marca con el
nombre de la carpeta). Si el `docker-compose.yml` **deja de declarar** un
servicio que antes existía, su contenedor queda **huérfano** y Compose lo
avisa al arrancar. No estorba (está detenido), pero ocupa disco. La
limpieza:

```powershell
docker compose up -d --remove-orphans   # levanta lo declarado Y borra los huérfanos
```

Importante: borra los **contenedores** sobrantes, no los **volúmenes** —
los datos de la BD siguen ahí (sección 4).

### Las directivas del `docker-compose.yml`, una por una

Estas son las palabras clave que usa el archivo de arriba, con lo que
significan y qué pasaría si faltaran:

| Directiva | Qué declara | Si no está |
|---|---|---|
| `services:` | La lista de contenedores del sistema. Cada nombre debajo es un servicio | No hay nada que levantar |
| `image:` | **Usa** una imagen ya hecha, del registro público | Habría que construirla con `build:` |
| `build:` | **Construye** la imagen con el `Dockerfile` de esa carpeta | Docker no sabría cómo armar su aplicación |
| `environment:` | Variables que el programa lee al arrancar (claves, direcciones) | El programa arranca sin saber a qué base conectarse |
| `volumes:` | Qué carpetas o volúmenes se montan dentro del contenedor | Los datos se pierden al apagar, y el código no se refresca |
| `ports:` | `"puerto en su PC : puerto dentro del contenedor"` | El servicio corre pero **usted no lo puede abrir** desde el navegador |
| `depends_on:` | En qué orden arrancan los servicios | Arrancan a la vez, y la API busca una base que todavía no existe |
| `healthcheck:` | Cómo saber si el servicio **ya responde**, no solo si «existe» | `depends_on` esperaría a que arranque, no a que sirva |
| `restart:` | Qué hacer si el proceso se muere | El contenedor se queda caído |
| `volumes:` (al final, sin indentar) | Declara los volúmenes **nombrados** que usan los servicios | El volumen no existe y el servicio no arranca |

**El nombre del servicio es también su dirección.** Cuando un servicio le
habla a otro, lo llama por el nombre que tiene en este archivo: Docker crea
una red interna y lo resuelve. Por eso no se usa `localhost` — **dentro de
un contenedor, `localhost` es el contenedor mismo**.

**Los dos números de `ports:` no son lo mismo.** El de la izquierda es el
puerto de su computador; el de la derecha, el de adentro. Cambiar el de la
izquierda no toca una línea de código.


### `docker compose up -d --build`: un comando que hace siete cosas

Esta es la parte que hace que valga la pena. **Un solo comando ejecuta toda
esta secuencia**, en este orden:

| # | Qué hace | El comando que se ahorra |
|---|---|---|
| 1 | **Lee** el `docker-compose.yml` y entiende el sistema completo | — |
| 2 | **Descarga** las imágenes que usted no tiene todavía (las de `image:`) | `docker pull imagen` por cada una |
| 3 | **Construye** las imágenes propias siguiendo su `Dockerfile` (las de `build:`) | `docker build -t nombre ./carpeta` por cada una |
| 4 | **Crea la red** interna para que los contenedores se encuentren por su nombre | `docker network create red` |
| 5 | **Crea los volúmenes** nombrados donde viven los datos | `docker volume create nombre` |
| 6 | **Crea y enciende un contenedor por servicio**, con sus puertos, variables y volúmenes | `docker run -d --name … -p … -e … -v … imagen` por cada uno |
| 7 | **Respeta el orden**: espera a que la base RESPONDA antes de encender la API | No tiene equivalente: habría que mirarlo a ojo |

Y todo eso **es repetible**: quien lo corra mañana en otro computador obtiene
exactamente lo mismo, porque la secuencia no está en la cabeza de nadie sino
escrita en dos archivos — el `docker-compose.yml` y los `Dockerfile`.

---

### Lo mismo, pero escrito a mano

**Sin compose**, para levantar este proyecto —que tiene **3 servicios**— hay
que escribir esto, en este orden, cada vez:

```powershell
# 1. Crear la red, para que los contenedores se encuentren por su nombre
docker network create proyecto_aplicacion_y_servicios_web_default

# 2. sqlserver
docker run -d --name sqlserver --network proyecto_aplicacion_y_servicios_web_default --restart unless-stopped `
  -e "ACCEPT_EULA=Y" `
  -e "MSSQL_SA_PASSWORD=Paradigmas123!" `
  -e "MSSQL_PID=Developer" `
  -v mssqldata:/var/opt/mssql `
  -p 11467:1433 mcr.microsoft.com/mssql/server:2022-latest

# 3. ESPERAR a que responda de verdad… mirándolo a ojo

# 4. sqlserver-init
docker run -d --name sqlserver-init --network proyecto_aplicacion_y_servicios_web_default --restart no --entrypoint /bin/bash `
  -e "MSSQL_SA_PASSWORD=Paradigmas123!" `
  -v "${PWD}/db:/scripts:ro" mcr.microsoft.com/mssql/server:2022-latest /scripts/init.sh

# 5. Construir la imagen de api-facturas y encenderla
docker build -t api-facturas ./api_facturas
docker run -d --name api-facturas --network proyecto_aplicacion_y_servicios_web_default --restart unless-stopped `
  -e "ConnectionStrings__SqlServer=Server=sqlserver,1433;Database=bdfacturas_sqlserver_local;User Id=sa;Password=Paradigmas123!;TrustServerCertificate=True;" `
  -v "${PWD}/api_facturas:/app" `
  -v /app/bin `
  -v /app/obj `
  -p 8036:8036 api-facturas

```

**5 comandos**, con sus flags, en un orden que no se puede equivocar.
Con compose, todo eso es:

```powershell
docker compose up -d --build
```

**De dónde sale cada pedazo:**

| Lo que antes era un flag | Ahora vive en |
|---|---|
| `docker build -t … ./carpeta` | `build:` del compose, y el **`Dockerfile`** de esa carpeta dice cómo |
| `-p 8080:8080` | `ports:` |
| `-e VARIABLE=valor` | `environment:` |
| `-v origen:destino` | `volumes:` |
| `--network …` | Compose la crea sola y mete a todos adentro |
| `--name` | El nombre del servicio |
| El orden y la espera | `depends_on:` + `healthcheck:` |

Y las dos banderas del comando:

| Bandera | Qué hace | Cuándo se usa |
|---|---|---|
| `-d` | Lo deja corriendo **en segundo plano** y le devuelve la terminal | Casi siempre. Sin ella la terminal queda pegada |
| `--build` | **Reconstruye** las imágenes propias antes de encender | La primera vez, y cada vez que cambie un `Dockerfile` |

> **Por eso el curso dice «un solo comando».** No es comodidad: es que el
> sistema entero queda **escrito** en dos archivos en vez de vivir en la
> memoria de quien lo levantó la primera vez. Cualquiera lo reproduce igual,
> y eso es lo que hace que su proyecto sea entregable.


## 6. Kubernetes (y por qué este curso NO lo necesita)

Kubernetes (K8s) es el orquestador de contenedores **a escala de clúster**:
reparte contenedores entre muchas máquinas, escala réplicas según demanda,
reprograma lo que se cae. Compose y K8s no compiten: Compose orquesta **en
una máquina**; K8s orquesta **un clúster**.

| Kubernetes resuelve… | ¿Existe ese problema aquí? |
|---|---|
| Repartir contenedores entre muchas máquinas | No — todo corre en su PC |
| Escalar a N réplicas cuando sube el tráfico | No — el "tráfico" es usted con curl |
| Alta disponibilidad (un nodo muere → reprogramar) | No — si su PC se apaga, se acabó la clase |
| Despliegue continuo sin caída | No — "actualizar" es guardar y que recompile |
| Secretos, RBAC, múltiples equipos | No — credenciales didácticas, un usuario |

**La regla profesional:** Compose para desarrollo local y sistemas de un
host; Kubernetes cuando se necesita más de una máquina. **El puente
conceptual:** ambos son YAML declarativo describiendo estado deseado —
quien domina un compose ya entiende la mitad conceptual de K8s.

## 7. Los comandos que este curso usa (chuleta)

```powershell
docker ps                        # qué está corriendo (con -a: también lo detenido)
docker stop X / docker start X   # apagar / encender (los datos se conservan)
docker logs X                    # ver la salida del contenedor (errores incluidos)
docker exec X comando            # ejecutar algo DENTRO del contenedor
# … y los de todos los días en este proyecto:
docker compose up -d --build     # materializar el docker-compose.yml (con rebuild)
docker compose ps -a             # estado de los servicios (el init debe estar Exited 0)
docker compose logs api-facturas # la salida de un servicio (errores incluidos)
docker compose down [-v]         # apagar todo (-v: borrar también los volúmenes = reset BD)
docker compose up -d --remove-orphans  # además, borrar contenedores huérfanos (sección 5)
```

### Cómo se leen los comandos que encuentre por ahí

Fíjese en la `X` de arriba: **no es parte del comando**. Está puesta donde va
un valor suyo — el nombre de su contenedor. Y el `[-v]` va entre corchetes
cuadrados porque es **opcional**.

Esa forma de escribir no es de este documento: es la de toda la
documentación técnica. En la página de Docker, en la de Git y en cualquier
respuesta de internet va a encontrar comandos así:

```
docker stop <nombre>
docker logs <contenedor>
git clone <url>
```

**Los signos `<` y `>` NO se escriben.** Son una marca que quiere decir
*«aquí va un valor suyo»*, y lo de adentro dice qué clase de valor.

**Ejemplo completo.** La documentación dice:

```
docker stop <nombre>
```

Usted primero averigua el nombre:

```powershell
docker ps
```

```
NAMES                              PORTS
proyecto_php1-api-facturas-1       0.0.0.0:8022->8022/tcp
proyecto_php1-mariadb-1            0.0.0.0:13326->3306/tcp
```

Y después escribe **el nombre tal como aparece**, sin los signos:

```powershell
docker stop proyecto_php1-api-facturas-1
```

Lo que **no** se escribe:

| Mal | Por qué |
|---|---|
| `docker stop <nombre>` | Dejó la marca en vez de reemplazarla |
| `docker stop <proyecto_php1-api-facturas-1>` | Puso el valor, pero dejó los signos |
| `docker stop "proyecto_php1-api-facturas-1"` | Las comillas sobran aquí |

**Las tres marcas que verá siempre:**

| Marca | Significa |
|---|---|
| `<algo>` | Obligatorio. Reemplácelo por su valor, sin los signos |
| `[algo]` | Opcional. Puede omitirlo entero |
| `a\|b` | Escoja uno de los dos |

**¿Y de dónde sale el valor?** Casi siempre de un comando que lista lo que
hay: para contenedores es `docker ps`, y el nombre está en la columna
`NAMES`.


## 8. ¿Hace falta una cuenta de Docker?

**No.** Las imágenes que usa este proyecto son **públicas**: se descargan sin
registrarse, sin iniciar sesión y sin pagar nada.

Al abrir Docker Desktop puede aparecer una ventana pidiendo *Sign in* o
*Create an account*. **Ciérrela, o escoja «Continue without signing in».**
Todo funciona igual.

### ¿Y si ya tiene cuenta y entra con ella?

**También funciona**, y hasta ayuda un poco: Docker Hub le da un límite de
descargas más alto a quien tiene la sesión abierta que a quien descarga de
forma anónima.

Dicho eso, **para este proyecto no hace falta**: ni para descargar las
imágenes, ni para levantarlas, ni para trabajar.

### Lo único que sí es obligatorio

**Que Docker Desktop esté encendido.** Ábralo y espere a que termine de
arrancar: el icono de la ballena, abajo a la derecha, deja de moverse.

Si Docker está apagado, cualquier comando responde algo así:

```
error during connect: ... the docker daemon is not running
```

Ese mensaje **no es un problema del proyecto**: es Docker que no está
corriendo. Enciéndalo y repita el comando.

---

## 9. Referencias

1. Docker — *Docker overview*: <https://docs.docker.com/get-started/docker-overview/>
2. Docker — imágenes y contenedores: <https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/>
3. Docker — volúmenes: <https://docs.docker.com/engine/storage/volumes/>
4. Docker Compose: <https://docs.docker.com/compose/>
5. Kubernetes — *Overview*: <https://kubernetes.io/es/docs/concepts/overview/>
6. En este repositorio: el `docker-compose.yml` de la raíz (comentado) y
   el [README](../README.md).
