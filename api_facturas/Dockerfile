# ==============================================================
# Dockerfile de la API Facturas — ASP.NET Core / .NET 10 (puerto 8036)
#
# Usa la imagen del SDK (no la de runtime) a propósito: el
# contenedor corre `dotnet watch`, que RECOMPILA Y REINICIA solo
# cuando usted guarda un archivo .cs — el ciclo de desarrollo del
# curso (guardar → esperar la recompilación → refrescar).
# ==============================================================

FROM mcr.microsoft.com/dotnet/sdk:10.0

# Carpeta de trabajo dentro del contenedor (el compose monta aquí el código):
WORKDIR /app

# Variables de entorno:
#   DOTNET_USE_POLLING_FILE_WATCHER: en Docker sobre Windows, los avisos
#     de "archivo cambiado" no siempre llegan; el sondeo (polling) revisa
#     los archivos cada tanto y el watch funciona confiable.
#   ASPNETCORE_URLS: en qué dirección y puerto escucha la API dentro del
#     contenedor (el compose publica ese 8036 hacia su PC).
ENV DOTNET_USE_POLLING_FILE_WATCHER=1 \
    ASPNETCORE_URLS=http://0.0.0.0:8036

EXPOSE 8036

# El comando de arranque: dotnet watch compila, ejecuta y se queda
# vigilando los archivos. --non-interactive para que no haga preguntas.
CMD ["dotnet", "watch", "run", "--non-interactive", "--project", "ApiFacturas.csproj"]
