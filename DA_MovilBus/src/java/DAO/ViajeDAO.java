package dao;

import config.ConexionBD;
import model.Asiento;
import model.Viaje;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ViajeDAO {

    public boolean programarViajeConTripulacion(Viaje viaje, List<Integer> idConductores) {
        String sqlViaje = "INSERT INTO Viaje (id_ruta, id_bus, fecha_hora_salida, fecha_hora_llegada_estimada, estado) VALUES (?, ?, ?, ?, ?)";
        String sqlTripulacion = "INSERT INTO Viaje_Conductor (id_viaje, id_conductor, rol_tripulacion) VALUES (?, ?, ?)";
        String sqlUpdateConductor = "UPDATE Conductores SET estado = 'ASIGNADO' WHERE id_conductor = ?";

        Connection con = null;
        PreparedStatement psViaje = null;
        PreparedStatement psTrip = null;
        PreparedStatement psUpd = null;
        ResultSet rs = null;

        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            psViaje = con.prepareStatement(sqlViaje, Statement.RETURN_GENERATED_KEYS);
            psViaje.setInt(1, viaje.getIdRuta());
            psViaje.setInt(2, viaje.getIdBus());
            psViaje.setTimestamp(3, viaje.getFechaHora());
            psViaje.setTimestamp(4, viaje.getFechaHoraLlegadaEstimada());
            psViaje.setString(5, viaje.getEstado());

            int filas = psViaje.executeUpdate();
            int idViajeGenerado = 0;

            if (filas > 0) {
                rs = psViaje.getGeneratedKeys();
                if (rs.next()) idViajeGenerado = rs.getInt(1);
            }

            if (idViajeGenerado > 0 && idConductores != null && !idConductores.isEmpty()) {
                psTrip = con.prepareStatement(sqlTripulacion);
                psUpd = con.prepareStatement(sqlUpdateConductor);

                for (int i = 0; i < idConductores.size(); i++) {
                    int idCond = idConductores.get(i);
                    String rol = (i == 0) ? "PILOTO PRINCIPAL" : "PILOTO DE RELEVO";

                    psTrip.setInt(1, idViajeGenerado);
                    psTrip.setInt(2, idCond);
                    psTrip.setString(3, rol);
                    psTrip.addBatch();

                    psUpd.setInt(1, idCond);
                    psUpd.addBatch();
                }

                psTrip.executeBatch();
                psUpd.executeBatch();
            } else {
                throw new SQLException("No se pudo generar el ID del viaje o no se enviaron conductores.");
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("Error en la transacción de viaje: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (psViaje != null) psViaje.close(); } catch (SQLException e) {}
            try { if (psTrip != null) psTrip.close(); } catch (SQLException e) {}
            try { if (psUpd != null) psUpd.close(); } catch (SQLException e) {}
        }
    }

    public boolean actualizarEstado(int idViaje, String estado) {
        String sql = "UPDATE Viaje SET estado = ? WHERE id_viaje = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, idViaje);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar viaje: " + e.getMessage());
            return false;
        }
    }

    public boolean cancelarViaje(int idViaje) {
        Connection con = null;
        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            String sqlLiberar = "UPDATE c SET c.estado = 'DISPONIBLE' FROM Conductores c " +
                                "INNER JOIN Viaje_Conductor vc ON c.id_conductor = vc.id_conductor " +
                                "WHERE vc.id_viaje = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlLiberar)) {
                ps.setInt(1, idViaje);
                ps.executeUpdate();
            }

            String sqlViaje = "UPDATE Viaje SET estado = 'CANCELADO' WHERE id_viaje = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlViaje)) {
                ps.setInt(1, idViaje);
                ps.executeUpdate();
            }

            con.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("Error al cancelar viaje: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        }
    }

    /**
     * Finaliza automaticamente los viajes PROGRAMADO cuya fecha de salida ya paso.
     * Se ejecuta internamente antes de cada listado programado.
     */
    public void finalizarViajesPasados() {
        String sql = "UPDATE Viaje SET estado = 'FINALIZADO' " +
                     "WHERE estado = 'PROGRAMADO' AND fecha_hora_salida < GETDATE()";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int actualizados = ps.executeUpdate();
            if (actualizados > 0) {
                System.out.println("[Auto] " + actualizados + " viaje(s) finalizados automaticamente.");
            }
        } catch (SQLException e) {
            System.err.println("Error al finalizar viajes pasados: " + e.getMessage());
        }
    }

    public List<Map<String, Object>> listarViajesProgramados() {
        // Auto-finalizar viajes que ya pasaron
        finalizarViajesPasados();
        
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT v.id_viaje, (o.nombre + ' - ' + d.nombre) AS nombre_ruta, " +
                     "v.fecha_hora_salida, v.fecha_hora_llegada_estimada, b.placa, v.estado " +
                     "FROM Viaje v " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "WHERE v.estado NOT IN ('FINALIZADO', 'CANCELADO') " +
                     "ORDER BY v.fecha_hora_salida ASC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> viaje = new HashMap<>();
                viaje.put("idViaje", rs.getInt("id_viaje"));
                viaje.put("nombreRuta", rs.getString("nombre_ruta"));
                viaje.put("fechaHora", rs.getTimestamp("fecha_hora_salida"));
                viaje.put("fechaHoraLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                viaje.put("placaBus", rs.getString("placa"));
                viaje.put("estado", rs.getString("estado"));
                lista.add(viaje);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar viajes: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista TODOS los viajes (incluyendo FINALIZADO y CANCELADO) para el historial completo.
     */
    public List<Map<String, Object>> listarTodosLosViajes() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT v.id_viaje, (o.nombre + ' - ' + d.nombre) AS nombre_ruta, " +
                     "v.fecha_hora_salida, v.fecha_hora_llegada_estimada, b.placa, v.estado " +
                     "FROM Viaje v " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "ORDER BY v.fecha_hora_salida DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> viaje = new HashMap<>();
                viaje.put("idViaje", rs.getInt("id_viaje"));
                viaje.put("nombreRuta", rs.getString("nombre_ruta"));
                viaje.put("fechaHora", rs.getTimestamp("fecha_hora_salida"));
                viaje.put("fechaHoraLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                viaje.put("placaBus", rs.getString("placa"));
                viaje.put("estado", rs.getString("estado"));
                lista.add(viaje);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar todos los viajes: " + e.getMessage());
        }
        return lista;
    }

    public List<Map<String, Object>> buscarViajesParaVenta(int idOrigen, int idDestino, String fecha) {
        // Auto-finalizar viajes que ya pasaron antes de buscar
        finalizarViajesPasados();
        
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, " +
                     "o.nombre AS origen, d.nombre AS destino, b.placa, b.marca, b.capacidad_asientos, " +
                     "b.cantidad_pisos, r.precio_base, s.nombre_servicio " +
                     "FROM Viaje v " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio " +
                     "WHERE r.id_origen = ? AND r.id_destino = ? " +
                     "AND CAST(v.fecha_hora_salida AS DATE) = ? " +
                     "AND v.estado = 'PROGRAMADO' " +
                     "AND v.fecha_hora_salida >= GETDATE()";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idOrigen);
            ps.setInt(2, idDestino);
            ps.setString(3, fecha);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> v = new HashMap<>();
                    v.put("idViaje", rs.getInt("id_viaje"));
                    v.put("fechaHora", rs.getTimestamp("fecha_hora_salida"));
                    v.put("fechaHoraLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                    v.put("origen", rs.getString("origen"));
                    v.put("destino", rs.getString("destino"));
                    v.put("placa", rs.getString("placa"));
                    v.put("marca", rs.getString("marca"));
                    v.put("precioBase", rs.getDouble("precio_base"));
                    v.put("nombreServicio", rs.getString("nombre_servicio"));
                    v.put("capacidadAsientos", rs.getInt("capacidad_asientos"));
                    v.put("cantidadPisos", rs.getInt("cantidad_pisos"));
                    lista.add(v);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al buscar viajes para venta: " + e.getMessage());
        }
        return lista;
    }

    public Map<String, Object> obtenerInfoViaje(int idViaje) {
        String sql = "SELECT v.id_viaje, b.capacidad_asientos, b.cantidad_pisos, s.nombre_servicio, r.precio_base " +
                     "FROM Viaje v " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "WHERE v.id_viaje = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idViaje);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> info = new HashMap<>();
                    info.put("idViaje", rs.getInt("id_viaje"));
                    info.put("capacidadAsientos", rs.getInt("capacidad_asientos"));
                    info.put("cantidadPisos", rs.getInt("cantidad_pisos"));
                    info.put("nombreServicio", rs.getString("nombre_servicio"));
                    info.put("precioBase", rs.getDouble("precio_base"));
                    return info;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener info viaje: " + e.getMessage());
        }
        return null;
    }

    public int obtenerCapacidadBusPorViaje(int idViaje) {
        String sql = "SELECT b.capacidad_asientos FROM Viaje v " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus WHERE v.id_viaje = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idViaje);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("capacidad_asientos");
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener capacidad del bus: " + e.getMessage());
        }
        return 40;
    }

    public List<Integer> obtenerAsientosOcupados(int idViaje) {
        List<Integer> asientos = new ArrayList<>();
        String sql = "SELECT ba.numero_asiento FROM Pasaje p " +
                     "INNER JOIN Bus_Asiento ba ON p.id_bus_asiento = ba.id_bus_asiento " +
                     "WHERE p.id_viaje = ? AND p.estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idViaje);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) asientos.add(rs.getInt("numero_asiento"));
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener asientos ocupados: " + e.getMessage());
        }
        return asientos;
    }

    /** Lee asientos desde Bus_Asiento y calcula precio: base + tipo + recargo ubicación */
    public List<Asiento> generarCroquisDesdeBD(int idViaje) {
        List<Asiento> lista = new ArrayList<>();
        List<Integer> ocupados = obtenerAsientosOcupados(idViaje);

        String sql = "SELECT ba.id_bus_asiento, ba.id_bus, ba.numero_asiento, ba.piso, ba.fila, ba.columna, " +
                     "ba.posicion, ba.recargo_ubicacion, ta.descripcion AS tipo_asiento, ta.precio_adicional, r.precio_base " +
                     "FROM Bus_Asiento ba " +
                     "INNER JOIN Viaje v ON v.id_bus = ba.id_bus " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Tipo_Asiento ta ON ba.id_tipo_asiento = ta.id_tipo_asiento " +
                     "WHERE v.id_viaje = ? " +
                     "ORDER BY ba.piso, ba.fila, ba.columna";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idViaje);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double precio = rs.getDouble("precio_base")
                                  + rs.getDouble("precio_adicional")
                                  + rs.getDouble("recargo_ubicacion");
                    int numero = rs.getInt("numero_asiento");

                    Asiento a = new Asiento(
                        rs.getInt("id_bus_asiento"),
                        rs.getInt("id_bus"),
                        numero,
                        rs.getInt("piso"),
                        rs.getInt("fila"),
                        rs.getInt("columna"),
                        rs.getString("posicion"),
                        rs.getString("tipo_asiento"),
                        precio,
                        rs.getDouble("recargo_ubicacion"),
                        ocupados.contains(numero)
                    );
                    lista.add(a);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al generar croquis desde BD: " + e.getMessage());
        }
        return lista;
    }

    public List<Asiento> generarCroquisDinamico(int idViaje) {
        return generarCroquisDesdeBD(idViaje);
    }

    /**
     * Lista todas las ventas (pasajes emitidos) con detalles completos
     * para el historial de ventas. Incluye datos del pasajero, viaje, bus, asiento y pago.
     */
    /**
     * Obtiene los detalles completos de UNA venta específica por su ID.
     * Se usa en la pantalla de confirmación post-compra.
     */
    public Map<String, Object> obtenerVentaPorId(int idPasaje) {
        String sql = "SELECT p.id_pasaje, p.fecha_emision, p.precio_pagado, p.estado AS estado_pasaje, " +
                     "c.dni AS dni_cliente, c.nombre AS nombre_cliente, c.apellido AS apellido_cliente, " +
                     "v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, " +
                     "o.nombre AS origen, d.nombre AS destino, " +
                     "b.placa, b.marca, b.modelo, s.nombre_servicio, " +
                     "ba.numero_asiento, ba.piso, ta.descripcion AS tipo_asiento, r.precio_base " +
                     "FROM Pasaje p " +
                     "INNER JOIN Viaje v ON p.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio " +
                     "INNER JOIN Cliente c ON p.id_cliente = c.id_cliente " +
                     "INNER JOIN Bus_Asiento ba ON p.id_bus_asiento = ba.id_bus_asiento " +
                     "INNER JOIN Tipo_Asiento ta ON ba.id_tipo_asiento = ta.id_tipo_asiento " +
                     "WHERE p.id_pasaje = ?";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPasaje);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> venta = new HashMap<>();
                    venta.put("idPasaje", rs.getInt("id_pasaje"));
                    venta.put("fechaEmision", rs.getTimestamp("fecha_emision"));
                    venta.put("precioPagado", rs.getDouble("precio_pagado"));
                    venta.put("estadoPasaje", rs.getString("estado_pasaje"));
                    venta.put("dniCliente", rs.getString("dni_cliente"));
                    venta.put("nombreCliente", rs.getString("nombre_cliente"));
                    venta.put("apellidoCliente", rs.getString("apellido_cliente"));
                    venta.put("idViaje", rs.getInt("id_viaje"));
                    venta.put("fechaHoraSalida", rs.getTimestamp("fecha_hora_salida"));
                    venta.put("fechaHoraLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                    venta.put("origen", rs.getString("origen"));
                    venta.put("destino", rs.getString("destino"));
                    venta.put("placa", rs.getString("placa"));
                    venta.put("marca", rs.getString("marca"));
                    venta.put("modelo", rs.getString("modelo"));
                    venta.put("nombreServicio", rs.getString("nombre_servicio"));
                    venta.put("numeroAsiento", rs.getInt("numero_asiento"));
                    venta.put("piso", rs.getInt("piso"));
                    venta.put("tipoAsiento", rs.getString("tipo_asiento"));
                    venta.put("precioBase", rs.getDouble("precio_base"));
                    return venta;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener venta por ID: " + e.getMessage());
        }
        return null;
    }

    /**
     * Obtiene los detalles de MULTIPLES ventas por sus IDs.
     * Se usa en la pantalla de confirmación post-compra multi-asiento.
     */
    public List<Map<String, Object>> obtenerVentasPorIds(String idsConcatenados) {
        List<Map<String, Object>> lista = new ArrayList<>();
        if (idsConcatenados == null || idsConcatenados.trim().isEmpty()) return lista;
        
        // Validar que solo contenga dígitos y comas (seguridad anti-SQL injection)
        if (!idsConcatenados.matches("\\d+(,\\d+)*")) {
            System.err.println("IDs de pasajes inválidos: " + idsConcatenados);
            return lista;
        }

        String sql = "SELECT p.id_pasaje, p.fecha_emision, p.precio_pagado, p.estado AS estado_pasaje, " +
                     "c.dni AS dni_cliente, c.nombre AS nombre_cliente, c.apellido AS apellido_cliente, " +
                     "v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, " +
                     "o.nombre AS origen, d.nombre AS destino, " +
                     "b.placa, b.marca, b.modelo, s.nombre_servicio, " +
                     "ba.numero_asiento, ba.piso, ta.descripcion AS tipo_asiento, r.precio_base " +
                     "FROM Pasaje p " +
                     "INNER JOIN Viaje v ON p.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio " +
                     "INNER JOIN Cliente c ON p.id_cliente = c.id_cliente " +
                     "INNER JOIN Bus_Asiento ba ON p.id_bus_asiento = ba.id_bus_asiento " +
                     "INNER JOIN Tipo_Asiento ta ON ba.id_tipo_asiento = ta.id_tipo_asiento " +
                     "WHERE p.id_pasaje IN (" + idsConcatenados + ") " +
                     "ORDER BY p.id_pasaje ASC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> venta = new HashMap<>();
                venta.put("idPasaje", rs.getInt("id_pasaje"));
                venta.put("fechaEmision", rs.getTimestamp("fecha_emision"));
                venta.put("precioPagado", rs.getDouble("precio_pagado"));
                venta.put("estadoPasaje", rs.getString("estado_pasaje"));
                venta.put("dniCliente", rs.getString("dni_cliente"));
                venta.put("nombreCliente", rs.getString("nombre_cliente"));
                venta.put("apellidoCliente", rs.getString("apellido_cliente"));
                venta.put("idViaje", rs.getInt("id_viaje"));
                venta.put("fechaHoraSalida", rs.getTimestamp("fecha_hora_salida"));
                venta.put("fechaHoraLlegada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                venta.put("origen", rs.getString("origen"));
                venta.put("destino", rs.getString("destino"));
                venta.put("placa", rs.getString("placa"));
                venta.put("marca", rs.getString("marca"));
                venta.put("modelo", rs.getString("modelo"));
                venta.put("nombreServicio", rs.getString("nombre_servicio"));
                venta.put("numeroAsiento", rs.getInt("numero_asiento"));
                venta.put("piso", rs.getInt("piso"));
                venta.put("tipoAsiento", rs.getString("tipo_asiento"));
                venta.put("precioBase", rs.getDouble("precio_base"));
                lista.add(venta);
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener ventas por IDs: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Lista TODAS las ventas (acceso solo para ADMINISTRADOR).
     */
    public List<Map<String, Object>> listarVentas() {
        return ejecutarListadoVentas("", null);
    }

    /**
     * Lista ventas realizadas por un VENDEDOR específico.
     */
    public List<Map<String, Object>> listarVentasPorVendedor(int idUsuario) {
        String whereExtra = "AND pg.id_vendedor = ?";
        return ejecutarListadoVentas(whereExtra, ps -> ps.setInt(1, idUsuario));
    }

    /**
     * Lista ventas compradas por un CLIENTE (filtra por DNI del cliente asociado al usuario).
     * El username del cliente es su DNI, que coincide con Cliente.dni.
     */
    public List<Map<String, Object>> listarVentasPorCliente(String dniCliente) {
        String whereExtra = "AND c.dni = ?";
        return ejecutarListadoVentas(whereExtra, ps -> ps.setString(1, dniCliente));
    }

    /**
     * Anula un pasaje (cambia su estado a ANULADO).
     * Solo ADMINISTRADOR y VENDEDOR pueden ejecutar esta acción.
     * @return true si se anuló correctamente
     */
    public boolean anularPasaje(int idPasaje) {
        String sql = "UPDATE Pasaje SET estado = 'ANULADO' WHERE id_pasaje = ? AND estado = 'ACTIVO'";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPasaje);
            int filas = ps.executeUpdate();
            return filas > 0;
        } catch (SQLException e) {
            System.err.println("Error al anular pasaje: " + e.getMessage());
            return false;
        }
    }

    /**
     * Registra un pago en la tabla Pago.
     * Para ventas de admin/vendedor, se asigna el id del vendedor.
     * Para compras de cliente web, id_vendedor se deja NULL.
     */
    public boolean registrarPago(int idPasaje, double monto, String metodoPago, Integer idVendedor) {
        String sql = "INSERT INTO Pago (monto_total, metodo_pago, id_pasaje, id_vendedor) VALUES (?, ?, ?, ?)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, monto);
            ps.setString(2, metodoPago);
            ps.setInt(3, idPasaje);
            if (idVendedor != null) {
                ps.setInt(4, idVendedor);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al registrar pago: " + e.getMessage());
            return false;
        }
    }

    /**
     * Método interno reutilizable para ejecutar consultas de listado de ventas
     * con filtros adicionales.
     */
    @FunctionalInterface
    private interface ParamSetter {
        void set(PreparedStatement ps) throws SQLException;
    }

    private List<Map<String, Object>> ejecutarListadoVentas(String whereExtra, ParamSetter paramSetter) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT p.id_pasaje, p.fecha_emision, p.precio_pagado, p.estado AS estado_pasaje, " +
                     "c.dni AS dni_cliente, c.nombre AS nombre_cliente, c.apellido AS apellido_cliente, " +
                     "v.id_viaje, v.fecha_hora_salida, " +
                     "o.nombre AS origen, d.nombre AS destino, " +
                     "b.placa, s.nombre_servicio, " +
                     "ba.numero_asiento, ba.piso, ta.descripcion AS tipo_asiento, " +
                     "pg.monto_total, pg.metodo_pago, pg.fecha_pago, pg.numero_operacion, " +
                     "u.username AS vendedor " +
                     "FROM Pasaje p " +
                     "INNER JOIN Viaje v ON p.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Servicio s ON b.id_servicio = s.id_servicio " +
                     "INNER JOIN Cliente c ON p.id_cliente = c.id_cliente " +
                     "INNER JOIN Bus_Asiento ba ON p.id_bus_asiento = ba.id_bus_asiento " +
                     "INNER JOIN Tipo_Asiento ta ON ba.id_tipo_asiento = ta.id_tipo_asiento " +
                     "LEFT JOIN Pago pg ON p.id_pasaje = pg.id_pasaje " +
                     "LEFT JOIN Usuarios u ON pg.id_vendedor = u.id_usuario " +
                     "WHERE 1=1 " + whereExtra + " " +
                     "ORDER BY p.fecha_emision DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (paramSetter != null) paramSetter.set(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> venta = new HashMap<>();
                    venta.put("idPasaje", rs.getInt("id_pasaje"));
                    venta.put("fechaEmision", rs.getTimestamp("fecha_emision"));
                    venta.put("precioPagado", rs.getDouble("precio_pagado"));
                    venta.put("estadoPasaje", rs.getString("estado_pasaje"));
                    venta.put("dniCliente", rs.getString("dni_cliente"));
                    venta.put("nombreCliente", rs.getString("nombre_cliente"));
                    venta.put("apellidoCliente", rs.getString("apellido_cliente"));
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
                    venta.put("numeroOperacion", rs.getString("numero_operacion"));
                    venta.put("vendedor", rs.getString("vendedor"));
                    lista.add(venta);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al listar ventas: " + e.getMessage());
        }
        return lista;
    }
}
