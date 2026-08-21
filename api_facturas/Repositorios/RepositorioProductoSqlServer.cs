// ============================================================
// RepositorioProductoSqlServer — la capa de DATOS de el producto.
//
// SQL escrito A MANO y SIEMPRE parametrizado; DAPPER como
// micro-ejecutor: QueryAsync<T> mapea columna→propiedad por nombre
// y ExecuteAsync devuelve filas afectadas — sin Entity Framework:
// nada genera SQL por nosotros (constitución, Art. 2).
// Dialecto SQL Server: TOP (@limite) al PRINCIPIO del SELECT (T-SQL no tiene LIMIT).
// ============================================================

using ApiFacturas.Modelos;
using Dapper;
using Microsoft.Data.SqlClient;

namespace ApiFacturas.Repositorios;

public class RepositorioProductoSqlServer : IRepositorioProducto
{
    private readonly string _cadenaConexion;

    public RepositorioProductoSqlServer(string cadenaConexion)
    {
        _cadenaConexion = cadenaConexion;
    }

    /// <summary>Conexión cerrada: Dapper la abre y cierra por operación;
    /// el "await using" del llamador la libera aunque haya error.</summary>
    private SqlConnection CrearConexion() => new(_cadenaConexion);

    public async Task<List<Producto>> ObtenerTodosAsync(int limite)
    {
        const string sql = @"SELECT TOP (@limite) codigo, nombre, stock, valorunitario
                             FROM producto ORDER BY codigo";
        await using var conexion = CrearConexion();
        var filas = await conexion.QueryAsync<Producto>(sql, new { limite });
        return filas.ToList();
    }

    public async Task<Producto?> ObtenerPorCodigoAsync(string codigo)
    {
        const string sql = @"SELECT codigo, nombre, stock, valorunitario
                             FROM producto WHERE codigo = @codigo";
        await using var conexion = CrearConexion();
        // Una fila → el modelo; cero filas → null (el SERVICIO decide qué
        // significa ese null — aquí solo hay hechos):
        return await conexion.QueryFirstOrDefaultAsync<Producto>(sql, new { codigo });
    }

    public async Task CrearAsync(Producto producto)
    {
        const string sql = @"INSERT INTO producto (codigo, nombre, stock, valorunitario)
                             VALUES (@Codigo, @Nombre, @Stock, @Valorunitario)";
        await using var conexion = CrearConexion();
        // El OBJETO del modelo como fuente de parámetros (@Propiedad):
        await conexion.ExecuteAsync(sql, producto);
    }

    public async Task<int> ActualizarAsync(string codigo, Dictionary<string, object> datos)
    {
        // SET dinámico SOLO con las columnas que llegaron (PUT manda todas,
        // PATCH un subconjunto). Los NOMBRES salen de las PETICIONES (lista
        // blanca) — jamás del cliente; los VALORES van parametrizados:
        var asignaciones = string.Join(", ", datos.Keys.Select(c => $"{c} = @{c}"));
        var sql = $"UPDATE producto SET {asignaciones} WHERE codigo = @codigo_clave";
        var parametros = new DynamicParameters(datos);
        parametros.Add("codigo_clave", codigo);
        await using var conexion = CrearConexion();
        // ExecuteAsync devuelve las FILAS AFECTADAS (0 = no existía):
        return await conexion.ExecuteAsync(sql, parametros);
    }

    public async Task<int> EliminarAsync(string codigo)
    {
        // Si otras tablas lo referencian, la FK del motor rechaza → 500:
        const string sql = "DELETE FROM producto WHERE codigo = @codigo";
        await using var conexion = CrearConexion();
        return await conexion.ExecuteAsync(sql, new { codigo });
    }
}
