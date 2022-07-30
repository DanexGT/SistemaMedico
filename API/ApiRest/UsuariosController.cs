using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
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
    }
}