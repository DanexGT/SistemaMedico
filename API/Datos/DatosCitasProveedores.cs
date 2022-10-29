using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosCitasProveedores
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarCitaProveedor(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.AgregarCitaProveedor");
                Comando.Parameters.AddWithValue("@_IdProveedor", Entidad.IdProveedor);
                Comando.Parameters.AddWithValue("@_Cita", Entidad.Cita);
                Comando.Parameters.AddWithValue("@_Comentario", Entidad.Comentario);
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

        public static DataTable ObtenerCitasProveedor(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerCitasProveedor");
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

        public static DataTable ObtenerCitasProveedores(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerCitasProveedores");

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerDatosCitaProveedor(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerDatosCitaProveedor");
                Comando.Parameters.AddWithValue("@_IdCitaProveedor", Entidad.IdCitaProveedor);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable EliminarCitaProveedor(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.EliminarCitaProveedor");
                Comando.Parameters.AddWithValue("@_IdCitaProveedor", Entidad.IdCitaProveedor);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ModificarCitaProveedor(EntidadCitasProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ModificarCitaProveedor");
                Comando.Parameters.AddWithValue("@_IdCitaProveedor", Entidad.IdCitaProveedor);
                Comando.Parameters.AddWithValue("@_Cita", Entidad.Cita);
                Comando.Parameters.AddWithValue("@_Comentario", Entidad.Comentario);

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
