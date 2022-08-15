using Entidades;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class DatosHistoriales
    {
        private static DataTable DT = new DataTable();
        private static int Estado = 0;

        public static DataTable AgregarHistorialMedico(EntidadHistoriales Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.AgregarHistorialMedico");
                Comando.Parameters.AddWithValue("@_IdPaciente", Entidad.IdPaciente);
                Comando.Parameters.AddWithValue("@_PesoLibras", Entidad.PesoLibras);
                Comando.Parameters.AddWithValue("@_AlturaCentimetros", Entidad.AlturaCentimetros);
                Comando.Parameters.AddWithValue("@_PresionArterial", Entidad.PresionArterial);
                Comando.Parameters.AddWithValue("@_FrecuenciaCardiaca", Entidad.FrecuenciaCardiaca);
                Comando.Parameters.AddWithValue("@_FrecuenciaRespiratoria", Entidad.FrecuenciaRespiratoria);
                Comando.Parameters.AddWithValue("@_TemperaturaCelsius", Entidad.TemperaturaCelsius);
                Comando.Parameters.AddWithValue("@_MotivoConsulta", Entidad.MotivoConsulta);
                Comando.Parameters.AddWithValue("@_Diagnostico", Entidad.Diagnostico);
                Comando.Parameters.AddWithValue("@_Tratamiento", Entidad.Tratamiento);
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

        public static DataTable ObtenerHistorialesMedicosPaciente(EntidadHistoriales Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);
            DT.Clear();

            //0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ObtenerHistorialesMedicosPaciente");
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

        public static DataTable ObtenerDatosHistorialMedico(EntidadHistoriales Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ObtenerDatosHistorialMedico");
                Comando.Parameters.AddWithValue("@_IdHistorialMedico", Entidad.IdHistorialMedico);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable EliminarHistorialMedico(EntidadHistoriales Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.EliminarHistorialMedico");
                Comando.Parameters.AddWithValue("@_IdHistorialMedico", Entidad.IdHistorialMedico);

                DT = Conexion.EjecutarComandoSelect(Comando);
                DT = Funciones.AgregarEstadoToken(DT, Estado.ToString());

            }
            else
            {
                DT = Funciones.AgregarEstadoToken(DT, "0");
            }

            return DT;
        }

        public static DataTable ModificarHistorialMedico(EntidadHistoriales Entidad)
        {
            Estado = Funciones.ObtenerEstadoToken(Entidad.Token);

            // 0 expirado, 1 vigente
            if (Estado == 1)
            {
                SqlCommand Comando = Conexion.CrearComandoProc("Atencion.ModificarHistorialMedico");
                Comando.Parameters.AddWithValue("@_IdHistorialMedico", Entidad.IdHistorialMedico);
                Comando.Parameters.AddWithValue("@_PesoLibras", Entidad.PesoLibras);
                Comando.Parameters.AddWithValue("@_AlturaCentimetros", Entidad.AlturaCentimetros);
                Comando.Parameters.AddWithValue("@_PresionArterial", Entidad.PresionArterial);
                Comando.Parameters.AddWithValue("@_FrecuenciaCardiaca", Entidad.FrecuenciaCardiaca);
                Comando.Parameters.AddWithValue("@_FrecuenciaRespiratoria", Entidad.FrecuenciaRespiratoria);
                Comando.Parameters.AddWithValue("@_TemperaturaCelsius", Entidad.TemperaturaCelsius);
                Comando.Parameters.AddWithValue("@_MotivoConsulta", Entidad.MotivoConsulta);
                Comando.Parameters.AddWithValue("@_Diagnostico", Entidad.Diagnostico);
                Comando.Parameters.AddWithValue("@_Tratamiento", Entidad.Tratamiento);
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
