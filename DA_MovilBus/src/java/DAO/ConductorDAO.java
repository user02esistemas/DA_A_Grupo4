package dao;

import config.ConexionBD;
import model.Conductor;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ConductorDAO {

    public List<Conductor> listarConductoresDisponibles() {
        List<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, dni, nombre, apellido, nro_licencia, estado FROM Conductores WHERE estado = 'DISPONIBLE'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) {
            System.err.println("Error al listar conductores disponibles: " + e.getMessage());
        }
        return lista;
    }

    public List<Conductor> listarConductores() {
        List<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, dni, nombre, apellido, nro_licencia, estado FROM Conductores ORDER BY apellido, nombre";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) {
            System.err.println("Error al listar conductores: " + e.getMessage());
        }
        return lista;
    }

    public Conductor obtenerPorId(int id) {
        String sql = "SELECT id_conductor, dni, nombre, apellido, nro_licencia, estado FROM Conductores WHERE id_conductor = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener conductor: " + e.getMessage());
        }
        return null;
    }

    public boolean insertar(Conductor c) {
        String sql = "INSERT INTO Conductores (dni, nombre, apellido, nro_licencia, estado) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getDni());
            ps.setString(2, c.getNombre());
            ps.setString(3, c.getApellido());
            ps.setString(4, c.getNroLicencia());
            ps.setString(5, c.getEstado() != null ? c.getEstado() : "DISPONIBLE");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al insertar conductor: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar(Conductor c) {
        String sql = "UPDATE Conductores SET dni=?, nombre=?, apellido=?, nro_licencia=?, estado=? WHERE id_conductor=?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getDni());
            ps.setString(2, c.getNombre());
            ps.setString(3, c.getApellido());
            ps.setString(4, c.getNroLicencia());
            ps.setString(5, c.getEstado());
            ps.setInt(6, c.getIdConductor());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar conductor: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarLogico(int idConductor) {
        String sql = "UPDATE Conductores SET estado = 'INACTIVO' WHERE id_conductor = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idConductor);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al eliminar conductor: " + e.getMessage());
            return false;
        }
    }

    private Conductor mapear(ResultSet rs) throws SQLException {
        return new Conductor(
            rs.getInt("id_conductor"),
            rs.getString("dni"),
            rs.getString("nombre"),
            rs.getString("apellido"),
            rs.getString("nro_licencia"),
            rs.getString("estado")
        );
    }
}
