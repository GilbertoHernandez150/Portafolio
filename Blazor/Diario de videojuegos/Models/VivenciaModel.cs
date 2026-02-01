// Models/VivenciaModel.cs
namespace DiarioVideojuegos.Models
{
    public class VivenciaModel
    {
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
        public string Imagen { get; set; } = string.Empty;
    }
}