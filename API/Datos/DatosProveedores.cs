using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosProveedores
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarProveedor(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.AgregarProveedor");
                Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                Comando.Parameters.AddWithValue("@_Telefono", Entidad.Telefono);
                Comando.Parameters.AddWithValue("@_LaboratorioClinico", Entidad.LaboratorioClinico);
                Comando.Parameters.AddWithValue("@_Distribuidor", Entidad.Distribuidor);
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

        public static DataTable ObtenerProveedores(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerProveedores");

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerUnProveedor(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerUnProveedor");
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

        public static DataTable BuscarProveedor(EntidadBusqueda Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerProveedores");
                Comando.Parameters.AddWithValue("@_Busqueda", Entidad.Busqueda);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;

        }


        public static DataTable ObtenerDatosProveedor(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.ObtenerDatosProveedor");
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

        public static DataTable EliminarProveedor(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Compra.EliminarProveedor");
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

        public static DataTable ModificarProveedor(EntidadProveedores Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                   SqlCommand Comando = Conexion.CrearComandoProc("Compra.ModificarProveedor");
                   Comando.Parameters.AddWithValue("@_IdProveedor", Entidad.IdProveedor);
                   Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                   Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                   Comando.Parameters.AddWithValue("@_Telefono", Entidad.Telefono);
                   Comando.Parameters.AddWithValue("@_LaboratorioClinico", Entidad.LaboratorioClinico);
                   Comando.Parameters.AddWithValue("@_Distribuidor", Entidad.Distribuidor);

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
