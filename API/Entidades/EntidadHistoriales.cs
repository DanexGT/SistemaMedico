
namespace Entidades
{
    public class EntidadHistoriales : EntidadTokens
    {
        public int IdHistorialMedico { get; set; }
        public int IdPaciente { get; set; }
        public decimal Nombres { get; set; }
        public string Apellidos { get; set; }
        public string Direccion { get; set; }
        public string Email { get; set; }
        public string Contrasenia { get; set; }
        public int IdRol { get; set; }
    }
}
