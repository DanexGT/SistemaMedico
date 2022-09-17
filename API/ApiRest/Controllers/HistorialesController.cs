using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class HistorialesController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarHistorialMedico")]
        public DataTable AgregarHistorialMedico(EntidadHistoriales entidad)
        {
            return DatosHistoriales.AgregarHistorialMedico(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerHistorialesMedicos")]
        public DataTable ObtenerHistorialesMedicos(EntidadHistoriales entidad)
        {
            return DatosHistoriales.ObtenerHistorialesMedicos(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerHistorialesMedicosPaciente")]
        public DataTable ObtenerHistorialesMedicosPaciente(EntidadHistoriales entidad)
        {
            return DatosHistoriales.ObtenerHistorialesMedicosPaciente(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerDatosHistorialMedico")]
        public DataTable ObtenerDatosHistorialMedico(EntidadHistoriales entidad)
        {
            return DatosHistoriales.ObtenerDatosHistorialMedico(entidad);
        }

        [HttpPost]
        [Route("api/EliminarHistorialMedico")]
        public DataTable EliminarHistorialMedico(EntidadHistoriales entidad)
        {
            return DatosHistoriales.EliminarHistorialMedico(entidad);
        }

        [HttpPost]
        [Route("api/ModificarHistorialMedico")]
        public DataTable ModificarHistorialMedico(EntidadHistoriales entidad)
        {
            return DatosHistoriales.ModificarHistorialMedico(entidad);
        }
    }
}