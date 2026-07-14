package dao;

import config.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RutaDAO {

    public double obtenerDuracionRuta(int idRuta) {
        String sql = "SELECT duracion_horas FROM Ruta WHERE id_ruta = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idRuta);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("duracion_horas");
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener duración de ruta: " + e.getMessage());
        }
        return 0.0;
    }

    public List<Map<String, Object>> listarRutas() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT r.id_ruta, r.id_origen, r.id_destino, o.nombre AS origen, d.nombre AS destino, " +
                     "r.duracion_horas, r.precio_base, r.estado " +
                     "FROM Ruta r " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "ORDER BY o.nombre, d.nombre";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapearRuta(rs));
        } catch (SQLException e) {
            System.err.println("Error al listar rutas: " + e.getMessage());
        }
        return lista;
    }

    public List<Map<String, Object>> listarRutasActivas() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT r.id_ruta, r.id_origen, r.id_destino, o.nombre AS origen, d.nombre AS destino, " +
                     "r.duracion_horas, r.precio_base, r.estado " +
                     "FROM Ruta r " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "WHERE r.estado = 'ACTIVO' ORDER BY o.nombre, d.nombre";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapearRuta(rs));
        } catch (SQLException e) {
            System.err.println("Error al listar rutas activas: " + e.getMessage());
        }
        return lista;
    }

    public List<Map<String, Object>> listarCiudades() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT id_ciudad, nombre, departamento FROM Ciudades WHERE estado = 'ACTIVO' ORDER BY nombre";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> ciudad = new HashMap<>();
                ciudad.put("idCiudad", rs.getInt("id_ciudad"));
                ciudad.put("nombre", rs.getString("nombre"));
                ciudad.put("departamento", rs.getString("departamento"));
                lista.add(ciudad);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar ciudades: " + e.getMessage());
        }
        return lista;
    }

    public boolean insertar(int idOrigen, int idDestino, double duracion, double precioBase) {
        String sql = "INSERT INTO Ruta (id_origen, id_destino, duracion_horas, precio_base, estado) VALUES (?, ?, ?, ?, 'ACTIVO')";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idOrigen);
            ps.setInt(2, idDestino);
            ps.setDouble(3, duracion);
            ps.setDouble(4, precioBase);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al insertar ruta: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar(int idRuta, int idOrigen, int idDestino, double duracion, double precioBase, String estado) {
        String sql = "UPDATE Ruta SET id_origen=?, id_destino=?, duracion_horas=?, precio_base=?, estado=? WHERE id_ruta=?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idOrigen);
            ps.setInt(2, idDestino);
            ps.setDouble(3, duracion);
            ps.setDouble(4, precioBase);
            ps.setString(5, estado);
            ps.setInt(6, idRuta);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar ruta: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarLogico(int idRuta) {
        String sql = "UPDATE Ruta SET estado = 'INACTIVO' WHERE id_ruta = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idRuta);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al eliminar ruta: " + e.getMessage());
            return false;
        }
    }

    private Map<String, Object> mapearRuta(ResultSet rs) throws SQLException {
        Map<String, Object> ruta = new HashMap<>();
        ruta.put("idRuta", rs.getInt("id_ruta"));
        ruta.put("idOrigen", rs.getInt("id_origen"));
        ruta.put("idDestino", rs.getInt("id_destino"));
        ruta.put("origen", rs.getString("origen"));
        ruta.put("destino", rs.getString("destino"));
        ruta.put("duracionHoras", rs.getDouble("duracion_horas"));
        ruta.put("precioBase", rs.getDouble("precio_base"));
        ruta.put("estado", rs.getString("estado"));
        return ruta;
    }
}
