package dao;

import config.ConexionBD;
import model.CitaEncomienda;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CitaEncomiendaDAO {

    /**
     * Registra una nueva cita de encomienda.
     * Si el cliente no existe (por DNI), lo crea automáticamente.
     */
    public int insertarCita(CitaEncomienda cita, String dniCliente, String nombreCliente, String telefono) {
        String sqlCita = "INSERT INTO Cita_Encomienda (id_cliente, id_origen, id_destino, descripcion, " +
                         "peso_estimado, fecha_preferida, hora_preferida, estado, observaciones) " +
                         "OUTPUT INSERTED.id_cita " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDIENTE', ?)";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            // 1. Buscar o crear cliente
            int idCliente = buscarOCrearCliente(con, dniCliente, nombreCliente, telefono);

            // 2. Insertar cita
            ps = con.prepareStatement(sqlCita);
            ps.setInt(1, idCliente);
            ps.setInt(2, cita.getIdOrigen());
            ps.setInt(3, cita.getIdDestino());
            ps.setString(4, cita.getDescripcion());
            ps.setDouble(5, cita.getPesoEstimado());
            ps.setString(6, cita.getFechaPreferida());
            ps.setString(7, cita.getHoraPreferida());
            ps.setString(8, cita.getObservaciones() != null ? cita.getObservaciones() : "");

            rs = ps.executeQuery();
            int idGenerado = 0;
            if (rs.next()) {
                idGenerado = rs.getInt(1);
            }

            con.commit();
            return idGenerado;

        } catch (SQLException e) {
            System.err.println("Error al registrar cita encomienda: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return 0;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }

    /**
     * Lista todas las citas para el panel de administración.
     */
    public List<CitaEncomienda> listarCitas() {
        return ejecutarListadoCitas("", null);
    }

    /**
     * Lista citas filtradas por DNI del cliente.
     */
    public List<CitaEncomienda> listarCitasPorCliente(String dniCliente) {
        return ejecutarListadoCitas("WHERE cli.dni = ?", ps -> {
            try {
                ps.setString(1, dniCliente);
            } catch (SQLException e) {
                System.err.println("Error al setear parámetro: " + e.getMessage());
            }
        });
    }

    @FunctionalInterface
    private interface ParamSetter {
        void set(PreparedStatement ps) throws SQLException;
    }

    private List<CitaEncomienda> ejecutarListadoCitas(String whereExtra, ParamSetter paramSetter) {
        List<CitaEncomienda> lista = new ArrayList<>();
        String sql = "SELECT c.id_cita, c.descripcion, c.peso_estimado, c.fecha_preferida, c.hora_preferida, " +
                     "c.estado, c.fecha_registro, c.observaciones, " +
                     "cli.id_cliente, cli.dni, cli.nombre AS nombre_cliente, cli.apellido, cli.telefono, " +
                     "o.nombre AS origen, d.nombre AS destino " +
                     "FROM Cita_Encomienda c " +
                     "INNER JOIN Cliente cli ON c.id_cliente = cli.id_cliente " +
                     "INNER JOIN Ciudades o ON c.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON c.id_destino = d.id_ciudad " +
                     + whereExtra + " " +
                     "ORDER BY c.fecha_registro DESC";
        List<CitaEncomienda> lista = new ArrayList<>();
        String sql = "SELECT c.id_cita, c.descripcion, c.peso_estimado, c.fecha_preferida, c.hora_preferida, " +
                     "c.estado, c.fecha_registro, c.observaciones, " +
                     "cli.id_cliente, cli.dni, cli.nombre AS nombre_cliente, cli.apellido, cli.telefono, " +
                     "o.nombre AS origen, d.nombre AS destino " +
                     "FROM Cita_Encomienda c " +
                     "INNER JOIN Cliente cli ON c.id_cliente = cli.id_cliente " +
                     "INNER JOIN Ciudades o ON c.id_origen = o.id_ciudad " +
                     "INNER JOIN Ciudades d ON c.id_destino = d.id_ciudad " +
                     "ORDER BY c.fecha_registro DESC";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CitaEncomienda c = new CitaEncomienda();
                c.setIdCita(rs.getInt("id_cita"));
                c.setIdCliente(rs.getInt("id_cliente"));
                c.setDescripcion(rs.getString("descripcion"));
                c.setPesoEstimado(rs.getDouble("peso_estimado"));
                c.setFechaPreferida(rs.getString("fecha_preferida"));
                c.setHoraPreferida(rs.getString("hora_preferida"));
                c.setEstado(rs.getString("estado"));
                c.setFechaRegistro(rs.getTimestamp("fecha_registro"));
                c.setObservaciones(rs.getString("observaciones"));
                c.setNombreCliente(rs.getString("nombre_cliente") + " " + rs.getString("apellido"));
                c.setDniCliente(rs.getString("dni"));
                c.setTelefonoCliente(rs.getString("telefono"));
                c.setNombreOrigen(rs.getString("origen"));
                c.setNombreDestino(rs.getString("destino"));
                lista.add(c);
            }
        } catch (SQLException e) {
            System.err.println("Error al listar citas: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Cambia el estado de una cita (PENDIENTE → CONFIRMADA / CANCELADA / COMPLETADA).
     */
    public boolean actualizarEstado(int idCita, String nuevoEstado) {
        String sql = "UPDATE Cita_Encomienda SET estado = ? WHERE id_cita = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar estado cita: " + e.getMessage());
            return false;
        }
    }

    // =================================================================
    //  MÉTODOS AUXILIARES
    // =================================================================

    private int buscarOCrearCliente(Connection con, String dni, String nombreCompleto, String telefono) throws SQLException {
        String sqlBuscar = "SELECT id_cliente FROM Cliente WHERE dni = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlBuscar)) {
            ps.setString(1, dni);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id_cliente");
            }
        }

        String[] partes = separarNombre(nombreCompleto);
        String sqlCrear = "INSERT INTO Cliente (dni, nombre, apellido, telefono) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sqlCrear, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dni);
            ps.setString(2, partes[0]);
            ps.setString(3, partes[1]);
            ps.setString(4, telefono != null ? telefono : "");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo crear el cliente con DNI: " + dni);
    }

    private String[] separarNombre(String nombreCompleto) {
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()) return new String[]{"-", "-"};
        nombreCompleto = nombreCompleto.trim();
        int espacio = nombreCompleto.indexOf(" ");
        if (espacio > 0) {
            return new String[]{nombreCompleto.substring(0, espacio), nombreCompleto.substring(espacio + 1)};
        }
        return new String[]{nombreCompleto, "-"};
    }
}
