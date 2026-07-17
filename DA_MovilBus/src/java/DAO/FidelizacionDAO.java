package dao;

import config.ConexionBD;
import model.PuntosCliente;
import model.TransaccionPuntos;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FidelizacionDAO {

    // ================================================================
    //  CONSTANTES DEL PROGRAMA
    // ================================================================
    private static final int PUNTOS_POR_SOL = 10; // 1 punto cada S/10 → 10 centavos = 1 punto
    private static final int PUNTOS_CANJE_POR_SOL = 100; // 100 puntos = S/1 de descuento

    // ================================================================
    //  INICIALIZAR NIVELES (ejecutar una vez al deployar)
    // ================================================================
    public void inicializarNiveles() {
        String sql = "IF NOT EXISTS (SELECT 1 FROM Nivel_Fidelidad) BEGIN "
                + "INSERT INTO Nivel_Fidelidad (nombre_nivel, puntos_desde, puntos_hasta, descuento_porcentaje, color_hex, icono) VALUES "
                + "('BRONCE', 0, 199, 0, '#CD7F32', 'bi-trophy-fill'), "
                + "('PLATA', 200, 499, 3, '#C0C0C0', 'bi-trophy-fill'), "
                + "('ORO', 500, 999, 5, '#FFD700', 'bi-trophy-fill'), "
                + "('PLATINO', 1000, NULL, 10, '#E5E4E2', 'bi-star-fill') "
                + "END";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
            System.out.println("[Fidelizacion] Niveles inicializados correctamente.");
        } catch (SQLException e) {
            System.err.println("Error inicializar niveles: " + e.getMessage());
        }
    }

    // ================================================================
    //  OBTENER / CLASIFICAR NIVEL
    // ================================================================

    /**
     * Determina el nivel de fidelidad según los puntos acumulados.
     */
    public Map<String, Object> obtenerNivelPorPuntos(int puntosAcumulados) {
        String sql = "SELECT id_nivel, nombre_nivel, descuento_porcentaje, color_hex, icono "
                + "FROM Nivel_Fidelidad "
                + "WHERE puntos_desde <= ? AND (puntos_hasta IS NULL OR puntos_hasta >= ?)";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, puntosAcumulados);
            ps.setInt(2, puntosAcumulados);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> nivel = new HashMap<>();
                    nivel.put("idNivel", rs.getInt("id_nivel"));
                    nivel.put("nombre", rs.getString("nombre_nivel"));
                    nivel.put("descuento", rs.getDouble("descuento_porcentaje"));
                    nivel.put("color", rs.getString("color_hex"));
                    nivel.put("icono", rs.getString("icono"));
                    return nivel;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obtenerNivelPorPuntos: " + e.getMessage());
        }
        // Default: Bronce
        Map<String, Object> nivel = new HashMap<>();
        nivel.put("idNivel", 1);
        nivel.put("nombre", "BRONCE");
        nivel.put("descuento", 0.0);
        nivel.put("color", "#CD7F32");
        nivel.put("icono", "bi-trophy-fill");
        return nivel;
    }

    // ================================================================
    //  PUNTOS DEL CLIENTE
    // ================================================================

    /**
     * Obtiene o crea el registro de puntos de un cliente.
     */
    public PuntosCliente obtenerPuntosCliente(int idCliente) {
        // Primero intentar obtener
        String sql = "SELECT pc.*, c.dni, c.nombre, c.apellido, "
                + "nf.nombre_nivel, nf.color_hex, nf.icono, nf.descuento_porcentaje "
                + "FROM Puntos_Cliente pc "
                + "INNER JOIN Cliente c ON pc.id_cliente = c.id_cliente "
                + "LEFT JOIN Nivel_Fidelidad nf ON pc.id_nivel_actual = nf.id_nivel "
                + "WHERE pc.id_cliente = ?";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearPuntosCliente(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obtenerPuntosCliente: " + e.getMessage());
        }

        // No existe → crear registro
        return crearRegistroPuntos(idCliente);
    }

    /**
     * Crea un registro de puntos para un cliente nuevo.
     */
    private PuntosCliente crearRegistroPuntos(int idCliente) {
        String sql = "INSERT INTO Puntos_Cliente (id_cliente, puntos_acumulados, puntos_canjeados, id_nivel_actual, fecha_ultima_actualizacion) "
                + "VALUES (?, 0, 0, 1, GETDATE())";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error crearRegistroPuntos: " + e.getMessage());
        }
        // Retornar objeto con valores default
        PuntosCliente pc = new PuntosCliente();
        pc.setIdCliente(idCliente);
        pc.setPuntosAcumulados(0);
        pc.setPuntosCanjeados(0);
        pc.setNombreNivel("BRONCE");
        pc.setNivelColor("#CD7F32");
        pc.setNivelIcono("bi-trophy-fill");
        pc.setDescuentoNivel(0);
        return pc;
    }

    /**
     * Busca cliente por DNI y retorna sus puntos.
     */
    public PuntosCliente obtenerPuntosPorDNI(String dni) {
        String sql = "SELECT pc.*, c.dni, c.nombre, c.apellido, "
                + "nf.nombre_nivel, nf.color_hex, nf.icono, nf.descuento_porcentaje "
                + "FROM Puntos_Cliente pc "
                + "INNER JOIN Cliente c ON pc.id_cliente = c.id_cliente "
                + "LEFT JOIN Nivel_Fidelidad nf ON pc.id_nivel_actual = nf.id_nivel "
                + "WHERE c.dni = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, dni);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearPuntosCliente(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error obtenerPuntosPorDNI: " + e.getMessage());
        }
        return null;
    }

    // ================================================================
    //  ACUMULAR PUNTOS POR COMPRA
    // ================================================================

    /**
     * Acumula puntos para un cliente después de una compra exitosa.
     * Calcula: monto / 10 = puntos (ej: S/50 → 5 puntos)
     * 
     * @param idCliente ID del cliente
     * @param montoGastado Monto total de la compra
     * @param idPasaje ID del pasaje asociado (opcional, puede ser null)
     * @return true si se acumularon correctamente
     */
    public boolean acumularPuntos(int idCliente, double montoGastado, Integer idPasaje) {
        int puntosGanados = (int) (montoGastado / PUNTOS_POR_SOL);
        if (puntosGanados <= 0) return true; // montos muy pequeños no generan puntos

        Connection con = null;
        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            // 1. Obtener o crear registro de puntos
            PuntosCliente pc = obtenerPuntosClienteConConexion(con, idCliente);

            // 2. Actualizar puntos acumulados
            String sqlUpdate = "UPDATE Puntos_Cliente SET puntos_acumulados = puntos_acumulados + ?, "
                    + "fecha_ultima_actualizacion = GETDATE() WHERE id_cliente = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                ps.setInt(1, puntosGanados);
                ps.setInt(2, idCliente);
                ps.executeUpdate();
            }

            // 3. Recalcular nivel según nuevos puntos
            int nuevosPuntos = pc.getPuntosAcumulados() + puntosGanados;
            Map<String, Object> nivel = obtenerNivelPorPuntos(nuevosPuntos);
            int idNivel = (int) nivel.get("idNivel");

            String sqlNivel = "UPDATE Puntos_Cliente SET id_nivel_actual = ? WHERE id_cliente = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlNivel)) {
                ps.setInt(1, idNivel);
                ps.setInt(2, idCliente);
                ps.executeUpdate();
            }

            // 4. Registrar transacción
            String desc = "Compra de pasaje S/ " + String.format("%.2f", montoGastado)
                    + " → +" + puntosGanados + " puntos";
            String sqlTrans = "INSERT INTO Transaccion_Puntos (id_cliente, id_pasaje, tipo, puntos, monto_referencia, descripcion) "
                    + "VALUES (?, ?, 'ACUMULACION', ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sqlTrans)) {
                ps.setInt(1, idCliente);
                if (idPasaje != null) {
                    ps.setInt(2, idPasaje);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setInt(3, puntosGanados);
                ps.setDouble(4, montoGastado);
                ps.setString(5, desc);
                ps.executeUpdate();
            }

            con.commit();
            System.out.println("[Fidelizacion] +" + puntosGanados + " pts para cliente #" + idCliente);
            return true;

        } catch (SQLException e) {
            System.err.println("Error acumularPuntos: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException e) {}
            }
        }
    }

    /**
     * Versión que recibe una conexión externa (para usar dentro de transacciones
     * existentes en VentaServlet).
     */
    public boolean acumularPuntosEnTransaccion(Connection con, int idCliente, double montoGastado, Integer idPasaje)
            throws SQLException {
        int puntosGanados = (int) (montoGastado / PUNTOS_POR_SOL);
        if (puntosGanados <= 0) return true;

        // 1. Obtener o crear registro de puntos
        PuntosCliente pc = obtenerPuntosClienteConConexion(con, idCliente);

        // 2. Actualizar puntos acumulados
        String sqlUpdate = "UPDATE Puntos_Cliente SET puntos_acumulados = puntos_acumulados + ?, "
                + "fecha_ultima_actualizacion = GETDATE() WHERE id_cliente = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
            ps.setInt(1, puntosGanados);
            ps.setInt(2, idCliente);
            ps.executeUpdate();
        }

        // 3. Recalcular nivel
        int nuevosPuntos = pc.getPuntosAcumulados() + puntosGanados;
        Map<String, Object> nivel = obtenerNivelPorPuntos(nuevosPuntos);
        int idNivel = (int) nivel.get("idNivel");

        String sqlNivel = "UPDATE Puntos_Cliente SET id_nivel_actual = ? WHERE id_cliente = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlNivel)) {
            ps.setInt(1, idNivel);
            ps.setInt(2, idCliente);
            ps.executeUpdate();
        }

        // 4. Registrar transacción
        String desc = "Compra de pasaje S/ " + String.format("%.2f", montoGastado)
                + " → +" + puntosGanados + " puntos";
        String sqlTrans = "INSERT INTO Transaccion_Puntos (id_cliente, id_pasaje, tipo, puntos, monto_referencia, descripcion) "
                + "VALUES (?, ?, 'ACUMULACION', ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sqlTrans)) {
            ps.setInt(1, idCliente);
            if (idPasaje != null) {
                ps.setInt(2, idPasaje);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setInt(3, puntosGanados);
            ps.setDouble(4, montoGastado);
            ps.setString(5, desc);
            ps.executeUpdate();
        }

        System.out.println("[Fidelizacion] +" + puntosGanados + " pts para cliente #" + idCliente);
        return true;
    }

    // ================================================================
    //  CANJE DE PUNTOS
    // ================================================================

    /**
     * Canjea puntos por un descuento.
     * Mínimo 100 puntos (= S/1 de descuento).
     * 
     * @param idCliente ID del cliente
     * @param puntosAUsar Puntos a canjear
     * @return Mapa con resultado: exito (boolean), descuento (double), mensaje (String)
     */
    public Map<String, Object> canjearPuntos(int idCliente, int puntosAUsar) {
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("exito", false);

        PuntosCliente pc = obtenerPuntosCliente(idCliente);
        int puntosDisponibles = pc.getPuntosDisponibles();

        // Validar puntos mínimos
        if (puntosAUsar < PUNTOS_CANJE_POR_SOL) {
            resultado.put("mensaje", "Mínimo " + PUNTOS_CANJE_POR_SOL + " puntos para canjear.");
            return resultado;
        }
        if (puntosAUsar > puntosDisponibles) {
            resultado.put("mensaje", "No tienes suficientes puntos. Disponibles: " + puntosDisponibles);
            return resultado;
        }

        Connection con = null;
        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            // 1. Actualizar puntos canjeados
            String sqlCanje = "UPDATE Puntos_Cliente SET puntos_canjeados = puntos_canjeados + ?, "
                    + "fecha_ultima_actualizacion = GETDATE() WHERE id_cliente = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlCanje)) {
                ps.setInt(1, puntosAUsar);
                ps.setInt(2, idCliente);
                ps.executeUpdate();
            }

            // 2. Calcular descuento: 100 puntos = S/1
            double descuento = (double) puntosAUsar / PUNTOS_CANJE_POR_SOL;

            // 3. Registrar transacción
            String sqlTrans = "INSERT INTO Transaccion_Puntos (id_cliente, tipo, puntos, monto_referencia, descripcion) "
                    + "VALUES (?, 'CANJE', ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sqlTrans)) {
                ps.setInt(1, idCliente);
                ps.setInt(2, puntosAUsar);
                ps.setDouble(3, descuento);
                ps.setString(4, "Canje de " + puntosAUsar + " puntos → S/ " + String.format("%.2f", descuento) + " de descuento");
                ps.executeUpdate();
            }

            con.commit();

            resultado.put("exito", true);
            resultado.put("descuento", descuento);
            resultado.put("puntosUsados", puntosAUsar);
            resultado.put("mensaje", "¡Canje exitoso! Obtuviste S/ " + String.format("%.2f", descuento) + " de descuento.");
            System.out.println("[Fidelizacion] Canje: " + puntosAUsar + " pts → S/ " + descuento + " descuento (cliente #" + idCliente + ")");

        } catch (SQLException e) {
            System.err.println("Error canjearPuntos: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            resultado.put("mensaje", "Error al procesar el canje: " + e.getMessage());
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException e) {}
            }
        }

        return resultado;
    }

    // ================================================================
    //  HISTORIAL DE TRANSACCIONES
    // ================================================================

    public List<TransaccionPuntos> listarTransacciones(int idCliente, int limite) {
        List<TransaccionPuntos> lista = new ArrayList<>();
        String sql = "SELECT * FROM Transaccion_Puntos WHERE id_cliente = ? "
                + "ORDER BY fecha DESC";
        if (limite > 0) sql = "SELECT TOP " + limite + " * FROM Transaccion_Puntos WHERE id_cliente = ? "
                + "ORDER BY fecha DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearTransaccion(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error listarTransacciones: " + e.getMessage());
        }
        return lista;
    }

    public List<TransaccionPuntos> listarTransaccionesRecientes(int limite) {
        List<TransaccionPuntos> lista = new ArrayList<>();
        String sql = "SELECT TOP " + limite + " tp.*, c.dni, c.nombre, c.apellido "
                + "FROM Transaccion_Puntos tp "
                + "INNER JOIN Cliente c ON tp.id_cliente = c.id_cliente "
                + "ORDER BY tp.fecha DESC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearTransaccion(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error listarTransaccionesRecientes: " + e.getMessage());
        }
        return lista;
    }

    // ================================================================
    //  LISTADOS PARA ADMIN
    // ================================================================

    /**
     * Lista todos los clientes con sus puntos (para vista de admin).
     */
    public List<PuntosCliente> listarTodosClientes() {
        List<PuntosCliente> lista = new ArrayList<>();
        String sql = "SELECT pc.*, c.dni, c.nombre, c.apellido, "
                + "nf.nombre_nivel, nf.color_hex, nf.icono, nf.descuento_porcentaje "
                + "FROM Puntos_Cliente pc "
                + "INNER JOIN Cliente c ON pc.id_cliente = c.id_cliente "
                + "LEFT JOIN Nivel_Fidelidad nf ON pc.id_nivel_actual = nf.id_nivel "
                + "ORDER BY pc.puntos_acumulados DESC";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearPuntosCliente(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error listarTodosClientes: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Estadísticas del programa de fidelización.
     */
    public Map<String, Object> obtenerEstadisticas() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM Puntos_Cliente) AS total_clientes, "
                + "(SELECT ISNULL(SUM(puntos_acumulados), 0) FROM Puntos_Cliente) AS total_puntos, "
                + "(SELECT ISNULL(SUM(puntos_canjeados), 0) FROM Puntos_Cliente) AS total_canjeados, "
                + "(SELECT COUNT(*) FROM Transaccion_Puntos WHERE tipo = 'CANJE') AS total_canjes, "
                + "(SELECT COUNT(*) FROM Puntos_Cliente WHERE puntos_acumulados >= 1000) AS platino_count, "
                + "(SELECT COUNT(*) FROM Puntos_Cliente WHERE puntos_acumulados >= 500 AND puntos_acumulados < 1000) AS oro_count, "
                + "(SELECT COUNT(*) FROM Puntos_Cliente WHERE puntos_acumulados >= 200 AND puntos_acumulados < 500) AS plata_count, "
                + "(SELECT COUNT(*) FROM Puntos_Cliente WHERE puntos_acumulados < 200) AS bronce_count";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("totalClientes", rs.getInt("total_clientes"));
                stats.put("totalPuntos", rs.getInt("total_puntos"));
                stats.put("totalCanjeados", rs.getInt("total_canjeados"));
                stats.put("totalCanjes", rs.getInt("total_canjes"));
                stats.put("platino", rs.getInt("platino_count"));
                stats.put("oro", rs.getInt("oro_count"));
                stats.put("plata", rs.getInt("plata_count"));
                stats.put("bronce", rs.getInt("bronce_count"));
            }
        } catch (SQLException e) {
            System.err.println("Error obtenerEstadisticas: " + e.getMessage());
        }
        return stats;
    }

    // ================================================================
    //  HELPERS
    // ================================================================

    /**
     * Obtiene puntos de cliente usando una conexión existente.
     * Si no existe registro, lo crea.
     */
    private PuntosCliente obtenerPuntosClienteConConexion(Connection con, int idCliente) throws SQLException {
        String sql = "SELECT pc.*, ISNULL(nf.id_nivel, 1) AS id_nivel_actual, "
                + "ISNULL(nf.nombre_nivel, 'BRONCE') AS nombre_nivel, "
                + "ISNULL(nf.descuento_porcentaje, 0) AS descuento_porcentaje "
                + "FROM Puntos_Cliente pc "
                + "LEFT JOIN Nivel_Fidelidad nf ON pc.id_nivel_actual = nf.id_nivel "
                + "WHERE pc.id_cliente = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PuntosCliente pc = new PuntosCliente();
                    pc.setIdCliente(rs.getInt("id_cliente"));
                    pc.setPuntosAcumulados(rs.getInt("puntos_acumulados"));
                    pc.setPuntosCanjeados(rs.getInt("puntos_canjeados"));
                    return pc;
                }
            }
        }

        // No existe → crear
        String sqlInsert = "INSERT INTO Puntos_Cliente (id_cliente, puntos_acumulados, puntos_canjeados, id_nivel_actual) "
                + "VALUES (?, 0, 0, 1)";
        try (PreparedStatement ps = con.prepareStatement(sqlInsert)) {
            ps.setInt(1, idCliente);
            ps.executeUpdate();
        }

        PuntosCliente pc = new PuntosCliente();
        pc.setIdCliente(idCliente);
        pc.setPuntosAcumulados(0);
        pc.setPuntosCanjeados(0);
        return pc;
    }

    private PuntosCliente mapearPuntosCliente(ResultSet rs) throws SQLException {
        PuntosCliente pc = new PuntosCliente();
        pc.setIdPuntos(rs.getInt("id_puntos"));
        pc.setIdCliente(rs.getInt("id_cliente"));
        pc.setPuntosAcumulados(rs.getInt("puntos_acumulados"));
        pc.setPuntosCanjeados(rs.getInt("puntos_canjeados"));
        pc.setIdNivelActual(rs.getInt("id_nivel_actual"));
        pc.setFechaUltimaActualizacion(rs.getTimestamp("fecha_ultima_actualizacion"));

        // Datos del cliente
        try { pc.setDniCliente(rs.getString("dni")); } catch (SQLException e) {}
        try { pc.setNombreCliente(rs.getString("nombre") + " " + rs.getString("apellido")); } catch (SQLException e) {}

        // Datos del nivel
        try { pc.setNombreNivel(rs.getString("nombre_nivel")); } catch (SQLException e) {}
        try { pc.setNivelColor(rs.getString("color_hex")); } catch (SQLException e) {}
        try { pc.setNivelIcono(rs.getString("icono")); } catch (SQLException e) {}
        try { pc.setDescuentoNivel(rs.getDouble("descuento_porcentaje")); } catch (SQLException e) {}

        return pc;
    }

    private TransaccionPuntos mapearTransaccion(ResultSet rs) throws SQLException {
        TransaccionPuntos t = new TransaccionPuntos();
        t.setIdTransaccion(rs.getInt("id_transaccion"));
        t.setIdCliente(rs.getInt("id_cliente"));
        t.setIdPasaje(rs.getObject("id_pasaje") != null ? rs.getInt("id_pasaje") : null);
        t.setTipo(rs.getString("tipo"));
        t.setPuntos(rs.getInt("puntos"));
        t.setMontoReferencia(rs.getDouble("monto_referencia"));
        t.setDescripcion(rs.getString("descripcion"));
        t.setFecha(rs.getTimestamp("fecha"));
        return t;
    }

    // ================================================================
    //  GETTER para la constante (usado desde JSP/Servlets)
    // ================================================================

    public static int getPuntosCanjePorSol() {
        return PUNTOS_CANJE_POR_SOL;
    }

    public static int getPuntosPorSol() {
        return PUNTOS_POR_SOL;
    }
}
