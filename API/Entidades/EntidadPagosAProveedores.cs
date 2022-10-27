using System;

namespace Entidades
{
    public class EntidadPagosAProveedores : EntidadTokens
    {
        public int IdPago { get; set; }
        public int IdCompra { get; set; }
        public DateTime FechaPago { get; set; }
        public decimal MontoPago{ get; set; }
        public int IdEstadoPago { get; set; }
    }
}
