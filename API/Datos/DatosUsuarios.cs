using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Datos
{
    public class DatosUsuarios
    {
        private static readonly Funciones Funciones = new Funciones();
        private static readonly int VigenciaEnMinutos = 30;
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarUsuario(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Sesion.AgregarUsuario");
                Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                Comando.Parameters.AddWithValue("@_Direccion", Entidad.Direccion);
                Comando.Parameters.AddWithValue("@_Email", Entidad.Email);
                Comando.Parameters.AddWithValue("@_Contrasenia", Funciones.SeguridadSHA512(Entidad.Contrasenia));
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

        public static DataTable ObtenerUsuarios(EntidadUsuarios entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ObtenerUsuarios");

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ObtenerDatosUsuario(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ObtenerDatosUsuario");
                Comando.Parameters.AddWithValue("@_IdUsuario", Entidad.IdUsuario);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable EliminarUsuario(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Sesion.EliminarUsuario");
                Comando.Parameters.AddWithValue("@_IdUsuario", Entidad.IdUsuario);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ModificarUsuario(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ModificarUsuario");
                Comando.Parameters.AddWithValue("@_IdUsuario", Entidad.IdUsuario);
                Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                Comando.Parameters.AddWithValue("@_Direccion", Entidad.Direccion);
                Comando.Parameters.AddWithValue("@_Email", Entidad.Email);
                Comando.Parameters.AddWithValue("@_Contrasenia", Funciones.SeguridadSHA512(Entidad.Contrasenia));

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
