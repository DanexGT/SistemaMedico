using System;

namespace Entidades
{
    public class EntidadPagosAProveedores : EntidadTokens
    {
        public int IdPagoAProveedor { get; set; }
        public int IdProveedor { get; set; }
        public int Saldo { get; set; }
        public DateTime FechaFactura { get; set; }
        public int Pago { get; set; }
        public DateTime FechaPago { get; set; }
        public string EstadoPago { get; set; }
    }
}
