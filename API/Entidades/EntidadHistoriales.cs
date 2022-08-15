
namespace Entidades
{
    public class EntidadHistoriales : EntidadTokens
    {
        public int IdHistorialMedico { get; set; }
        public int IdPaciente { get; set; }
        public decimal PesoLibras { get; set; }
        public int AlturaCentimetros { get; set; }
        public string PresionArterial { get; set; }
        public int FrecuenciaCardiaca { get; set; }
        public int FrecuenciaRespiratoria { get; set; }
        public decimal TemperaturaCelsius { get; set; }
        public string MotivoConsulta { get; set; }
        public string Diagnostico { get; set; }
        public string Tratamiento { get; set; }
        public string Comentario { get; set; }
    }
}
