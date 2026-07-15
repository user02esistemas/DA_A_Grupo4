package dao;

import config.ConexionBD;
import model.Ciudad;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CiudadDAO {

    public List<Ciudad> listarTodas() {
        List<Ciudad> lista = new ArrayList<>();
        String sql = "SELECT id_ciudad, nombre, departamento, estado FROM Ciudades ORDER BY nombre";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error al listar ciudades: " + e.getMessage());
        }
        return lista;
    }

    public List<Ciudad> listarActivas() {
        List<Ciudad> lista = new ArrayList<>();
        String sql = "SELECT id_ciudad, nombre, departamento, estado FROM Ciudades WHERE estado = 'ACTIVO' ORDER BY nombre";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error al listar ciudades activas: " + e.getMessage());
        }
        return lista;
    }

    public Ciudad obtenerPorId(int id) {
        String sql = "SELECT id_ciudad, nombre, departamento, estado FROM Ciudades WHERE id_ciudad = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener ciudad: " + e.getMessage());
        }
        return null;
    }

    public boolean insertar(Ciudad ciudad) {
        String sql = "INSERT INTO Ciudades (nombre, departamento, estado) VALUES (?, ?, ?)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ciudad.getNombre());
            ps.setString(2, ciudad.getDepartamento());
            ps.setString(3, ciudad.getEstado() != null ? ciudad.getEstado() : "ACTIVO");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al insertar ciudad: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar(Ciudad ciudad) {
        String sql = "UPDATE Ciudades SET nombre = ?, departamento = ?, estado = ? WHERE id_ciudad = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ciudad.getNombre());
            ps.setString(2, ciudad.getDepartamento());
            ps.setString(3, ciudad.getEstado());
            ps.setInt(4, ciudad.getIdCiudad());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar ciudad: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarLogico(int idCiudad) {
        String sql = "UPDATE Ciudades SET estado = 'INACTIVO' WHERE id_ciudad = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idCiudad);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al eliminar ciudad: " + e.getMessage());
            return false;
        }
    }

    private Ciudad mapear(ResultSet rs) throws SQLException {
        return new Ciudad(
            rs.getInt("id_ciudad"),
            rs.getString("nombre"),
            rs.getString("departamento"),
            rs.getString("estado")
        );
    }
}
