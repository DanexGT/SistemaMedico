using System;
using System.Data;
using System.Data.SqlClient;

namespace Datos
{
    public class Conexion
    {
        //Datos para Conexion con la BD de SQL
        private static string Usuario = "sa";
        private static string Contrasenia = "1234";
        private static string Servidor = "Danex\\SQLExpress";
        private static string BaseDeDatos = "BDSistemaMedico";

        public static string ObtenerCadenaConexionSQL()
        {
            return "Persist Security Info = False; User ID = '" + Usuario
                + "'; Contrasenia = '" + Contrasenia
                + "'; Initial Catalog = '" + BaseDeDatos
                + "'; Server =" + Servidor + "'";
        }

        //EJECUTAR PROCEDIMIENTO ALMACENADO PASANDOLO COMO PARAMETRO
        public static SqlCommand CrearComandoProc(string SP)
        {
            string CadenaConexion = Conexion.ObtenerCadenaConexionSQL();
            SqlConnection MiConexion = new SqlConnection(CadenaConexion);
            SqlCommand Comando = new SqlCommand(SP, MiConexion);
            Comando.CommandType = CommandType.StoredProcedure;
            return Comando;
        }

        /*
         EjecutarComandoSelect
         */
        public static DataTable EjecutarComandoSelect(SqlCommand Comando)
        {
            DataTable DT = new DataTable();
            try
            {
                Comando.Connection.Open();
                SqlDataAdapter adaptador = new SqlDataAdapter();
                adaptador.SelectCommand = Comando;
                adaptador.Fill(DT);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                Comando.Connection.Dispose(); //Limpiar la memoria
                Comando.Connection.Close(); //Cierra la sesión y conexión
            }
            return DT;
        }
    }
}
