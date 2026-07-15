package dao;

import config.ConexionBD;
import model.Cliente;
import model.Usuario;
import java.sql.*;

public class ClienteDAO {

    public boolean registrarClienteConUsuario(Cliente cliente, Usuario usuario) {
        String sqlUsuario = "INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado) VALUES (?, ?, ?, ?, 3, 'ACTIVO')";
        String sqlCliente = "INSERT INTO Cliente (dni, nombre, apellido, telefono, email, fecha_registro, id_usuario) VALUES (?, ?, ?, ?, ?, GETDATE(), ?)";
        
        Connection con = null;
        PreparedStatement psUser = null;
        PreparedStatement psClient = null;
        ResultSet rs = null;

        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false); // Iniciamos transacción

            // 1. Insertar el Usuario
            psUser = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, usuario.getUsername());
            psUser.setString(2, usuario.getPassword()); // Considera usar hashing en producción
            psUser.setString(3, usuario.getNombre());
            psUser.setString(4, usuario.getApellido());

            int filasUsuario = psUser.executeUpdate();
            int idUsuarioGenerado = 0;

            if (filasUsuario > 0) {
                rs = psUser.getGeneratedKeys();
                if (rs.next()) {
                    idUsuarioGenerado = rs.getInt(1);
                }
            }

            // 2. Insertar el Cliente vinculándolo al idUsuario generado
            if (idUsuarioGenerado > 0) {
                psClient = con.prepareStatement(sqlCliente);
                psClient.setString(1, cliente.getDni());
                psClient.setString(2, cliente.getNombre());
                psClient.setString(3, cliente.getApellido());
                psClient.setString(4, cliente.getTelefono());
                psClient.setString(5, cliente.getEmail());
                psClient.setInt(6, idUsuarioGenerado);

                psClient.executeUpdate();
            } else {
                throw new SQLException("No se pudo generar el ID de usuario.");
            }

            con.commit(); // Confirmar transacción
            return true;

        } catch (SQLException e) {
            System.err.println("Error en transacción de ClienteDAO: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (psUser != null) psUser.close(); } catch (SQLException e) {}
            try { if (psClient != null) psClient.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}