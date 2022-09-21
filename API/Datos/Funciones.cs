using System;
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
            int Aleatorio = Rnd.Next(1, 99999); //Generar número aleatorio

            string Hora = DateTime.Now.ToString("hh:mm:ss");
            string Fecha = DateTime.Now.ToString("dd/MM/yyyy");

            string Token = SeguridadSHA512(Fecha + Hora + Aleatorio); //Encriptar token con los parámetros creados anteriormente

            Token = Regex.Replace(Token, @"[^0-9A-Za-z]", "", RegexOptions.None); //Reemplazar caracteres con los deseados (evitar errores en JSON)

            return Token;
        }

        public static int ObtenerEstadoToken(string Token)
        {
            SqlCommand Comando = Conexion.CrearComandoProc("Sesion.ObtenerEstadoToken");
            Comando.Parameters.AddWithValue("@_Token", Token);

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
                DT.Columns.Add("EstadoToken", typeof(string), Estado).SetOrdinal(0);  //AGREGAR UNA COLUMNA A TODOS LOS DATA TABLE
            }                                                                         //CON EL ESTADO DE TOKEN EN LA PRIMERA POSICIÓN
            else
            {
                DT.Reset();     //LIMPIAR TODO LO DE MEMORIA
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
