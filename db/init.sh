#!/bin/bash
# ==============================================================
# Inicializador de SQL Server (contenedor sqlserver-init).
#
# ¿Por qué existe este script? A diferencia de otros motores,
# SQL Server NO ejecuta automáticamente los scripts que se le
# monten: alguien tiene que conectarse y correrlos. Ese "alguien"
# es este script, que corre en un contenedor aparte, hace su
# trabajo UNA sola vez y termina.
#
# Crea la base de datos bdfacturas_sqlserver_local y ejecuta
# bdfacturas.sql SOLO si la BD no existe todavía (idempotente:
# correrlo mil veces no daña nada).
# ==============================================================

# set -e = "si cualquier comando falla, detente aquí" (no seguir a ciegas)
set -e

# Variables del script (para no repetir texto):
SQLCMD=/opt/mssql-tools18/bin/sqlcmd   # el cliente de línea de comandos de SQL Server
SERVER=sqlserver                       # el HOSTNAME interno del motor (nombre del servicio)
DB=bdfacturas_sqlserver_local          # la base de datos del curso

echo "[init] Verificando si la base de datos $DB existe..."
# Pregunta al catálogo del motor cuántas BD se llaman así (0 o 1):
EXISTE=$($SQLCMD -S $SERVER -U sa -P "$MSSQL_SA_PASSWORD" -C -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = '$DB'")

if [ "$EXISTE" = "1" ]; then
    echo "[init] La base de datos $DB ya existe. No se hace nada."
    exit 0
fi

echo "[init] Creando base de datos $DB..."
$SQLCMD -S $SERVER -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "CREATE DATABASE $DB"

echo "[init] Ejecutando script bdfacturas.sql..."
# -d $DB = conectarse A esa base de datos; -i = ejecutar el archivo:
$SQLCMD -S $SERVER -U sa -P "$MSSQL_SA_PASSWORD" -C -d $DB -i /scripts/bdfacturas.sql

echo "[init] SQL Server inicializado correctamente."
