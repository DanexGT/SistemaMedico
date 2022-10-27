using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosPagosAProveedores
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarPagoProveedor(EntidadPagosAProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.AgregarPagoProveedor");
                Comando.Parameters.AddWithValue("@_IdCompra", Entidad.IdCompra);
                Comando.Parameters.AddWithValue("@_FechaPago", Entidad.FechaPago);
                Comando.Parameters.AddWithValue("@_MontoPago", Entidad.MontoPago);
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

        public static DataTable ObtenerPagosProveedor(EntidadPagosAProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerPagosProveedor");
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

        public static DataTable ObtenerPagosProveedores(EntidadPagosAProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerPagosProveedores");

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        //public static DataTable ObtenerDatosPagoProveedor(EntidadPagosAProveedores Entidad)
        //{
        //    Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

        //    // 0 expirado, 1 vigente
        //    if (Estado == 1)
        //    {
        //        SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerDatosPagoProveedor");
        //        Comando.Parameters.AddWithValue("@_IdPagoAProveedor", Entidad.IdPagoAProveedor);

        //        DT = Conexion.EjecutarComandoSelect(Comando);
        //        DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

        //    }
        //    else
        //    {
        //        DT = Funciones.AgregarEstadoToken(DT, "0");
        //    }

        //    return DT;
        //}

        //public static DataTable EliminarPagoProveedor(EntidadPagosAProveedores Entidad)
        //{
        //    Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

        //    // 0 expirado, 1 vigente
        //    if (Estado == 1)
        //    {
        //        SqlCommand Comando = Conexion.CrearComandoProc("Compra.EliminarPagoProveedor");
        //        Comando.Parameters.AddWithValue("@_IdPagoAProveedor", Entidad.IdPagoAProveedor);

        //        DT = Conexion.EjecutarComandoSelect(Comando);
        //        DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

        //    }
        //    else
        //    {
        //        DT = Funciones.AgregarEstadoToken(DT, "0");
        //    }

        //    return DT;
        //}

        //public static DataTable ModificarPagoProveedor(EntidadPagosAProveedores Entidad)
        //{
        //    Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

        //    // 0 expirado, 1 vigente
        //    if (Estado == 1)
        //    {
        //        SqlCommand Comando = Conexion.CrearComandoProc("Compra.ModificarPagoProveedor");
        //        Comando.Parameters.AddWithValue("@_IdPagoAProveedor", Entidad.IdPagoAProveedor);
        //        Comando.Parameters.AddWithValue("@_Saldo", Entidad.Saldo);
        //        Comando.Parameters.AddWithValue("@_FechaFactura", Entidad.FechaFactura);
        //        Comando.Parameters.AddWithValue("@_Pago", Entidad.Pago);
        //        Comando.Parameters.AddWithValue("@_FechaPago", Entidad.FechaPago);
        //        Comando.Parameters.AddWithValue("@_EstadoPago", Entidad.EstadoPago);

        //        DT = Conexion.EjecutarComandoSelect(Comando);
        //        DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
        //    }
        //    else
        //    {
        //        DT = Funciones.AgregarEstadoToken(DT, "0");
        //    }

        //    return DT;
        //}

    }
}
