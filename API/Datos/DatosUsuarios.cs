using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosUsuarios
    {
        private static readonly Funciones Funciones = new Funciones();
        private static readonly int VigenciaMinutos = 1;
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
                Comando.Parameters.AddWithValue("@_IdRol", Entidad.IdRol);
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

        public static DataTable ObtenerUsuarios(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
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
                if (Entidad.Contrasenia.Length > 0)
                {
                    SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ModificarUsuario");
                    Comando.Parameters.AddWithValue("@_IdUsuario", Entidad.IdUsuario);
                    Comando.Parameters.AddWithValue("@_Nombres", Entidad.Nombres);
                    Comando.Parameters.AddWithValue("@_Apellidos", Entidad.Apellidos);
                    Comando.Parameters.AddWithValue("@_Direccion", Entidad.Direccion);
                    Comando.Parameters.AddWithValue("@_Email", Entidad.Email);
                    Comando.Parameters.AddWithValue("@_Contrasenia", Funciones.SeguridadSHA512(Entidad.Contrasenia));
                    Comando.Parameters.AddWithValue("@_IdRol", Entidad.IdRol);

                    DT = Conexion.EjecutarComandoSelect(Comando);
                    DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

                }
            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable IniciarSesion(EntidadUsuarios Entidad)
        {
            SqlCommand Comando = Conexion.CrearComandoProc("Sesion.IniciarSesion");
            Comando.Parameters.AddWithValue("@_Email", Entidad.Email);
            Comando.Parameters.AddWithValue("@_Contrasenia", Funciones.SeguridadSHA512(Entidad.Contrasenia));
            Comando.Parameters.AddWithValue("@_Token", Funciones.GenerarTokenDeSesion());
            Comando.Parameters.AddWithValue("@_VigenciaMinutos", VigenciaMinutos);

            return Conexion.EjecutarComandoSelect(Comando);
        }

        //OBTIENE LOS ENLACES O MENUS DE OPCIONES A LAS QUE TENDRÁ ACCESO EL USUARIO
        public static DataTable MenuUsuario(EntidadUsuarios Entidad)
        {
            SqlCommand Comando = Conexion.CrearComandoProc("Sesion.MenuUsuario");
            Comando.Parameters.AddWithValue("@_Token", Entidad.Token);
            Comando.Parameters.AddWithValue("@_IdModulo", Entidad.IdModulo);

            return Conexion.EjecutarComandoSelect(Comando);
        }
    }
}
