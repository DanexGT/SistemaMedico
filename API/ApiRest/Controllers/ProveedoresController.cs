using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class ProveedoresController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarProveedor")]
        public DataTable AgregarProveedor(EntidadProveedores entidad)
        {
            return DatosProveedores.AgregarProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerProveedores")]
        public DataTable ObtenerProveedores(EntidadProveedores entidad)
        {
            return DatosProveedores.ObtenerProveedores(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerUnProveedor")]
        public DataTable ObtenerUnProveedor(EntidadProveedores entidad)
        {
            return DatosProveedores.ObtenerUnProveedor(entidad);
        }

        [HttpPost]
        [Route("api/BuscarProveedores")]
        public DataTable BuscarProveedor(EntidadBusqueda busqueda)
        {
            return DatosProveedores.BuscarProveedor(busqueda);
        }

        [HttpPost]
        [Route("api/ObtenerDatosProveedor")]
        public DataTable ObtenerDatosProveedor(EntidadProveedores entidad)
        {
            return DatosProveedores.ObtenerDatosProveedor(entidad);
        }

        [HttpPost]
        [Route("api/EliminarProveedor")]
        public DataTable EliminarProveedor(EntidadProveedores entidad)
        {
            return DatosProveedores.EliminarProveedor(entidad);
        }

        [HttpPost]
        [Route("api/ModificarProveedor")]
        public DataTable ModificarProveedor(EntidadProveedores entidad)
        {
            return DatosProveedores.ModificarProveedor(entidad);
        }


    }
}
