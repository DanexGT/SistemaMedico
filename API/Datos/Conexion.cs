﻿using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;

namespace Datos
{
    public class Conexion
    {
        //Datos para Conexion con la BD de SQL
        //private static string Usuario = "sa";
        //private static string Password = "alexander02";
        //private static string Servidor = "Danex\\SQLExpress";
        //private static string BaseDeDatos = "BDSistemaMedico";

        private static string Usuario = WebConfigurationManager.AppSettings["Usuario"].ToString();
        private static string Password = WebConfigurationManager.AppSettings["Password"].ToString();
        private static string Servidor = WebConfigurationManager.AppSettings["Servidor"].ToString();
        private static string BaseDeDatos = WebConfigurationManager.AppSettings["BaseDeDatos"].ToString();

        public static string ObtenerCadenaConexionSQL()
        {
            return "Persist Security Info = False; User ID = '" + Usuario
                    + "'; Password = '" + Password
                    + "'; Initial Catalog = '" + BaseDeDatos
                    + "'; Server = '" + Servidor + "'";
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
