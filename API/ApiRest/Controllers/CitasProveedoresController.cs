using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class CitasProveedoresController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarCitaProveedor")]
        public DataTable AgregarCitaProveedor(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.AgregarCitaProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerCitasProveedor")]
        public DataTable ObtenerCitasProveedor(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.ObtenerCitasProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerCitasProveedores")]
        public DataTable ObtenerCitasProveedores(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.ObtenerCitasProveedores(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerDatosCitaProveedor")]
        public DataTable ObtenerDatosCitaProveedor(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.ObtenerDatosCitaProveedor(entidad);
        }

        [HttpPost]
        [Route("api/EliminarCitaProveedor")]
        public DataTable EliminarCitaProveedor(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.EliminarCitaProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ModificarCitaProveedor")]
        public DataTable ModificarCitaProveedor(EntidadCitasProveedores entidad)
        {
            return DatosCitasProveedores.ModificarCitaProveedor(entidad);
        }
    }
}