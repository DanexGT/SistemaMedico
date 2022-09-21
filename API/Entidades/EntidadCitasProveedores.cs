using System;

namespace Entidades
{
    public class EntidadCitasProveedores : EntidadTokens
    {
        public int IdCitaProveedor { get; set; }
        public int IdProveedor { get; set; }
        public DateTime Cita { get; set; }
        public string Comentario { get; set; }
    }
}
