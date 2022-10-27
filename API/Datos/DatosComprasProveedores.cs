using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosComprasProveedores
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarCompraProveedor(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.AgregarCompraProveedor");
                Comando.Parameters.AddWithValue("@_NumFactura", Entidad.NumFactura);
                Comando.Parameters.AddWithValue("@_IdProveedor", Entidad.IdProveedor);
                Comando.Parameters.AddWithValue("@_FechaFactura", Entidad.FechaFactura);
                Comando.Parameters.AddWithValue("@_TotalCompra", Entidad.TotalCompra);
                Comando.Parameters.AddWithValue("@_Token", Entidad.Token);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerComprasProveedor(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerComprasProveedor");
                Comando.Parameters.AddWithValue("@_IdProveedor", Entidad.IdProveedor);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerComprasProveedores(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerComprasProveedores");

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerDatosCompraProveedor(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerDatosCompraProveedor");
                Comando.Parameters.AddWithValue("@_IdCompra", Entidad.IdCompra);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable EliminarCompraProveedor(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.EliminarCompraProveedor");
                Comando.Parameters.AddWithValue("@_IdCompra", Entidad.IdCompra);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ModificarCompraProveedor(EntidadComprasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ModificarCompraProveedor");
                Comando.Parameters.AddWithValue("_IdCompra", Entidad.IdCompra);
                Comando.Parameters.AddWithValue("@_NumFactura", Entidad.NumFactura);
                Comando.Parameters.AddWithValue("@_FechaFactura", Entidad.FechaFactura);
                Comando.Parameters.AddWithValue("@_TotalCompra", Entidad.TotalCompra);
                Comando.Parameters.AddWithValue("@_IdEstadoCompra", Entidad.IdEstadoCompra);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

    }
}
