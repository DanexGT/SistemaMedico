using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosPacientes
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarPaciente(EntidadPacientes Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.AgregarPaciente");
                Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                Comando.Parameters.AddWithValue("@_FechaNacimiento", Entidad.FechaNacimiento);
                Comando.Parameters.AddWithValue("@_Direccion", Entidad.Direccion);
                Comando.Parameters.AddWithValue("@_Sexo", Entidad.Sexo);
                Comando.Parameters.AddWithValue("@_Telefono", Entidad.Telefono);
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

        public static DataTable ObtenerPacientes(EntidadPacientes Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ObtenerPacientes"); 

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable BuscarPaciente(EntidadBusqueda Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ObtenerPacientes");
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


        public static DataTable ObtenerDatosPaciente(EntidadPacientes Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ObtenerDatosPaciente");
                Comando.Parameters.AddWithValue("@_IdPaciente", Entidad.IdPaciente);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable EliminarPaciente(EntidadPacientes Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.EliminarPaciente");
                Comando.Parameters.AddWithValue("@_IdPaciente", Entidad.IdPaciente);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ModificarPaciente(EntidadPacientes Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                   SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ModificarPaciente");
                   Comando.Parameters.AddWithValue("@_IdPaciente", Entidad.IdPaciente);
                   Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                   Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                   Comando.Parameters.AddWithValue("@_FechaNacimiento", Entidad.FechaNacimiento);
                   Comando.Parameters.AddWithValue("@_Direccion", Entidad.Direccion);
                   Comando.Parameters.AddWithValue("@_Sexo", Entidad.Sexo);
                   Comando.Parameters.AddWithValue("@_Telefono", Entidad.Telefono);

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
