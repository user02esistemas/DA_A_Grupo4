package dao;

import config.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DashboardDAO {

    /**
     * Obtiene el total de viajes programados para hoy.
     */
    public int contarViajesHoy() {
        String sql = "SELECT COUNT(*) AS total FROM Viaje "
                + "WHERE CAST(fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND estado IN ('PROGRAMADO', 'EN_RUTA')";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarViajesHoy: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de pasajes vendidos hoy.
     */
    public int contarPasajesHoy() {
        String sql = "SELECT COUNT(*) AS total FROM Pasaje "
                + "WHERE CAST(fecha_emision AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarPasajesHoy: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de ingresos (pagos) registrados hoy.
     */
    public double sumarIngresosHoy() {
        String sql = "SELECT ISNULL(SUM(monto_total), 0) AS total FROM Pago "
                + "WHERE CAST(fecha_pago AS DATE) = CAST(GETDATE() AS DATE)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (SQLException e) {
            System.err.println("Error sumarIngresosHoy: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de encomiendas pendientes (REGISTRADO o EN VIAJE).
     */
    public int contarEncomiendasPendientes() {
        String sql = "SELECT COUNT(*) AS total FROM Encomienda "
                + "WHERE estado IN ('REGISTRADO', 'EN VIAJE')";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarEncomiendasPendientes: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de conductores disponibles (no asignados).
     */
    public int contarConductoresDisponibles() {
        String sql = "SELECT COUNT(*) AS total FROM Conductores WHERE estado = 'DISPONIBLE'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarConductoresDisponibles: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el porcentaje de ocupacion promedio de los viajes de hoy.
     * Calcula asientos vendidos / capacidad total del bus.
     */
    public double calcularOcupacionPromedio() {
        String sql = "SELECT AVG(CAST(ocupados AS FLOAT) / CAST(capacidad AS FLOAT) * 100) AS promedio "
                + "FROM ( "
                + "  SELECT v.id_viaje, b.capacidad_asientos AS capacidad, "
                + "    (SELECT COUNT(*) FROM Pasaje p WHERE p.id_viaje = v.id_viaje AND p.estado = 'ACTIVO') AS ocupados "
                + "  FROM Viaje v "
                + "  INNER JOIN Bus b ON v.id_bus = b.id_bus "
                + "  WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "  AND v.estado IN ('PROGRAMADO', 'EN_RUTA') "
                + ") AS sub";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                double prom = rs.getDouble("promedio");
                return rs.wasNull() ? 0 : Math.round(prom * 10.0) / 10.0;
            }
        } catch (SQLException e) {
            System.err.println("Error calcularOcupacionPromedio: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Lista los viajes del dia (proximas salidas) con datos de ocupacion.
     */
    public List<Map<String, Object>> listarViajesDelDia() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, v.estado, "
                + "o.nombre AS origen, d.nombre AS destino, "
                + "b.placa, b.capacidad_asientos, s.nombre_servicio, "
                + "(SELECT COUNT(*) FROM Pasaje p WHERE p.id_viaje = v.id_viaje AND p.estado = 'ACTIVO') AS asientos_ocupados "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "INNER JOIN Bus b ON v.id_bus = b.id_bus "
                + "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio "
                + "WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND v.estado IN ('PROGRAMADO', 'EN_RUTA') "
                + "ORDER BY v.fecha_hora_salida ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> viaje = new HashMap<>();
                viaje.put("idViaje", rs.getInt("id_viaje"));
                viaje.put("fechaHora", rs.getTimestamp("fecha_hora_salida"));
                viaje.put("fechaLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                viaje.put("estado", rs.getString("estado"));
                viaje.put("origen", rs.getString("origen"));
                viaje.put("destino", rs.getString("destino"));
                viaje.put("placa", rs.getString("placa"));
                viaje.put("capacidad", rs.getInt("capacidad_asientos"));
                viaje.put("servicio", rs.getString("nombre_servicio"));
                viaje.put("ocupados", rs.getInt("asientos_ocupados"));
                lista.add(viaje);
            }
        } catch (SQLException e) {
            System.err.println("Error listarViajesDelDia: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Obtiene los ingresos de los ultimos 30 dias para el grafico.
     * Devuelve una lista de mapas con fecha y total.
     */
    public List<Map<String, Object>> obtenerIngresosUltimos30Dias() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT CAST(fecha_pago AS DATE) AS fecha, ISNULL(SUM(monto_total), 0) AS total "
                + "FROM Pago "
                + "WHERE fecha_pago >= DATEADD(DAY, -30, GETDATE()) "
                + "GROUP BY CAST(fecha_pago AS DATE) "
                + "ORDER BY fecha ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("fecha", rs.getDate("fecha"));
                row.put("total", rs.getDouble("total"));
                lista.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error obtenerIngresosUltimos30Dias: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Obtiene el total de viajes del mes actual (para comparativa).
     */
    public int contarViajesDelMes() {
        String sql = "SELECT COUNT(*) AS total FROM Viaje "
                + "WHERE MONTH(fecha_hora_salida) = MONTH(GETDATE()) "
                + "AND YEAR(fecha_hora_salida) = YEAR(GETDATE())";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarViajesDelMes: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de pasajeros transportados en el mes (suma de asientos vendidos).
     */
    public int contarPasajerosDelMes() {
        String sql = "SELECT COUNT(*) AS total FROM Pasaje p "
                + "INNER JOIN Viaje v ON p.id_viaje = v.id_viaje "
                + "WHERE MONTH(v.fecha_hora_salida) = MONTH(GETDATE()) "
                + "AND YEAR(v.fecha_hora_salida) = YEAR(GETDATE()) "
                + "AND p.estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarPasajerosDelMes: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene el total de buses activos en la flota.
     */
    public int contarBusesActivos() {
        String sql = "SELECT COUNT(*) AS total FROM Bus WHERE estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("total");
        } catch (SQLException e) {
            System.err.println("Error contarBusesActivos: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Obtiene alertas operativas del sistema.
     * Retorna lista de mapas con tipo, mensaje, severidad.
     */
    public List<Map<String, String>> obtenerAlertas() {
        List<Map<String, String>> alertas = new ArrayList<>();

        // 1. Viajes de hoy sin conductores asignados
        String sql1 = "SELECT v.id_viaje, o.nombre AS origen, d.nombre AS destino "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND v.estado = 'PROGRAMADO' "
                + "AND NOT EXISTS (SELECT 1 FROM Viaje_Conductor vc WHERE vc.id_viaje = v.id_viaje)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql1);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                alertas.add(Map.of(
                    "tipo", "warning",
                    "icono", "bi-exclamation-triangle",
                    "mensaje", "Viaje " + rs.getString("origen") + " → " + rs.getString("destino") + " sin conductor asignado",
                    "severidad", "Alta"
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error alerta conductores: " + e.getMessage());
        }

        // 2. Encomiendas pendientes hace mas de 3 dias
        String sql2 = "SELECT COUNT(*) AS total FROM Encomienda "
                + "WHERE estado = 'REGISTRADO' AND fecha_envio < DATEADD(DAY, -3, GETDATE())";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql2);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("total") > 0) {
                alertas.add(Map.of(
                    "tipo", "danger",
                    "icono", "bi-box-seam",
                    "mensaje", rs.getInt("total") + " encomienda(s) sin procesar desde hace mas de 3 dias",
                    "severidad", "Urgente"
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error alerta encomiendas: " + e.getMessage());
        }

        // 3. Conductores disponibles vs necesarios
        String sql3 = "SELECT (SELECT COUNT(*) FROM Conductores WHERE estado = 'DISPONIBLE') AS disponibles, "
                + "(SELECT COUNT(*) FROM Viaje WHERE CAST(fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) AND estado = 'PROGRAMADO') AS viajes_hoy";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql3);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int disp = rs.getInt("disponibles");
                int viajes = rs.getInt("viajes_hoy");
                if (disp < viajes) {
                    alertas.add(Map.of(
                        "tipo", "warning",
                        "icono", "bi-people",
                        "mensaje", "Faltan " + (viajes - disp) + " conductor(es) para cubrir los viajes de hoy",
                        "severidad", "Media"
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error alerta conductores disp: " + e.getMessage());
        }

        // 4. Buses en mantenimiento
        String sql4 = "SELECT COUNT(*) AS total FROM Bus WHERE estado = 'INACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql4);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt("total") > 0) {
                alertas.add(Map.of(
                    "tipo", "info",
                    "icono", "bi-truck",
                    "mensaje", rs.getInt("total") + " bus(es) se encuentran inactivos",
                    "severidad", "Baja"
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error alerta buses: " + e.getMessage());
        }

        // 5. Ocupacion baja en viajes de hoy
        String sql5 = "SELECT v.id_viaje, o.nombre AS origen, d.nombre AS destino, "
                + "(SELECT COUNT(*) FROM Pasaje p WHERE p.id_viaje = v.id_viaje AND p.estado = 'ACTIVO') AS ocupados, "
                + "b.capacidad_asientos "
                + "FROM Viaje v "
                + "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta "
                + "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad "
                + "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad "
                + "INNER JOIN Bus b ON v.id_bus = b.id_bus "
                + "WHERE CAST(v.fecha_hora_salida AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND v.estado = 'PROGRAMADO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql5);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int ocupados = rs.getInt("ocupados");
                int capacidad = rs.getInt("capacidad_asientos");
                double pct = capacidad > 0 ? (double) ocupados / capacidad * 100 : 0;
                if (ocupados == 0) {
                    alertas.add(Map.of(
                        "tipo", "warning",
                        "icono", "bi-graph-down-arrow",
                        "mensaje", "Viaje " + rs.getString("origen") + " → " + rs.getString("destino") + " sin ventas (0% ocupacion)",
                        "severidad", "Media"
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error alerta ocupacion: " + e.getMessage());
        }

        if (alertas.isEmpty()) {
            alertas.add(Map.of(
                "tipo", "success",
                "icono", "bi-check-circle",
                "mensaje", "No hay alertas pendientes. Todo esta en orden.",
                "severidad", "OK"
            ));
        }

        return alertas;
    }
}
