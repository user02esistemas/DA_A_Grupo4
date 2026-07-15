package dao;

import config.ConexionBD;
import model.Encomienda;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EncomiendaDAO {

    /**
     * Registra una nueva encomienda junto con su pago en una transacción.
     * Si el remitente o destinatario no existen como Cliente, se crean automáticamente.
     *
     * @param encomienda   Datos de la encomienda
     * @param dniRemitente    DNI del remitente
     * @param nombreRemitente Nombre del remitente
     * @param dniDest    DNI del destinatario
     * @param nombreDest     Nombre del destinatario
     * @param idVendedor  ID del usuario que registra (opcional, null para cliente web)
     * @param metodoPago  Método de pago
     * @return true si se registró exitosamente
     */
    public boolean registrarEncomienda(Encomienda encomienda,
                                       String dniRemitente, String nombreRemitente,
                                       String dniDest, String nombreDest,
                                       Integer idVendedor, String metodoPago) {
        String sqlEncomienda = "INSERT INTO Encomienda (descripcion_contenido, peso_kg, precio_envio, " +
                               "estado, fecha_envio, id_viaje, id_remitente, id_destinatario) " +
                               "OUTPUT INSERTED.id_encomienda " +
                               "VALUES (?, ?, ?, 'REGISTRADO', GETDATE(), ?, ?, ?)";

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

            // 3. Insertar encomienda
            psEnc = con.prepareStatement(sqlEncomienda);
            psEnc.setString(1, encomienda.getDescripcionContenido());
            psEnc.setDouble(2, encomienda.getPesoKg());
            psEnc.setDouble(3, encomienda.getPrecioEnvio());
            psEnc.setInt(4, encomienda.getIdViaje());
            psEnc.setInt(5, idRemitente);
            psEnc.setInt(6, idDestinatario);

            int idEncomiendaGenerado = 0;
            rs = psEnc.executeQuery();
            if (rs.next()) {
                idEncomiendaGenerado = rs.getInt(1);
            }

            if (idEncomiendaGenerado == 0) {
                throw new SQLException("No se pudo generar el ID de la encomienda.");
            }

            // 4. Insertar pago asociado (Pago.id_pasaje puede ser NULL, usamos id_encomienda)
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
            System.out.println("[OK] Encomienda #" + idEncomiendaGenerado + " registrada");
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
        String sql = "SELECT e.id_encomienda, e.descripcion_contenido, e.peso_kg, e.precio_envio, " +
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
     * Lista encomiendas donde el DNI del remitente o destinatario coincide.
     * Útil para que un cliente vea sus envíos.
     */
    public List<Map<String, Object>> listarEncomiendasPorCliente(String dniCliente) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT e.id_encomienda, e.descripcion_contenido, e.peso_kg, e.precio_envio, " +
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
     * Actualiza el estado de una encomienda.
     */
    public boolean actualizarEstado(int idEncomienda, String nuevoEstado) {
        String sql = "UPDATE Encomienda SET estado = ? WHERE id_encomienda = ?";
        // Si se marca como ENTREGADO, registrar la fecha
        if ("ENTREGADO".equalsIgnoreCase(nuevoEstado)) {
            sql = "UPDATE Encomienda SET estado = ?, fecha_entrega_real = GETDATE() WHERE id_encomienda = ?";
        }
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idEncomienda);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar estado encomienda: " + e.getMessage());
            return false;
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
