using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class ComprasProveedoresController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarCompraProveedor")]
        public DataTable AgregarCompraProveedor(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.AgregarCompraProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerComprasProveedor")]
        public DataTable ObtenerComprasProveedor(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.ObtenerComprasProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerComprasProveedores")]
        public DataTable ObtenerComprasProveedores(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.ObtenerComprasProveedores(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerDatosCompraProveedor")]
        public DataTable ObtenerDatosCompraProveedor(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.ObtenerDatosCompraProveedor(entidad);
        }

        [HttpPost]
        [Route("api/EliminarCompraProveedor")]
        public DataTable EliminarCompraProveedor(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.EliminarCompraProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ModificarCompraProveedor")]
        public DataTable ModificarCompraProveedor(EntidadComprasProveedores entidad)
        {
            return DatosComprasProveedores.ModificarCompraProveedor(entidad);
        }
    }
}