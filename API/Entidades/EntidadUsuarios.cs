﻿
namespace Entidades
{
    public class EntidadUsuarios : EntidadTokens
    {
        //public int IdUsuario { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public string Direccion { get; set; }
        public string Email { get; set; }
        public string Contrasenia { get; set; }
        public int IdRol { get; set; }

        //public string FechaIngreso { get; set; }

        //public int Estado { get; set; }
    }
}
