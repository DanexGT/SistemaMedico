using System;

namespace Entidades
{
    public class EntidadPacientes : EntidadTokens
    {
        public int IdPaciente { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public string Direccion { get; set; }
        public string Sexo { get; set; }
        public int Telefono { get; set; }
    }
}
