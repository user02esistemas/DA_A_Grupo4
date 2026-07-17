package dao;

import config.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReporteDAO {

    /**
     * Lista ventas filtradas por rango de fechas, vendedor y ruta.
     */
    public List<Map<String, Object>> reporteVentas(String fechaDesde, String fechaHasta,
                                                     Integer idVendedor, Integer idRuta) {
        List<Map<String, Object>> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.id_pasaje, p.fecha_emision, p.precio_pagado, p.estado AS estado_pasaje, ");
        sql.append("c.dni AS dni_cliente, c.nombre AS nombre_cliente, c.apellido AS apellido_cliente, ");
        sql.append("v.id_viaje, v.fecha_hora_salida, ");
        sql.append("o.nombre AS origen, d.nombre AS destino, ");
        sql.append("b.placa, s.nombre_servicio, ");
        sql.append("ba.numero_asiento, ba.piso, ta.descripcion AS tipo_asiento, ");
        sql.append("pg.monto_total, pg.metodo_pago, pg.fecha_pago, ");
        sql.append("u.username AS vendedor, r.id_ruta ");
        sql.append("FROM Pasaje p ");
        sql.append("INNER JOIN Viaje v ON p.id_viaje = v.id_viaje ");
        sql.append("INNER JOIN Ruta r ON v.id_ruta = r.id_ruta ");
        sql.append("INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad ");
        sql.append("INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad ");
        sql.append("INNER JOIN Bus b ON v.id_bus = b.id_bus ");
        sql.append("INNER JOIN Servicio s ON b.id_servicio = s.id_servicio ");
        sql.append("INNER JOIN Cliente c ON p.id_cliente = c.id_cliente ");
        sql.append("INNER JOIN Bus_Asiento ba ON p.id_bus_asiento = ba.id_bus_asiento ");
        sql.append("INNER JOIN Tipo_Asiento ta ON ba.id_tipo_asiento = ta.id_tipo_asiento ");
        sql.append("LEFT JOIN Pago pg ON p.id_pasaje = pg.id_pasaje ");
        sql.append("LEFT JOIN Usuarios u ON pg.id_vendedor = u.id_usuario ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (fechaDesde != null && !fechaDesde.isEmpty()) {
            sql.append("AND CAST(p.fecha_emision AS DATE) >= ? ");
            params.add(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.isEmpty()) {
            sql.append("AND CAST(p.fecha_emision AS DATE) <= ? ");
            params.add(fechaHasta);
        }
        if (idVendedor != null && idVendedor > 0) {
            sql.append("AND u.id_usuario = ? ");
            params.add(idVendedor);
        }
        if (idRuta != null && idRuta > 0) {
            sql.append("AND r.id_ruta = ? ");
            params.add(idRuta);
        }

        sql.append("ORDER BY p.fecha_emision DESC");

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    ps.setInt(i + 1, (Integer) params.get(i));
                } else {
                    ps.setString(i + 1, (String) params.get(i));
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> venta = new HashMap<>();
                    venta.put("idPasaje", rs.getInt("id_pasaje"));
                    venta.put("fechaEmision", rs.getTimestamp("fecha_emision"));
                    venta.put("precioPagado", rs.getDouble("precio_pagado"));
                    venta.put("estadoPasaje", rs.getString("estado_pasaje"));
                    venta.put("dniCliente", rs.getString("dni_cliente"));
                    venta.put("nombreCliente", rs.getString("nombre_cliente") + " " + rs.getString("apellido_cliente"));
                    venta.put("idViaje", rs.getInt("id_viaje"));
                    venta.put("fechaHoraSalida", rs.getTimestamp("fecha_hora_salida"));
                    venta.put("origen", rs.getString("origen"));
                    venta.put("destino", rs.getString("destino"));
                    venta.put("placa", rs.getString("placa"));
                    venta.put("nombreServicio", rs.getString("nombre_servicio"));
                    venta.put("numeroAsiento", rs.getInt("numero_asiento"));
                    venta.put("piso", rs.getInt("piso"));
                    venta.put("tipoAsiento", rs.getString("tipo_asiento"));
                    venta.put("montoTotal", rs.getDouble("monto_total"));
                    venta.put("metodoPago", rs.getString("metodo_pago"));
                    venta.put("fechaPago", rs.getTimestamp("fecha_pago"));
                    venta.put("vendedor", rs.getString("vendedor"));
                    venta.put("idRuta", rs.getInt("id_ruta"));
                    lista.add(venta);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error reporteVentas: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista viajes filtrados por rango de fechas, ruta y estado.
     */
    public List<Map<String, Object>> reporteViajes(String fechaDesde, String fechaHasta,
                                                    Integer idRuta, String estado) {
        List<Map<String, Object>> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, v.estado, ");
        sql.append("o.nombre AS origen, d.nombre AS destino, ");
        sql.append("b.placa, b.marca, s.nombre_servicio, b.capacidad_asientos, ");
        sql.append("(SELECT COUNT(*) FROM Pasaje p WHERE p.id_viaje = v.id_viaje AND p.estado = 'ACTIVO') AS asientos_ocupados ");
        sql.append("FROM Viaje v ");
        sql.append("INNER JOIN Ruta r ON v.id_ruta = r.id_ruta ");
        sql.append("INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad ");
        sql.append("INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad ");
        sql.append("INNER JOIN Bus b ON v.id_bus = b.id_bus ");
        sql.append("INNER JOIN Servicio s ON b.id_servicio = s.id_servicio ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (fechaDesde != null && !fechaDesde.isEmpty()) {
            sql.append("AND CAST(v.fecha_hora_salida AS DATE) >= ? ");
            params.add(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.isEmpty()) {
            sql.append("AND CAST(v.fecha_hora_salida AS DATE) <= ? ");
            params.add(fechaHasta);
        }
        if (idRuta != null && idRuta > 0) {
            sql.append("AND r.id_ruta = ? ");
            params.add(idRuta);
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append("AND v.estado = ? ");
            params.add(estado);
        }

        sql.append("ORDER BY v.fecha_hora_salida DESC");

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                if (params.get(i) instanceof Integer) {
                    ps.setInt(i + 1, (Integer) params.get(i));
                } else {
                    ps.setString(i + 1, (String) params.get(i));
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> viaje = new HashMap<>();
                    viaje.put("idViaje", rs.getInt("id_viaje"));
                    viaje.put("fechaHoraSalida", rs.getTimestamp("fecha_hora_salida"));
                    viaje.put("fechaLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                    viaje.put("estado", rs.getString("estado"));
                    viaje.put("origen", rs.getString("origen"));
                    viaje.put("destino", rs.getString("destino"));
                    viaje.put("placa", rs.getString("placa"));
                    viaje.put("marca", rs.getString("marca"));
                    viaje.put("servicio", rs.getString("nombre_servicio"));
                    viaje.put("capacidad", rs.getInt("capacidad_asientos"));
                    viaje.put("ocupados", rs.getInt("asientos_ocupados"));
                    lista.add(viaje);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error reporteViajes: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista encomiendas filtradas por rango de fechas y estado.
     */
    public List<Map<String, Object>> reporteEncomiendas(String fechaDesde, String fechaHasta, String estado) {
        List<Map<String, Object>> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT e.id_encomienda, e.descripcion_contenido, e.peso_kg, e.precio_envio, ");
        sql.append("e.estado, e.fecha_envio, e.fecha_entrega_real, ");
        sql.append("o.nombre AS origen, d.nombre AS destino, b.placa, ");
        sql.append("rem.dni AS dni_remitente, rem.nombre + ' ' + rem.apellido AS nombre_remitente, ");
        sql.append("dest.dni AS dni_destinatario, dest.nombre + ' ' + dest.apellido AS nombre_destinatario, ");
        sql.append("pg.monto_total, pg.metodo_pago, u.username AS vendedor ");
        sql.append("FROM Encomienda e ");
        sql.append("INNER JOIN Viaje v ON e.id_viaje = v.id_viaje ");
        sql.append("INNER JOIN Ruta r ON v.id_ruta = r.id_ruta ");
        sql.append("INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad ");
        sql.append("INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad ");
        sql.append("INNER JOIN Bus b ON v.id_bus = b.id_bus ");
        sql.append("INNER JOIN Cliente rem ON e.id_remitente = rem.id_cliente ");
        sql.append("INNER JOIN Cliente dest ON e.id_destinatario = dest.id_cliente ");
        sql.append("LEFT JOIN Pago pg ON e.id_encomienda = pg.id_encomienda ");
        sql.append("LEFT JOIN Usuarios u ON pg.id_vendedor = u.id_usuario ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (fechaDesde != null && !fechaDesde.isEmpty()) {
            sql.append("AND CAST(e.fecha_envio AS DATE) >= ? ");
            params.add(fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.isEmpty()) {
            sql.append("AND CAST(e.fecha_envio AS DATE) <= ? ");
            params.add(fechaHasta);
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append("AND e.estado = ? ");
            params.add(estado);
        }

        sql.append("ORDER BY e.fecha_envio DESC");

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, (String) p);
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> enc = new HashMap<>();
                    enc.put("idEncomienda", rs.getInt("id_encomienda"));
                    enc.put("descripcion", rs.getString("descripcion_contenido"));
                    enc.put("pesoKg", rs.getDouble("peso_kg"));
                    enc.put("precioEnvio", rs.getDouble("precio_envio"));
                    enc.put("estado", rs.getString("estado"));
                    enc.put("fechaEnvio", rs.getTimestamp("fecha_envio"));
                    enc.put("fechaEntrega", rs.getTimestamp("fecha_entrega_real"));
                    enc.put("origen", rs.getString("origen"));
                    enc.put("destino", rs.getString("destino"));
                    enc.put("placa", rs.getString("placa"));
                    enc.put("dniRemitente", rs.getString("dni_remitente"));
                    enc.put("nombreRemitente", rs.getString("nombre_remitente"));
                    enc.put("dniDestinatario", rs.getString("dni_destinatario"));
                    enc.put("nombreDestinatario", rs.getString("nombre_destinatario"));
                    enc.put("montoTotal", rs.getDouble("monto_total"));
                    enc.put("metodoPago", rs.getString("metodo_pago"));
                    enc.put("vendedor", rs.getString("vendedor"));
                    lista.add(enc);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error reporteEncomiendas: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Obtiene total de ingresos del reporte filtrado (para el resumen).
     */
    public double totalIngresosReporte(String fechaDesde, String fechaHasta, Integer idVendedor, Integer idRuta) {
        List<Map<String, Object>> datos = reporteVentas(fechaDesde, fechaHasta, idVendedor, idRuta);
        return datos.stream()
                .mapToDouble(v -> (Double) v.getOrDefault("precioPagado", 0.0))
                .sum();
    }

    public int totalPasajesReporte(String fechaDesde, String fechaHasta, Integer idVendedor, Integer idRuta) {
        List<Map<String, Object>> datos = reporteVentas(fechaDesde, fechaHasta, idVendedor, idRuta);
        return datos.size();
    }
}
