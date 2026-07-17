package dao;

import config.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotificacionDAO {

    /**
     * Obtiene todas las notificaciones activas para el usuario.
     * Retorna lista de mapas con: id, tipo, mensaje, icono, color, link, timestamp
     */
    public List<Map<String, Object>> obtenerNotificaciones() {
        List<Map<String, Object>> notificaciones = new ArrayList<>();

        // 1. Viajes que salen en las proximas 2 horas
        String sql1 = "SELECT v.id_viaje, v.fecha_hora_salida, "
                + "o.nombre AS origen, d.nombre AS destino, b.placa "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "INNER JOIN Bus b ON v.id_bus = b.id_bus "
                + "WHERE v.estado = 'PROGRAMADO' "
                + "AND v.fecha_hora_salida BETWEEN GETDATE() AND DATEADD(HOUR, 2, GETDATE()) "
                + "ORDER BY v.fecha_hora_salida ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql1);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> n = new HashMap<>();
                n.put("id", "viaje_" + rs.getInt("id_viaje"));
                n.put("tipo", "viaje_proximo");
                n.put("mensaje", "🚌 Viaje " + rs.getString("origen") + " → " + rs.getString("destino")
                        + " sale pronto (" + rs.getTimestamp("fecha_hora_salida") + ")");
                n.put("icono", "bi-bus-front");
                n.put("color", "primary");
                n.put("link", "viajes.jsp");
                n.put("timestamp", rs.getTimestamp("fecha_hora_salida"));
                notificaciones.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error notif viajes proximos: " + e.getMessage());
        }

        // 2. Encomiendas registradas y sin asignar a viaje (pendientes hace >1 dia)
        String sql2 = "SELECT COUNT(*) AS total FROM Encomienda "
                + "WHERE estado = 'REGISTRADO' AND fecha_envio < DATEADD(DAY, -1, GETDATE())";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql2);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("total") > 0) {
                Map<String, Object> n = new HashMap<>();
                n.put("id", "enc_pendientes");
                n.put("tipo", "encomienda_pendiente");
                n.put("mensaje", "📦 " + rs.getInt("total") + " encomienda(s) pendientes de entrega");
                n.put("icono", "bi-box-seam");
                n.put("color", "warning");
                n.put("link", "EncomiendaServlet?accion=listar");
                n.put("timestamp", new Timestamp(System.currentTimeMillis()));
                notificaciones.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error notif encomiendas: " + e.getMessage());
        }

        // 3. Viajes de HOY con baja ocupacion (< 50% o 0 ventas)
        String sql3 = "SELECT v.id_viaje, o.nombre AS origen, d.nombre AS destino, b.capacidad_asientos, "
                + "(SELECT COUNT(*) FROM Pasaje p WHERE p.id_viaje = v.id_viaje AND p.estado = 'ACTIVO') AS ocupados "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "INNER JOIN Bus b ON v.id_bus = b.id_bus "
                + "WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND v.estado = 'PROGRAMADO' "
                + "ORDER BY v.fecha_hora_salida ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql3);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int ocupados = rs.getInt("ocupados");
                int capacidad = rs.getInt("capacidad_asientos");
                double pct = capacidad > 0 ? (double) ocupados / capacidad * 100 : 0;
                if (pct < 50) {
                    Map<String, Object> n = new HashMap<>();
                    n.put("id", "baja_oc_" + rs.getInt("id_viaje"));
                    if (ocupados == 0) {
                        n.put("mensaje", "📉 Viaje " + rs.getString("origen") + " → " + rs.getString("destino")
                                + " sin ventas hoy (0% ocupacion)");
                        n.put("color", "danger");
                    } else {
                        n.put("mensaje", "📉 Viaje " + rs.getString("origen") + " → " + rs.getString("destino")
                                + " con baja ocupacion (" + String.format("%.0f", pct) + "% - " + ocupados + "/" + capacidad + " asientos)");
                        n.put("color", "warning");
                    }
                    n.put("tipo", "baja_ocupacion");
                    n.put("icono", "bi-graph-down-arrow");
                    n.put("link", "ventas.jsp");
                    n.put("timestamp", new Timestamp(System.currentTimeMillis()));
                    notificaciones.add(n);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error notif baja ocupacion: " + e.getMessage());
        }

        // 5. Mantenimientos vencidos (no completados a tiempo)
        String sql5 = "SELECT COUNT(*) AS total FROM Mantenimiento "
                + "WHERE estado IN ('PROGRAMADO', 'EN_PROCESO') "
                + "AND fecha_fin IS NOT NULL AND fecha_fin < GETDATE()";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql5);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("total") > 0) {
                Map<String, Object> n = new HashMap<>();
                n.put("id", "mtto_vencidos");
                n.put("tipo", "mtto_vencido");
                n.put("mensaje", "🔧 " + rs.getInt("total") + " mantenimiento(s) vencido(s) sin completar");
                n.put("icono", "bi-tools");
                n.put("color", "danger");
                n.put("link", "MantenimientoServlet");
                n.put("timestamp", new Timestamp(System.currentTimeMillis()));
                notificaciones.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error notif mtto vencidos: " + e.getMessage());
        }

        // 6. Buses sin mantenimiento en los ultimos 60 dias
        String sql6 = "SELECT COUNT(*) AS total FROM Bus b WHERE b.estado = 'ACTIVO' "
                + "AND DATEDIFF(DAY, ISNULL((SELECT MAX(m.fecha_inicio) FROM Mantenimiento m WHERE m.id_bus = b.id_bus), '1900-01-01'), GETDATE()) > 60";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql6);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("total") > 0) {
                Map<String, Object> n = new HashMap<>();
                n.put("id", "mtto_pendientes");
                n.put("tipo", "mtto_pendiente");
                n.put("mensaje", "🔧 " + rs.getInt("total") + " bus(es) sin mantenimiento en mas de 60 dias");
                n.put("icono", "bi-clock-history");
                n.put("color", "warning");
                n.put("link", "MantenimientoServlet");
                n.put("timestamp", new Timestamp(System.currentTimeMillis()));
                notificaciones.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error notif mtto pendientes: " + e.getMessage());
        }

        // 4. Viajes de hoy sin conductor asignado
        String sql4 = "SELECT v.id_viaje, o.nombre AS origen, d.nombre AS destino "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND v.estado = 'PROGRAMADO' "
                + "AND NOT EXISTS (SELECT 1 FROM Viaje_Conductor vc WHERE vc.id_viaje = v.id_viaje)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql4);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> n = new HashMap<>();
                n.put("id", "sin_cond_" + rs.getInt("id_viaje"));
                n.put("tipo", "sin_conductor");
                n.put("mensaje", "⚠️ Viaje " + rs.getString("origen") + " → " + rs.getString("destino")
                        + " no tiene conductor asignado");
                n.put("icono", "bi-exclamation-triangle");
                n.put("color", "danger");
                n.put("link", "viajes.jsp");
                n.put("timestamp", new Timestamp(System.currentTimeMillis()));
                notificaciones.add(n);
            }
        } catch (SQLException e) {
            System.err.println("Error notif conductores: " + e.getMessage());
        }

        return notificaciones;
    }

    /**
     * Obtiene SOLO el conteo de notificaciones (mas rapido para el badge).
     */
    public int contarNotificaciones() {
        return obtenerNotificaciones().size();
    }
}
