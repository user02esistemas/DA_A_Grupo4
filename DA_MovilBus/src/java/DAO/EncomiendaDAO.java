package dao;

import config.ConexionBD;
import model.Encomienda;
import model.EncomiendaEstado;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.security.SecureRandom;

public class EncomiendaDAO {

    private static final String CODIGO_PREFIX = "MOV-";
    private static final int CODIGO_RANDOM_LENGTH = 8;
    private static final String CODIGO_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Genera un codigo de seguimiento unico de 8 caracteres alfanumericos.
     */
    public String generarCodigoSeguimiento() {
        int intentos = 0;
        while (intentos < 10) {
            StringBuilder sb = new StringBuilder(CODIGO_PREFIX);
            for (int i = 0; i < CODIGO_RANDOM_LENGTH; i++) {
                sb.append(CODIGO_CHARS.charAt(RANDOM.nextInt(CODIGO_CHARS.length())));
            }
            String codigo = sb.toString();
            if (!existeCodigoSeguimiento(codigo)) {
                return codigo;
            }
            intentos++;
        }
        return CODIGO_PREFIX + System.currentTimeMillis();
    }

    private boolean existeCodigoSeguimiento(String codigo) {
        String sql = "SELECT COUNT(1) FROM Encomienda WHERE codigo_seguimiento = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, codigo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error al verificar codigo: " + e.getMessage());
            return false;
        }
    }

    /**
     * Registra una nueva encomienda junto con su pago en una transaccion.
     * Genera automaticamente un codigo de seguimiento unico.
     */
    public boolean registrarEncomienda(Encomienda encomienda,
                                       String dniRemitente, String nombreRemitente,
                                       String dniDest, String nombreDest,
                                       Integer idVendedor, String metodoPago) {
        String sqlEncomienda = "INSERT INTO Encomienda (descripcion_contenido, peso_kg, precio_envio, " +
                               "estado, fecha_envio, id_viaje, id_remitente, id_destinatario, codigo_seguimiento) " +
                               "OUTPUT INSERTED.id_encomienda " +
                               "VALUES (?, ?, ?, 'REGISTRADO', GETDATE(), ?, ?, ?, ?)";

        Connection con = null;
        PreparedStatement psEnc = null;
        PreparedStatement psPago = null;
        ResultSet rs = null;

        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            // 1. Crear o recuperar remitente
            int idRemitente = buscarOCrearCliente(con, dniRemitente, nombreRemitente);
            // 2. Crear o recuperar destinatario
            int idDestinatario = buscarOCrearCliente(con, dniDest, nombreDest);

            // 3. Generar codigo de seguimiento unico
            String codigoSeguimiento = generarCodigoSeguimiento();
            encomienda.setCodigoSeguimiento(codigoSeguimiento);

            // 4. Insertar encomienda
            psEnc = con.prepareStatement(sqlEncomienda);
            psEnc.setString(1, encomienda.getDescripcionContenido());
            psEnc.setDouble(2, encomienda.getPesoKg());
            psEnc.setDouble(3, encomienda.getPrecioEnvio());
            psEnc.setInt(4, encomienda.getIdViaje());
            psEnc.setInt(5, idRemitente);
            psEnc.setInt(6, idDestinatario);
            psEnc.setString(7, codigoSeguimiento);

            int idEncomiendaGenerado = 0;
            rs = psEnc.executeQuery();
            if (rs.next()) {
                idEncomiendaGenerado = rs.getInt(1);
            }

            if (idEncomiendaGenerado == 0) {
                throw new SQLException("No se pudo generar el ID de la encomienda.");
            }

            // 5. Registrar estado inicial en historial
            registrarEstadoHistorico(con, idEncomiendaGenerado, null, "REGISTRADO", 
                idVendedor != null ? "Vendedor" : "Cliente Web", 
                "Encomienda registrada con codigo " + codigoSeguimiento);

            // 6. Insertar pago asociado (Pago.id_pasaje puede ser NULL, usamos id_encomienda)
            String sqlPago = "INSERT INTO Pago (monto_total, metodo_pago, id_encomienda, id_vendedor) " +
                             "VALUES (?, ?, ?, ?)";
            psPago = con.prepareStatement(sqlPago);
            psPago.setDouble(1, encomienda.getPrecioEnvio());
            psPago.setString(2, metodoPago != null ? metodoPago : "EFECTIVO");
            psPago.setInt(3, idEncomiendaGenerado);
            if (idVendedor != null) {
                psPago.setInt(4, idVendedor);
            } else {
                psPago.setNull(4, java.sql.Types.INTEGER);
            }
            psPago.executeUpdate();

            con.commit();
            System.out.println("[OK] Encomienda #" + idEncomiendaGenerado + " registrada - Codigo: " + codigoSeguimiento);
            return true;

        } catch (SQLException e) {
            System.err.println("Error en transacción de EncomiendaDAO: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { System.err.println("Rollback fallo: " + ex.getMessage()); }
            }
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (psEnc != null) psEnc.close(); } catch (SQLException e) {}
            try { if (psPago != null) psPago.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }

    /**
     * Lista todas las encomiendas registradas con datos completos.
     */
    public List<Map<String, Object>> listarEncomiendas() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT e.id_encomienda, e.codigo_seguimiento, e.descripcion_contenido, e.peso_kg, e.precio_envio, " +
                     "e.estado, e.fecha_envio, e.fecha_entrega_real, " +
                     "v.id_viaje, v.fecha_hora_salida, " +
                     "o.nombre AS origen, d.nombre AS destino, b.placa, " +
                     "rem.dni AS dni_remitente, rem.nombre AS nombre_remitente, rem.apellido AS apellido_remitente, " +
                     "dest.dni AS dni_destinatario, dest.nombre AS nombre_destinatario, dest.apellido AS apellido_destinatario, " +
                     "pg.monto_total, pg.metodo_pago, u.username AS vendedor " +
                     "FROM Encomienda e " +
                     "INNER JOIN Viaje v ON e.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Cliente rem ON e.id_remitente = rem.id_cliente " +
                     "INNER JOIN Cliente dest ON e.id_destinatario = dest.id_cliente " +
                     "LEFT JOIN Pago pg ON e.id_encomienda = pg.id_encomienda " +
                     "LEFT JOIN Usuarios u ON pg.id_vendedor = u.id_usuario " +
                     "ORDER BY e.fecha_envio DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> enc = new HashMap<>();
                enc.put("idEncomienda", rs.getInt("id_encomienda"));
                enc.put("codigoSeguimiento", rs.getString("codigo_seguimiento"));
                enc.put("descripcion", rs.getString("descripcion_contenido"));
                enc.put("pesoKg", rs.getDouble("peso_kg"));
                enc.put("precioEnvio", rs.getDouble("precio_envio"));
                enc.put("estado", rs.getString("estado"));
                enc.put("fechaEnvio", rs.getTimestamp("fecha_envio"));
                enc.put("fechaEntrega", rs.getTimestamp("fecha_entrega_real"));
                enc.put("idViaje", rs.getInt("id_viaje"));
                enc.put("fechaSalida", rs.getTimestamp("fecha_hora_salida"));
                enc.put("origen", rs.getString("origen"));
                enc.put("destino", rs.getString("destino"));
                enc.put("placa", rs.getString("placa"));
                enc.put("dniRemitente", rs.getString("dni_remitente"));
                enc.put("nombreRemitente", rs.getString("nombre_remitente") + " " + rs.getString("apellido_remitente"));
                enc.put("dniDestinatario", rs.getString("dni_destinatario"));
                enc.put("nombreDestinatario", rs.getString("nombre_destinatario") + " " + rs.getString("apellido_destinatario"));
                enc.put("montoPago", rs.getDouble("monto_total"));
                enc.put("metodoPago", rs.getString("metodo_pago"));
                enc.put("vendedor", rs.getString("vendedor"));
                lista.add(enc);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar encomiendas: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Busca una encomienda por su codigo de seguimiento unico (para tracking publico).
     * Retorna null si no se encuentra.
     */
    public Map<String, Object> obtenerEncomiendaPorCodigo(String codigo) {
        String sql = "SELECT e.id_encomienda, e.codigo_seguimiento, e.descripcion_contenido, " +
                     "e.peso_kg, e.precio_envio, e.estado, e.fecha_envio, e.fecha_entrega_real, " +
                     "v.id_viaje, v.fecha_hora_salida, v.fecha_hora_llegada_estimada, " +
                     "o.nombre AS origen, d.nombre AS destino, b.placa, b.marca, " +
                     "rem.dni AS dni_remitente, rem.nombre AS nombre_remitente, rem.apellido AS apellido_remitente, " +
                     "dest.dni AS dni_destinatario, dest.nombre AS nombre_destinatario, dest.apellido AS apellido_destinatario, " +
                     "pg.monto_total, pg.metodo_pago " +
                     "FROM Encomienda e " +
                     "INNER JOIN Viaje v ON e.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Cliente rem ON e.id_remitente = rem.id_cliente " +
                     "INNER JOIN Cliente dest ON e.id_destinatario = dest.id_cliente " +
                     "LEFT JOIN Pago pg ON e.id_encomienda = pg.id_encomienda " +
                     "WHERE e.codigo_seguimiento = ?";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, codigo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> enc = new HashMap<>();
                    enc.put("idEncomienda", rs.getInt("id_encomienda"));
                    enc.put("codigoSeguimiento", rs.getString("codigo_seguimiento"));
                    enc.put("descripcion", rs.getString("descripcion_contenido"));
                    enc.put("pesoKg", rs.getDouble("peso_kg"));
                    enc.put("precioEnvio", rs.getDouble("precio_envio"));
                    enc.put("estado", rs.getString("estado"));
                    enc.put("fechaEnvio", rs.getTimestamp("fecha_envio"));
                    enc.put("fechaEntrega", rs.getTimestamp("fecha_entrega_real"));
                    enc.put("idViaje", rs.getInt("id_viaje"));
                    enc.put("fechaSalida", rs.getTimestamp("fecha_hora_salida"));
                    enc.put("fechaLlegadaEstimada", rs.getTimestamp("fecha_hora_llegada_estimada"));
                    enc.put("origen", rs.getString("origen"));
                    enc.put("destino", rs.getString("destino"));
                    enc.put("placa", rs.getString("placa"));
                    enc.put("marca", rs.getString("marca"));
                    enc.put("dniRemitente", rs.getString("dni_remitente"));
                    enc.put("nombreRemitente", rs.getString("nombre_remitente") + " " + rs.getString("apellido_remitente"));
                    enc.put("dniDestinatario", rs.getString("dni_destinatario"));
                    enc.put("nombreDestinatario", rs.getString("nombre_destinatario") + " " + rs.getString("apellido_destinatario"));
                    enc.put("montoPago", rs.getDouble("monto_total"));
                    enc.put("metodoPago", rs.getString("metodo_pago"));
                    return enc;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener encomienda por codigo: " + e.getMessage());
        }
        return null;
    }

    /**
     * Obtiene el historial completo de cambios de estado de una encomienda.
     */
    public List<Map<String, Object>> obtenerHistorialEstados(int idEncomienda) {
        List<Map<String, Object>> historial = new ArrayList<>();
        String sql = "SELECT ee.id_estado, ee.estado_anterior, ee.estado_nuevo, " +
                     "ee.fecha_cambio, ee.usuario_cambio, ee.observacion " +
                     "FROM Encomienda_Estado ee " +
                     "WHERE ee.id_encomienda = ? " +
                     "ORDER BY ee.fecha_cambio ASC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idEncomienda);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> ev = new HashMap<>();
                    ev.put("idEstado", rs.getInt("id_estado"));
                    ev.put("estadoAnterior", rs.getString("estado_anterior"));
                    ev.put("estadoNuevo", rs.getString("estado_nuevo"));
                    ev.put("fechaCambio", rs.getTimestamp("fecha_cambio"));
                    ev.put("usuarioCambio", rs.getString("usuario_cambio"));
                    ev.put("observacion", rs.getString("observacion"));
                    historial.add(ev);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener historial de estados: " + e.getMessage());
        }
        return historial;
    }

    /**
     * Inserta un registro en el historial de estados.
     */
    private void registrarEstadoHistorico(Connection con, int idEncomienda, String estadoAnterior, 
                                           String estadoNuevo, String usuario, String observacion) throws SQLException {
        String sql = "INSERT INTO Encomienda_Estado (id_encomienda, estado_anterior, estado_nuevo, " +
                     "fecha_cambio, usuario_cambio, observacion) VALUES (?, ?, ?, GETDATE(), ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idEncomienda);
            if (estadoAnterior != null) {
                ps.setString(2, estadoAnterior);
            } else {
                ps.setNull(2, java.sql.Types.VARCHAR);
            }
            ps.setString(3, estadoNuevo);
            if (usuario != null) {
                ps.setString(4, usuario);
            } else {
                ps.setNull(4, java.sql.Types.VARCHAR);
            }
            if (observacion != null) {
                ps.setString(5, observacion);
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
            }
            ps.executeUpdate();
        }
    }

    /**
     * Lista encomiendas donde el DNI del remitente o destinatario coincide.
     * Útil para que un cliente vea sus envíos.
     */
    public List<Map<String, Object>> listarEncomiendasPorCliente(String dniCliente) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT e.id_encomienda, e.codigo_seguimiento, e.descripcion_contenido, e.peso_kg, e.precio_envio, " +
                     "e.estado, e.fecha_envio, e.fecha_entrega_real, " +
                     "v.id_viaje, v.fecha_hora_salida, " +
                     "o.nombre AS origen, d.nombre AS destino, b.placa, " +
                     "rem.dni AS dni_remitente, rem.nombre AS nombre_remitente, rem.apellido AS apellido_remitente, " +
                     "dest.dni AS dni_destinatario, dest.nombre AS nombre_destinatario, dest.apellido AS apellido_destinatario, " +
                     "pg.monto_total, pg.metodo_pago, u.username AS vendedor " +
                     "FROM Encomienda e " +
                     "INNER JOIN Viaje v ON e.id_viaje = v.id_viaje " +
                     "INNER JOIN Ruta r ON v.id_ruta = r.id_ruta " +
                     "INNER JOIN Ciudades o ON r.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON r.id_destino = d.id_ciudad " +
                     "INNER JOIN Bus b ON v.id_bus = b.id_bus " +
                     "INNER JOIN Cliente rem ON e.id_remitente = rem.id_cliente " +
                     "INNER JOIN Cliente dest ON e.id_destinatario = dest.id_cliente " +
                     "LEFT JOIN Pago pg ON e.id_encomienda = pg.id_encomienda " +
                     "LEFT JOIN Usuarios u ON pg.id_vendedor = u.id_usuario " +
                     "WHERE rem.dni = ? OR dest.dni = ? " +
                     "ORDER BY e.fecha_envio DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dniCliente);
            ps.setString(2, dniCliente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> enc = new HashMap<>();
                    enc.put("idEncomienda", rs.getInt("id_encomienda"));
                    enc.put("codigoSeguimiento", rs.getString("codigo_seguimiento"));
                    enc.put("descripcion", rs.getString("descripcion_contenido"));
                    enc.put("pesoKg", rs.getDouble("peso_kg"));
                    enc.put("precioEnvio", rs.getDouble("precio_envio"));
                    enc.put("estado", rs.getString("estado"));
                    enc.put("fechaEnvio", rs.getTimestamp("fecha_envio"));
                    enc.put("fechaEntrega", rs.getTimestamp("fecha_entrega_real"));
                    enc.put("idViaje", rs.getInt("id_viaje"));
                    enc.put("fechaSalida", rs.getTimestamp("fecha_hora_salida"));
                    enc.put("origen", rs.getString("origen"));
                    enc.put("destino", rs.getString("destino"));
                    enc.put("placa", rs.getString("placa"));
                    enc.put("dniRemitente", rs.getString("dni_remitente"));
                    enc.put("nombreRemitente", rs.getString("nombre_remitente") + " " + rs.getString("apellido_remitente"));
                    enc.put("dniDestinatario", rs.getString("dni_destinatario"));
                    enc.put("nombreDestinatario", rs.getString("nombre_destinatario") + " " + rs.getString("apellido_destinatario"));
                    enc.put("montoPago", rs.getDouble("monto_total"));
                    enc.put("metodoPago", rs.getString("metodo_pago"));
                    enc.put("vendedor", rs.getString("vendedor"));
                    lista.add(enc);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al listar encomiendas por cliente: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Actualiza el estado de una encomienda y registra el cambio en el historial.
     */
    public boolean actualizarEstado(int idEncomienda, String nuevoEstado) {
        Connection con = null;
        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            // Obtener estado actual antes del cambio
            String sqlEstadoActual = "SELECT estado FROM Encomienda WHERE id_encomienda = ?";
            String estadoAnterior = null;
            try (PreparedStatement ps = con.prepareStatement(sqlEstadoActual)) {
                ps.setInt(1, idEncomienda);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        estadoAnterior = rs.getString("estado");
                    }
                }
            }

            if (estadoAnterior == null) {
                return false;
            }

            // Actualizar estado
            String sqlUpdate;
            if ("ENTREGADO".equalsIgnoreCase(nuevoEstado)) {
                sqlUpdate = "UPDATE Encomienda SET estado = ?, fecha_entrega_real = GETDATE() WHERE id_encomienda = ?";
            } else {
                sqlUpdate = "UPDATE Encomienda SET estado = ? WHERE id_encomienda = ?";
            }

            try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                ps.setString(1, nuevoEstado);
                ps.setInt(2, idEncomienda);
                int actualizados = ps.executeUpdate();
                if (actualizados == 0) {
                    con.rollback();
                    return false;
                }
            }

            // Registrar en historial
            String observacion = "Estado cambiado de " + (estadoAnterior != null ? estadoAnterior : "ninguno") 
                                 + " a " + nuevoEstado;
            if ("ENTREGADO".equalsIgnoreCase(nuevoEstado)) {
                observacion = "Paquete entregado al destinatario";
            } else if ("ANULADO".equalsIgnoreCase(nuevoEstado)) {
                observacion = "Encomienda anulada";
            }
            registrarEstadoHistorico(con, idEncomienda, estadoAnterior, nuevoEstado, "Sistema", observacion);

            con.commit();
            System.out.println("[OK] Encomienda #" + idEncomienda + " estado: " + estadoAnterior + " -> " + nuevoEstado);
            return true;

        } catch (SQLException e) {
            System.err.println("Error al actualizar estado encomienda: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) {}
            }
        }
    }

    /**
     * Busca un cliente por DNI o lo crea si no existe.
     * Versión interna con auto-creación básica (solo dni, nombre, apellido).
     */
    private int buscarOCrearCliente(Connection con, String dni, String nombreCompleto) throws SQLException {
        String sqlBuscar = "SELECT id_cliente FROM Cliente WHERE dni = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlBuscar)) {
            ps.setString(1, dni);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id_cliente");
                }
            }
        }

        // No existe: crear con nombre básico
        String[] partes = separarNombre(nombreCompleto);
        String sqlCrear = "INSERT INTO Cliente (dni, nombre, apellido) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sqlCrear, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dni);
            ps.setString(2, partes[0]);
            ps.setString(3, partes[1]);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo crear el cliente con DNI: " + dni);
    }

    /**
     * Separa un nombre completo en nombre y apellido.
     */
    private String[] separarNombre(String nombreCompleto) {
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) {
            return new String[]{"-", "-"};
        }
        nombreCompleto = nombreCompleto.trim();
        int espacio = nombreCompleto.indexOf(" ");
        if (espacio > 0) {
            return new String[]{nombreCompleto.substring(0, espacio), nombreCompleto.substring(espacio + 1)};
        }
        return new String[]{nombreCompleto, "-"};
    }
}
