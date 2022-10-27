using System;

namespace Entidades
{
    public class EntidadComprasProveedores : EntidadTokens
    {
        public int IdCompra { get; set; }
        public string NumFactura { get; set; }
        public int IdProveedor { get; set; }
        public DateTime FechaFactura { get; set; }
        public decimal TotalCompra { get; set; }
        public int IdEstadoCompra { get; set; }
    }
}
