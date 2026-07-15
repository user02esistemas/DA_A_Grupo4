package dao;

import config.ConexionBD;
import model.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
public class UsuarioDAO {
    /**
     * Valida el inicio de sesión del usuario contra la base de datos
     */
    public Usuario validarLogin(String username, String password) {
        // Cambiar "FROM Usuario" por "FROM Usuarios"
        String sql = "SELECT u.id_usuario, u.username, u.nombre, u.apellido, r.nombre_rol, u.estado " +
                     "FROM Usuarios u " +
                     "INNER JOIN Roles r ON u.id_rol = r.id_rol " +
                     "WHERE u.username = ? AND u.password = ? AND u.estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario user = new Usuario();
                    user.setIdUsuario(rs.getInt("id_usuario"));
                    user.setUsername(rs.getString("username"));
                    user.setNombre(rs.getString("nombre"));
                    user.setApellido(rs.getString("apellido"));
                    user.setRol(rs.getString("nombre_rol"));
                    user.setEstado(rs.getString("estado"));
                    return user; // Retorna el usuario completo con su rol asignado
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en el proceso de login: " + e.getMessage());
        }
        return null; // Si las credenciales no coinciden o está inactivo, retorna vacío
    }
}
