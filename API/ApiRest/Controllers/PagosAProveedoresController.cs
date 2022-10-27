using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class PagosAProveedoresController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarPagoProveedor")]
        public DataTable AgregarPagoProveedor(EntidadPagosAProveedores entidad)
        {
            return DatosPagosAProveedores.AgregarPagoProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerPagosProveedor")]
        public DataTable ObtenerPagosProveedor(EntidadPagosAProveedores entidad)
        {
            return DatosPagosAProveedores.ObtenerPagosProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerPagosProveedores")]
        public DataTable ObtenerPagosProveedores(EntidadPagosAProveedores entidad)
        {
            return DatosPagosAProveedores.ObtenerPagosProveedores(entidad);
        }

        //[HttpPost]
        //[Route("api/ObtenerDatosPagoProveedor")]
        //public DataTable ObtenerDatosPagoProveedor(EntidadPagosAProveedores entidad)
        //{
        //    return DatosPagosAProveedores.ObtenerDatosPagoProveedor(entidad);
        //}

        //[HttpPost]
        //[Route("api/EliminarPagoProveedor")]
        //public DataTable EliminarPagoProveedor(EntidadPagosAProveedores entidad)
        //{
        //    return DatosPagosAProveedores.EliminarPagoProveedor(entidad);
        //}

        //[HttpPost]
        //[Route("api/ModificarPagoProveedor")]
        //public DataTable ModificarPagoProveedor(EntidadPagosAProveedores entidad)
        //{
        //    return DatosPagosAProveedores.ModificarPagoProveedor(entidad);
        //}
    }
}