package dao;

import config.ConexionBD;
import model.Bus;
import util.AsientoLayoutUtil;
import util.AsientoLayoutUtil.PlantillaAsiento;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BusDAO {

    public List<Bus> listarBuses() {
        List<Bus> lista = new ArrayList<>();
        String sql = "SELECT b.id_bus, b.placa, b.marca, b.modelo, b.capacidad_asientos, " +
                     "b.cantidad_pisos, b.estado, b.id_servicio, s.nombre_servicio " +
                     "FROM Bus b INNER JOIN Servicio s ON b.id_servicio = s.id_servicio ORDER BY b.id_bus";

        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Bus(
                    rs.getInt("id_bus"),
                    rs.getString("placa"),
                    rs.getString("marca"),
                    rs.getString("modelo"),
                    rs.getInt("capacidad_asientos"),
                    rs.getInt("cantidad_pisos"),
                    rs.getString("estado"),
                    rs.getInt("id_servicio"),
                    rs.getString("nombre_servicio")
                ));
            }
        } catch (SQLException e) {
            System.err.println("Error al listar buses: " + e.getMessage());
        }
        return lista;
    }

    public Bus obtenerPorId(int idBus) {
        String sql = "SELECT b.id_bus, b.placa, b.marca, b.modelo, b.capacidad_asientos, " +
                     "b.cantidad_pisos, b.estado, b.id_servicio, s.nombre_servicio " +
                     "FROM Bus b INNER JOIN Servicio s ON b.id_servicio = s.id_servicio WHERE b.id_bus = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idBus);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Bus(
                        rs.getInt("id_bus"),
                        rs.getString("placa"),
                        rs.getString("marca"),
                        rs.getString("modelo"),
                        rs.getInt("capacidad_asientos"),
                        rs.getInt("cantidad_pisos"),
                        rs.getString("estado"),
                        rs.getInt("id_servicio"),
                        rs.getString("nombre_servicio")
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener bus: " + e.getMessage());
        }
        return null;
    }

    public boolean insertarBusConAsientos(Bus bus) {
        String sqlBus = "INSERT INTO Bus (placa, marca, modelo, capacidad_asientos, cantidad_pisos, estado, id_servicio) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlAsiento = "INSERT INTO Bus_Asiento (id_bus, numero_asiento, piso, fila, columna, posicion, recargo_ubicacion, estado, id_tipo_asiento) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, 'DISPONIBLE', ?)";

        Connection con = null;
        PreparedStatement psBus = null;
        PreparedStatement psAsiento = null;
        ResultSet rs = null;

        try {
            con = ConexionBD.getConexion();
            con.setAutoCommit(false);

            psBus = con.prepareStatement(sqlBus, Statement.RETURN_GENERATED_KEYS);
            psBus.setString(1, bus.getPlaca());
            psBus.setString(2, bus.getMarca());
            psBus.setString(3, bus.getModelo());
            psBus.setInt(4, bus.getCapacidadAsientos());
            psBus.setInt(5, bus.getCantidadPisos());
            psBus.setString(6, bus.getEstado());
            psBus.setInt(7, bus.getIdServicio());

            int filasAfectadas = psBus.executeUpdate();
            int idBusGenerado = 0;

            if (filasAfectadas > 0) {
                rs = psBus.getGeneratedKeys();
                if (rs.next()) idBusGenerado = rs.getInt(1);
            }

            if (idBusGenerado > 0) {
                List<PlantillaAsiento> plantilla = AsientoLayoutUtil.generarPlantilla(
                    bus.getIdServicio(), bus.getCapacidadAsientos(), bus.getCantidadPisos());

                psAsiento = con.prepareStatement(sqlAsiento);
                for (PlantillaAsiento pa : plantilla) {
                    psAsiento.setInt(1, idBusGenerado);
                    psAsiento.setInt(2, pa.numeroAsiento);
                    psAsiento.setInt(3, pa.piso);
                    psAsiento.setInt(4, pa.fila);
                    psAsiento.setInt(5, pa.columna);
                    psAsiento.setString(6, pa.posicion);
                    psAsiento.setDouble(7, pa.recargoUbicacion);
                    psAsiento.setInt(8, pa.idTipoAsiento);
                    psAsiento.addBatch();
                }
                psAsiento.executeBatch();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("Error transaccional en BusDAO: " + e.getMessage());
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (psBus != null) psBus.close(); } catch (SQLException e) {}
            try { if (psAsiento != null) psAsiento.close(); } catch (SQLException e) {}
        }
    }

    public boolean actualizar(Bus bus) {
        String sql = "UPDATE Bus SET placa=?, marca=?, modelo=?, estado=? WHERE id_bus=?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, bus.getPlaca());
            ps.setString(2, bus.getMarca());
            ps.setString(3, bus.getModelo());
            ps.setString(4, bus.getEstado());
            ps.setInt(5, bus.getIdBus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al actualizar bus: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarLogico(int idBus) {
        String sql = "UPDATE Bus SET estado = 'INACTIVO' WHERE id_bus = ?";
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idBus);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error al eliminar bus: " + e.getMessage());
            return false;
        }
    }
}
