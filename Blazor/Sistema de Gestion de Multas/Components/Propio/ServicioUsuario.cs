using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class UsuarioService
{
    private readonly MultasDbContext _context;
    private readonly IPasswordHasher<Usuario> _passwordHasher;

    // Constructor con inyección de dependencias
    public UsuarioService(MultasDbContext context, IPasswordHasher<Usuario> passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    // Obtener todos los usuarios
    public async Task<List<Usuario>> ObtenerUsuariosAsync()
    {
        return await _context.Usuarios.ToListAsync();
    }

    // Obtener un usuario por su ID
    public async Task<Usuario> ObtenerUsuarioPorIdAsync(int id)
    {
        return await _context.Usuarios.FirstOrDefaultAsync(u => u.Id == id);
    }

    // Crear un nuevo usuario
    public async Task CrearUsuarioAsync(Usuario usuario)
    {
        // Asegúrate de cifrar la contraseña antes de guardarla
        usuario.Clave = _passwordHasher.HashPassword(usuario, usuario.Clave);

        // Guardar el usuario en la base de datos
        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();
    }

    // Editar un usuario
    public async Task EditarUsuarioAsync(Usuario usuario)
    {
        var usuarioExistente = await _context.Usuarios.FindAsync(usuario.Id);
        if (usuarioExistente != null)
        {
            usuarioExistente.Nombre = usuario.Nombre;
            usuarioExistente.Cedula = usuario.Cedula;
            usuarioExistente.Rol = usuario.Rol;
            usuarioExistente.Activo = usuario.Activo;

            // Solo actualizar la contraseña si no está vacía
            if (!string.IsNullOrEmpty(usuario.Clave)) 
            {
                usuarioExistente.Clave = _passwordHasher.HashPassword(usuarioExistente, usuario.Clave);
            }

            await _context.SaveChangesAsync();
        }
    }       

    // Activar un usuario
    public async Task ActivarUsuarioAsync(int id)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario != null)
        {
            usuario.Activo = true;
            await _context.SaveChangesAsync();
        }
    }

    // Desactivar un usuario
    public async Task DesactivarUsuarioAsync(int id)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario != null)
        {
            usuario.Activo = false;
            await _context.SaveChangesAsync();
        }
    }
}
