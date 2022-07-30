using System.Web.Http;
using System.Web.Http.Cors;

namespace ApiRest
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Configuración y servicios de Web API
            var urlPermitidas = new EnableCorsAttribute(origins: "*", headers: "*", methods: "*");
            config.EnableCors(urlPermitidas);

            // Rutas de Web API
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
