using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Datos
{
    public class Conexion
    {
        private static string Usuario = "sa";
        private static string Contrasenia = "1234";
        private static string Servidor = "Danex\\SQLExpress";
        private static string BaseDeDatos = "BDSistemaMedico";

        public static string CadenaConexionSQL()
        {
            return "Persist Security Info = False; User ID = '" + Usuario
                + "'; Contrasenia = '" + Contrasenia
                + "'; Initial Catalog = '" + BaseDeDatos
                + "'; Server =" + Servidor + "'";
    }
}
