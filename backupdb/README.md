# backupdb — respaldos de la base de datos

En esta carpeta se guardan los **respaldos (backups)** de `bdfacturas`.
SQL Server no usa dumps `.sql` como otros motores: su mecanismo nativo es
`BACKUP DATABASE`, que produce un archivo **`.bak`** binario (datos + log
en un solo archivo) — el formato estándar de respaldo del mundo Microsoft.

> ¿En qué se diferencia de `db/bdfacturas.sql`? En que ese script crea la
> BD en su **estado inicial** (los datos de fábrica del curso), mientras
> que un backup captura **SU estado actual**: lo que usted insertó, editó o
> borró. Si solo quiere volver al estado inicial, no necesita backup:
> `docker compose down -v` y volver a subir.

Convención de nombres: `bdfacturas_sqlserver_AAAA-MM-DD.bak` (si hace
varios el mismo día, agregue un sufijo: `_2.bak`).

---

## Cómo hacer un backup

Con el proyecto corriendo, desde la **raíz del repositorio** (dos comandos:
el respaldo se genera DENTRO del contenedor y luego se copia a esta
carpeta — así funciona igual en PowerShell, CMD o bash):

```powershell
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Paradigmas123!" -C -Q "BACKUP DATABASE bdfacturas_sqlserver_local TO DISK='/tmp/backup.bak' WITH INIT"
docker compose cp sqlserver:/tmp/backup.bak backupdb/bdfacturas_sqlserver_2026-08-08.bak
```

Qué hace cada pieza:

- `sqlcmd` — el cliente de línea de comandos de SQL Server (ya viene
  dentro del contenedor, no hay que instalar nada).
- `BACKUP DATABASE ... TO DISK` — el comando T-SQL nativo de respaldo;
  `WITH INIT` sobreescribe el archivo si ya existía.
- `docker compose cp` — copia el archivo del contenedor a su PC.

## Cómo restaurar un backup (restore)

El camino inverso: copiar el `.bak` al contenedor y ejecutar
`RESTORE DATABASE`. `WITH REPLACE` pisa la BD actual; el `SINGLE_USER`
saca las conexiones abiertas (por ejemplo la de la API) durante el
restore, y `MULTI_USER` las vuelve a permitir:

```powershell
docker compose cp backupdb/bdfacturas_sqlserver_2026-08-08.bak sqlserver:/tmp/restore.bak
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Paradigmas123!" -C -Q "ALTER DATABASE bdfacturas_sqlserver_local SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE bdfacturas_sqlserver_local FROM DISK='/tmp/restore.bak' WITH REPLACE; ALTER DATABASE bdfacturas_sqlserver_local SET MULTI_USER;"
```

Verifique: `http://localhost:8036/api/producto` debe mostrar los datos tal
como estaban cuando hizo el backup.

## Para probar el ciclo completo (ejercicio)

1. Haga un backup (arriba).
2. Cambie algo a propósito: cree un producto `PR999` con la API (POST) o
   edite el stock de uno existente.
3. Restaure el backup.
4. `PR999` desapareció (o el stock volvió) — la BD regresó EXACTAMENTE al
   momento del backup. Eso es un respaldo funcionando.

> ⚠️ El restore pisa TODO el contenido actual de la BD con el del archivo.
> Lo que haya cambiado DESPUÉS del backup se pierde. Por eso los respaldos
> se hacen ANTES de operaciones riesgosas (y en producción, con agenda).
