package dao;

import config.ConexionBD;
import model.Mantenimiento;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MantenimientoDAO {

    // ================================================================
    //  CRUD BASICO
    // ================================================================

    public List<Mantenimiento> listarTodos() {
        List<Mantenimiento> lista = new ArrayList<>();
        String sql = "SELECT m.*, b.placa FROM Mantenimiento m "
                + "INNER JOIN Bus b ON m.id_bus = b.id_bus "
                + "ORDER BY m.fecha_inicio DESC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapper(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error listar mantenimientos: " + e.getMessage());
        }
        return lista;
    }

    public Mantenimiento obtenerPorId(int id) {
        String sql = "SELECT m.*, b.placa FROM Mantenimiento m "
                + "INNER JOIN Bus b ON m.id_bus = b.id_bus "
                + "WHERE m.id_mantenimiento = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapper(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error obtener mantenimiento: " + e.getMessage());
        }
        return null;
    }

    public boolean insertar(Mantenimiento m) {
        String sql = "INSERT INTO Mantenimiento (id_bus, tipo_mantenimiento, fecha_inicio, fecha_fin, "
                + "descripcion, kilometraje_actual, costo, estado) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, m.getIdBus());
            ps.setString(2, m.getTipoMantenimiento());
            ps.setTimestamp(3, m.getFechaInicio());
            ps.setTimestamp(4, m.getFechaFin());
            ps.setString(5, m.getDescripcion());
            ps.setInt(6, m.getKilometrajeActual());
            ps.setDouble(7, m.getCosto());
            ps.setString(8, m.getEstado());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error insertar mantenimiento: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizar(Mantenimiento m) {
        String sql = "UPDATE Mantenimiento SET tipo_mantenimiento=?, fecha_inicio=?, fecha_fin=?, "
                + "descripcion=?, kilometraje_actual=?, costo=?, estado=? WHERE id_mantenimiento=?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.getTipoMantenimiento());
            ps.setTimestamp(2, m.getFechaInicio());
            ps.setTimestamp(3, m.getFechaFin());
            ps.setString(4, m.getDescripcion());
            ps.setInt(5, m.getKilometrajeActual());
            ps.setDouble(6, m.getCosto());
            ps.setString(7, m.getEstado());
            ps.setInt(8, m.getIdMantenimiento());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error actualizar mantenimiento: " + e.getMessage());
            return false;
        }
    }

    // ================================================================
    //  CONSULTAS PARA ALERTAS / DASHBOARD
    // ================================================================

    /**
     * Buses que estan actualmente en estado MANTENIMIENTO (con mantenimiento activo sin fecha_fin).
     */
    public List<Map<String, Object>> listarMantenimientosActivos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT m.id_mantenimiento, b.placa, b.marca, b.modelo, m.tipo_mantenimiento, "
                + "m.fecha_inicio, m.descripcion, m.kilometraje_actual "
                + "FROM Mantenimiento m "
                + "INNER JOIN Bus b ON m.id_bus = b.id_bus "
                + "WHERE m.estado IN ('PROGRAMADO', 'EN_PROCESO') "
                + "ORDER BY m.fecha_inicio ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id_mantenimiento"));
                row.put("placa", rs.getString("placa"));
                row.put("marca", rs.getString("marca"));
                row.put("modelo", rs.getString("modelo"));
                row.put("tipo", rs.getString("tipo_mantenimiento"));
                row.put("fechaInicio", rs.getTimestamp("fecha_inicio"));
                row.put("descripcion", rs.getString("descripcion"));
                row.put("kilometraje", rs.getInt("kilometraje_actual"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error listarMantenimientosActivos: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Obtiene mantenimientos que deberian haberse completado pero aun estan abiertos (vencidos).
     */
    public List<Map<String, Object>> listarMantenimientosVencidos() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT m.id_mantenimiento, b.placa, m.tipo_mantenimiento, m.fecha_inicio, m.fecha_fin "
                + "FROM Mantenimiento m INNER JOIN Bus b ON m.id_bus = b.id_bus "
                + "WHERE m.estado IN ('PROGRAMADO', 'EN_PROCESO') "
                + "AND m.fecha_fin IS NOT NULL AND m.fecha_fin < GETDATE() "
                + "ORDER BY m.fecha_fin ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id_mantenimiento"));
                row.put("placa", rs.getString("placa"));
                row.put("tipo", rs.getString("tipo_mantenimiento"));
                row.put("fechaInicio", rs.getTimestamp("fecha_inicio"));
                row.put("fechaFin", rs.getTimestamp("fecha_fin"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error listarMantenimientosVencidos: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Buses que llevan mas de 60 dias sin ningun mantenimiento registrado.
     */
    public List<Map<String, Object>> listarBusesSinMantenimientoReciente() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT sub.id_bus, sub.placa, sub.marca, sub.modelo, sub.ultimo_mantenimiento "
                + "FROM ( "
                + "  SELECT b.id_bus, b.placa, b.marca, b.modelo, "
                + "    ISNULL((SELECT MAX(m.fecha_inicio) FROM Mantenimiento m WHERE m.id_bus = b.id_bus), '1900-01-01') AS ultimo_mantenimiento "
                + "  FROM Bus b WHERE b.estado = 'ACTIVO' "
                + ") AS sub "
                + "WHERE DATEDIFF(DAY, sub.ultimo_mantenimiento, GETDATE()) > 60 "
                + "ORDER BY sub.ultimo_mantenimiento ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("idBus", rs.getInt("id_bus"));
                row.put("placa", rs.getString("placa"));
                row.put("marca", rs.getString("marca"));
                row.put("modelo", rs.getString("modelo"));
                row.put("ultimoMantenimiento", rs.getTimestamp("ultimo_mantenimiento"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error listarBusesSinMantenimiento: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Obtiene el total gastado en mantenimientos este mes.
     */
    public double sumarCostoMensual() {
        String sql = "SELECT ISNULL(SUM(costo), 0) AS total FROM Mantenimiento "
                + "WHERE MONTH(fecha_inicio) = MONTH(GETDATE()) "
                + "AND YEAR(fecha_inicio) = YEAR(GETDATE())";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            System.err.println("Error sumarCostoMensual: " + e.getMessage());
        }
        return 0;
    }

    // ================================================================
    //  MAPPER
    // ================================================================

    private Mantenimiento mapper(ResultSet rs) throws SQLException {
        Mantenimiento m = new Mantenimiento();
        m.setIdMantenimiento(rs.getInt("id_mantenimiento"));
        m.setIdBus(rs.getInt("id_bus"));
        m.setPlacaBus(rs.getString("placa"));
        m.setTipoMantenimiento(rs.getString("tipo_mantenimiento"));
        m.setFechaInicio(rs.getTimestamp("fecha_inicio"));
        m.setFechaFin(rs.getTimestamp("fecha_fin"));
        m.setDescripcion(rs.getString("descripcion"));
        m.setKilometrajeActual(rs.getInt("kilometraje_actual"));
        m.setCosto(rs.getDouble("costo"));
        m.setEstado(rs.getString("estado"));
        m.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        return m;
    }
}
