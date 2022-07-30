using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Datos
{
    public class Usuarios
    {
        private static readonly Funciones Funciones = new Funciones();
        private static readonly int VigenciaEnMinutos = 30;
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarUsuario(EntidadUsuarios Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.TxtToken);

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
    }
}
