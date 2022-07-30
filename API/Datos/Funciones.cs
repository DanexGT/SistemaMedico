﻿using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;

namespace Datos
{
    public class Funciones
    {
        public string lblStatus = "";
        private string CodigoDeSeguridad = "d@n3x"; //Código para cifrar las contraseñas
        //private string CodigoDeSeguridad = "j@3!";
        private static DataTable DT = new DataTable();

        public string SeguridadSHA512(string Pass) //Función Hash de Cifrado
        {
            System.Security.Cryptography.SHA512Managed HashTool = new System.Security.Cryptography.SHA512Managed(); //Instanciar objeto para encriptar
            Byte[] HashByte = Encoding.UTF8.GetBytes(string.Concat(Pass, CodigoDeSeguridad)); //Arreglo de byte para convertir y concatenar
            Byte[] EncryptedByte = HashTool.ComputeHash(HashByte); //Arreglo para devolver objeto encriptado
            HashTool.Clear(); //Limpiar de memoria

            return Convert.ToBase64String(EncryptedByte); //Devolver resultado en String
        }

        public string GenerarTokenDeSesion()
        {
            Random Rnd = new Random();
            int Aleatorio = Rnd.Next(1, 99999);

            string Hora = DateTime.Now.ToString("hh:mm:ss");
            string Fecha = DateTime.Now.ToString("dd/MM/yyyy");

            string TxtToken = SeguridadSHA512(Fecha + Hora + Aleatorio);

            TxtToken = Regex.Replace(TxtToken, @"[^0-9A-Za-z]", "", RegexOptions.None);

            return TxtToken;
        }

        public static int ObtenerEstadoToken(string TxtToken)
        {
            SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ObtenerEstadoToken");
            Comando.Parameters.AddWithValue("@_Token", TxtToken);

            DT.Reset();
            DT.Clear();

            // 0 = Expirado, 1 = Vigente
            DT = Conexion.EjecutarComandoSelect(Comando);
            return Convert.ToInt32(DT.Rows[0][0].ToString());
        }

        //AGREGA EL ESTADO DEL TOKEN A CADA DATATABLE O SET DE DATOS
        public static DataTable AgregarEstadoToken(DataTable DT, string Estado)
        {
            if (DT.Rows.Count > 0)
            {
                DT.Columns.Add("EstatoToken", typeof(string), Estado).SetOrdinal(0);
            }
            else
            {
                DT.Reset();
                DT.Clear();

                try
                {
                    DataColumn Col = new DataColumn();
                    Col.ColumnName = "EstadoToken";
                    DT.Columns.Add(Col);

                    DataRow Fila = DT.NewRow();
                    Fila["EstadoToken"] = Estado;
                    DT.Rows.Add(Fila);
                }
                catch
                {
                    DataRow Fila = DT.NewRow();
                    Fila["EstadoToken"] = Estado;
                    DT.Rows.Add(Fila);
                }
            }

            return DT;
        }
    }
}
