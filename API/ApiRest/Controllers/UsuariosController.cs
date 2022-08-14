using Datos;
using Entidades;
using System.Data;
using System.Web.Http;

namespace ApiRest
{
    public class UsuariosController : ApiController
    {
        [HttpPost]
        [Route("api/AgregarUsuario")]
        public DataTable Agregarusuario(EntidadUsuarios entidad)
        {
            return DatosUsuarios.AgregarUsuario(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerUsuarios")]
        public DataTable ObtenerUsuarios(EntidadUsuarios entidad)
        {
            return DatosUsuarios.ObtenerUsuarios(entidad);
        }

        [HttpPost]
        [Route("api/ObtenerDatosUsuario")]
        public DataTable ObtenerDatosUsuario(EntidadUsuarios entidad)
        {
            return DatosUsuarios.ObtenerDatosUsuario(entidad);
        }

        [HttpPost]
        [Route("api/EliminarUsuario")]
        public DataTable EliminarUsuario(EntidadUsuarios entidad)
        {
            return DatosUsuarios.EliminarUsuario(entidad);
        }

        [HttpPost]
        [Route("api/ModificarUsuario")]
        public DataTable ModificarUsuario(EntidadUsuarios entidad)
        {
            return DatosUsuarios.ModificarUsuario(entidad);
        }

        [HttpPost]
        [Route("api/IniciarSesion")]
        public DataTable IniciarSesion(EntidadUsuarios entidad)
        {
            return DatosUsuarios.IniciarSesion(entidad);
        }

        [HttpPost]
        [Route("api/MenuUsuario")]
        public DataTable MenuUsuario(EntidadUsuarios entidad)
        {
            return DatosUsuarios.MenuUsuario(entidad);
        }
    }
}