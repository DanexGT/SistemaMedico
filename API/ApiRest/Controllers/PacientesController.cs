using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest.Controllers
{
    public class PacientesController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarPaciente")]
        public DataTable AgregarPaciente(EntidadPacientes entidad)
        {
            return DatosPacientes.AgregarPaciente(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerPacientes")]
        public DataTable ObtenerPacientes(EntidadPacientes entidad)
        {
            return DatosPacientes.ObtenerPacientes(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerDatosPaciente")]
        public DataTable ObtenerDatosPaciente(EntidadPacientes entidad)
        {
            return DatosPacientes.ObtenerDatosPaciente(entidad);
        }

        [HttpPost]
        [Route("api/EliminarPaciente")]
        public DataTable EliminarPaciente(EntidadPacientes entidad)
        {
            return DatosPacientes.EliminarPaciente(entidad);
        }

        [HttpPost]
        [Route("api/ModificarPaciente")]
        public DataTable ModificarPaciente(EntidadPacientes entidad)
        {
            return DatosPacientes.ModificarPaciente(entidad);
        }

    }
}
