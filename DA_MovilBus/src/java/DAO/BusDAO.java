package DAO;

import conexion.ConexionBD;
import model.Bus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class BusDAO {

    // =========================================================
    // LISTAR BUSES
    // =========================================================
    public ArrayList<Bus> listarBuses() {

        ArrayList<Bus> lista = new ArrayList<>();

        String sql = """
                     SELECT
                         id_bus,
                         placa,
                         modelo,
                         capacidad,
                         anio,
                         estado
                     FROM Bus
                     ORDER BY id_bus
                     """;

        Connection cn = ConexionBD
                .getInstancia()
                .getConexion();

        if (cn == null) {
            System.err.println(
                    "No existe conexión con SQL Server."
            );
            return lista;
        }

        try (
                PreparedStatement ps = cn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                Bus bus = new Bus();

                bus.setIdBus(
                        rs.getInt("id_bus")
                );

                bus.setPlaca(
                        rs.getString("placa")
                );

                bus.setModelo(
                        rs.getString("modelo")
                );

                bus.setCapacidad(
                        rs.getInt("capacidad")
                );

                bus.setAnio(
                        rs.getInt("anio")
                );

                bus.setEstado(
                        rs.getString("estado")
                );

                lista.add(bus);
            }

        } catch (SQLException e) {

            System.err.println(
                    "Error al listar buses: "
                    + e.getMessage()
            );
        }

        return lista;
    }

    // =========================================================
    // INSERTAR BUS Y GENERAR AUTOMÁTICAMENTE SUS ASIENTOS
    // =========================================================
    public boolean insertarBus(Bus bus) {

        if (bus == null) {
            System.err.println(
                    "No se puede insertar un bus nulo."
            );
            return false;
        }

        if (bus.getCapacidad() <= 0) {
            System.err.println(
                    "La capacidad del bus debe ser mayor que cero."
            );
            return false;
        }

        String sqlBus = """
                        INSERT INTO Bus
                            (
                                placa,
                                modelo,
                                capacidad,
                                anio,
                                estado
                            )
                        VALUES (?, ?, ?, ?, ?)
                        """;

        Connection cn = ConexionBD
                .getInstancia()
                .getConexion();

        if (cn == null) {
            System.err.println(
                    "No existe conexión con SQL Server."
            );
            return false;
        }

        boolean autoCommitAnterior = true;

        try {

            autoCommitAnterior = cn.getAutoCommit();

            /*
             * Se desactiva el guardado automático.
             * El bus y sus asientos formarán una sola operación.
             */
            cn.setAutoCommit(false);

            int idBusGenerado;

            try (
                    PreparedStatement ps = cn.prepareStatement(
                            sqlBus,
                            Statement.RETURN_GENERATED_KEYS
                    )
            ) {

                ps.setString(
                        1,
                        bus.getPlaca()
                );

                ps.setString(
                        2,
                        bus.getModelo()
                );

                ps.setInt(
                        3,
                        bus.getCapacidad()
                );

                ps.setInt(
                        4,
                        bus.getAnio()
                );

                ps.setString(
                        5,
                        bus.getEstado()
                );

                int filasInsertadas = ps.executeUpdate();

                if (filasInsertadas != 1) {
                    throw new SQLException(
                            "No se pudo registrar el bus."
                    );
                }

                try (
                        ResultSet clavesGeneradas
                                = ps.getGeneratedKeys()
                ) {

                    if (!clavesGeneradas.next()) {
                        throw new SQLException(
                                "No se pudo obtener el id_bus generado."
                        );
                    }

                    idBusGenerado
                            = clavesGeneradas.getInt(1);
                }
            }

            /*
             * Después de registrar el bus, se crean automáticamente
             * todos sus asientos usando el mismo Connection.
             */
            generarAsientos(
                    cn,
                    idBusGenerado,
                    bus.getCapacidad()
            );

            /*
             * Solo se confirma la operación cuando el bus y todos
             * los asientos se insertaron correctamente.
             */
            cn.commit();

            bus.setIdBus(idBusGenerado);

            System.out.println(
                    "Bus registrado correctamente con id: "
                    + idBusGenerado
            );

            System.out.println(
                    "Asientos generados: "
                    + bus.getCapacidad()
            );

            return true;

        } catch (SQLException e) {

            /*
             * Si falla el bus o cualquiera de los asientos,
             * se deshace toda la operación.
             */
            try {
                cn.rollback();

                System.err.println(
                        "Se ejecutó rollback. "
                        + "No se guardó el bus ni sus asientos."
                );

            } catch (SQLException errorRollback) {

                System.err.println(
                        "Error al ejecutar rollback: "
                        + errorRollback.getMessage()
                );
            }

            System.err.println(
                    "Error al insertar bus y asientos: "
                    + e.getMessage()
            );

            return false;

        } finally {

            /*
             * Se devuelve la conexión a su configuración anterior.
             */
            try {
                cn.setAutoCommit(autoCommitAnterior);

            } catch (SQLException e) {

                System.err.println(
                        "No se pudo restaurar el autoCommit: "
                        + e.getMessage()
                );
            }
        }
    }

    // =========================================================
    // GENERAR LA MATRIZ DE ASIENTOS
    // =========================================================
    private void generarAsientos(
            Connection cn,
            int idBus,
            int capacidad
    ) throws SQLException {

        String sqlAsiento = """
                            INSERT INTO Bus_Asiento
                                (
                                    id_bus,
                                    numero_asiento,
                                    piso,
                                    fila,
                                    columna,
                                    lado,
                                    id_tipo_asiento
                                )
                            VALUES (?, ?, ?, ?, ?, ?, ?)
                            """;

        /*
         * Regla utilizada:
         *
         * - Hasta 40 asientos: bus de un piso.
         * - Más de 40 asientos: bus de dos pisos.
         * - Cuatro asientos por fila.
         * - Columnas 1 y 2: lado izquierdo.
         * - Columnas 3 y 4: lado derecho.
         * - Tipo de asiento inicial: Regular 140° (id 1).
         *
         * La distribución puede ajustarse posteriormente si el
         * docente entrega una plantilla física específica.
         */

        int cantidadPisos
                = capacidad > 40 ? 2 : 1;

        int asientosPrimerPiso;

        if (cantidadPisos == 1) {
            asientosPrimerPiso = capacidad;
        } else {
            asientosPrimerPiso = capacidad / 2;
        }

        int asientosSegundoPiso
                = capacidad - asientosPrimerPiso;

        int numeroAsiento = 1;

        try (
                PreparedStatement ps
                        = cn.prepareStatement(sqlAsiento)
        ) {

            for (
                    int piso = 1;
                    piso <= cantidadPisos;
                    piso++
            ) {

                int asientosDelPiso;

                if (piso == 1) {
                    asientosDelPiso = asientosPrimerPiso;
                } else {
                    asientosDelPiso = asientosSegundoPiso;
                }

                for (
                        int posicion = 0;
                        posicion < asientosDelPiso;
                        posicion++
                ) {

                    int fila
                            = (posicion / 4) + 1;

                    int columna
                            = (posicion % 4) + 1;

                    String lado;

                    if (columna <= 2) {
                        lado = "IZQUIERDO";
                    } else {
                        lado = "DERECHO";
                    }

                    /*
                     * En Tipo_Asiento:
                     * 1 = Regular 140°
                     */
                    int idTipoAsiento = 1;

                    ps.setInt(
                            1,
                            idBus
                    );

                    ps.setInt(
                            2,
                            numeroAsiento
                    );

                    ps.setInt(
                            3,
                            piso
                    );

                    ps.setInt(
                            4,
                            fila
                    );

                    ps.setInt(
                            5,
                            columna
                    );

                    ps.setString(
                            6,
                            lado
                    );

                    ps.setInt(
                            7,
                            idTipoAsiento
                    );

                    ps.addBatch();

                    numeroAsiento++;
                }
            }

            int[] resultados = ps.executeBatch();

            if (resultados.length != capacidad) {
                throw new SQLException(
                        "No se generaron todos los asientos. "
                        + "Esperados: "
                        + capacidad
                        + ", generados: "
                        + resultados.length
                );
            }

            for (int resultado : resultados) {

                if (resultado == Statement.EXECUTE_FAILED) {
                    throw new SQLException(
                            "Falló la inserción de uno "
                            + "o más asientos."
                    );
                }
            }
        }
    }

    // =========================================================
    // ACTUALIZAR BUS
    // =========================================================
    public boolean actualizarBus(Bus bus) {

        String sql = """
                     UPDATE Bus
                     SET
                         placa = ?,
                         modelo = ?,
                         capacidad = ?,
                         anio = ?,
                         estado = ?
                     WHERE id_bus = ?
                     """;

        Connection cn = ConexionBD
                .getInstancia()
                .getConexion();

        if (cn == null) {
            System.err.println(
                    "No existe conexión con SQL Server."
            );
            return false;
        }

        try (
                PreparedStatement ps = cn.prepareStatement(sql)
        ) {

            ps.setString(
                    1,
                    bus.getPlaca()
            );

            ps.setString(
                    2,
                    bus.getModelo()
            );

            ps.setInt(
                    3,
                    bus.getCapacidad()
            );

            ps.setInt(
                    4,
                    bus.getAnio()
            );

            ps.setString(
                    5,
                    bus.getEstado()
            );

            ps.setInt(
                    6,
                    bus.getIdBus()
            );

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            System.err.println(
                    "Error al actualizar bus: "
                    + e.getMessage()
            );

            return false;
        }
    }
}