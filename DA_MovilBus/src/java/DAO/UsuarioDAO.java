package dao;

import config.ConexionBD;
import model.Usuario;
import util.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    /**
     * Valida el inicio de sesion del usuario usando PBKDF2.
     * Busca por username, obtiene el hash almacenado y lo verifica en Java.
     */
    public Usuario validarLogin(String username, String password) {
        String sql = "SELECT u.id_usuario, u.username, u.password, u.nombre, u.apellido, r.nombre_rol, u.estado " +
                     "FROM Usuarios u " +
                     "INNER JOIN Roles r ON u.id_rol = r.id_rol " +
                     "WHERE u.username = ? AND u.estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    if (!PasswordUtil.verificarPassword(password, storedHash)) {
                        return null;
                    }
                    Usuario user = new Usuario();
                    user.setIdUsuario(rs.getInt("id_usuario"));
                    user.setUsername(rs.getString("username"));
                    user.setNombre(rs.getString("nombre"));
                    user.setApellido(rs.getString("apellido"));
                    user.setRol(rs.getString("nombre_rol"));
                    user.setEstado(rs.getString("estado"));
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en el proceso de login: " + e.getMessage());
        }
        return null;
    }

    /**
     * Inserta un nuevo usuario con rol VENDEDOR (id_rol = 2)
     */
    public boolean insertarVendedor(Usuario usuario) {
        String sql = "INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado) VALUES (?, ?, ?, ?, 2, 'ACTIVO')";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getUsername());
            ps.setString(2, PasswordUtil.hashPassword(usuario.getPassword()));
            ps.setString(3, usuario.getNombre());
            ps.setString(4, usuario.getApellido());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al insertar vendedor: " + e.getMessage());
            return false;
        }
    }

    /**
     * Lista todos los usuarios con rol VENDEDOR
     */
    public List<Usuario> listarVendedores() {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT u.id_usuario, u.username, u.nombre, u.apellido, r.nombre_rol, u.estado " +
                     "FROM Usuarios u " +
                     "INNER JOIN Roles r ON u.id_rol = r.id_rol " +
                     "WHERE r.nombre_rol = 'VENDEDOR' " +
                     "ORDER BY u.id_usuario DESC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Usuario u = new Usuario();
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setUsername(rs.getString("username"));
                u.setNombre(rs.getString("nombre"));
                u.setApellido(rs.getString("apellido"));
                u.setRol(rs.getString("nombre_rol"));
                u.setEstado(rs.getString("estado"));
                lista.add(u);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar vendedores: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Actualiza los datos de un vendedor (no cambia password ni username)
     */
    public boolean actualizarVendedor(Usuario usuario) {
        String sql = "UPDATE Usuarios SET nombre = ?, apellido = ?, estado = ? WHERE id_usuario = ? AND id_rol = 2";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getApellido());
            ps.setString(3, usuario.getEstado());
            ps.setInt(4, usuario.getIdUsuario());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar vendedor: " + e.getMessage());
            return false;
        }
    }

    /**
     * Cambia el estado de un vendedor a 'INACTIVO'
     */
    public boolean eliminarVendedor(int idUsuario) {
        String sql = "UPDATE Usuarios SET estado = 'INACTIVO' WHERE id_usuario = ? AND id_rol = 2";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al eliminar vendedor: " + e.getMessage());
            return false;
        }
    }
}
