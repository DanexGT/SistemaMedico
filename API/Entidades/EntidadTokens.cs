using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entidades
{
    public class EntidadTokens
    {
        public int Resultado { get; set; }
        public int IdToken { get; set; }
        public string Token { get; set; }
        public int VigenciaEnMinutos { get; set; }
        public int IdUsuario { get; set; }
        public string FechaIngreso { get; set; }
        public int Estado { get; set; }
        public int IdModulo { get; set; }
    }
}
